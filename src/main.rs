//! Hardware-free evaluation only. Never commission real devices with this store.
use std::sync::{Arc, Mutex};
use std::time::{Duration, SystemTime, UNIX_EPOCH};

use matter_controller::{ControllerStore, FabricConfig, MatterController, MatterTime, StoreError};

// Volatile on purpose: this store keeps snapshots in process memory only.
#[derive(Default)]
struct MemoryStore(Mutex<Option<Vec<u8>>>);

impl ControllerStore for MemoryStore {
    fn load(&self) -> Result<Option<Vec<u8>>, StoreError> {
        Ok(self
            .0
            .lock()
            .map_err(|_| std::io::Error::other("store poisoned"))?
            .clone())
    }

    fn save(&self, snapshot: &[u8]) -> Result<(), StoreError> {
        *self
            .0
            .lock()
            .map_err(|_| std::io::Error::other("store poisoned"))? = Some(snapshot.to_vec());
        Ok(())
    }
}

fn fabric_config() -> FabricConfig {
    let now = SystemTime::now()
        .duration_since(UNIX_EPOCH)
        .expect("clock before Unix epoch")
        .as_secs();
    FabricConfig::new(
        1,
        1,
        1,
        (
            MatterTime::from_unix_secs(now.saturating_sub(3600)),
            MatterTime::NO_EXPIRY,
        ),
    )
}

async fn probe() -> Result<(), Box<dyn std::error::Error>> {
    let store = Arc::new(MemoryStore::default());
    // No attestation roots or pairing input: this program cannot commission a device.
    let controller = MatterController::open(store.clone()).await?;
    assert!(controller.fabrics().await?.is_empty());
    controller.create_fabric(fabric_config()).await?;
    let before = controller.fabrics().await?;
    assert_eq!(before.len(), 1);
    assert!(controller.create_fabric(fabric_config()).await.is_err());
    drop(controller);

    let reopened = MatterController::open(store).await?;
    assert_eq!(reopened.fabrics().await?, before, "fabric identity changed");
    assert!(reopened.nodes().await?.is_empty());
    println!("OK: fabric created, duplicate refused, identity restored from RAM snapshot; no hardware or disk secrets");
    // Optional bounded idle window for external RSS/CPU measurement.
    if std::env::args().any(|arg| arg == "--measure") {
        tokio::time::sleep(Duration::from_secs(30)).await;
    }
    Ok(())
}

#[tokio::main(flavor = "current_thread")]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    probe().await
}

#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn fabric_survives_controller_recreation() {
        tokio::time::timeout(Duration::from_secs(10), probe())
            .await
            .unwrap()
            .unwrap();
    }

    #[tokio::test]
    async fn corrupt_snapshot_is_rejected() {
        let store = Arc::new(MemoryStore(Mutex::new(Some(vec![0xff; 16]))));
        assert!(MatterController::open(store).await.is_err());
    }

    struct UnwritableStore;
    impl ControllerStore for UnwritableStore {
        fn load(&self) -> Result<Option<Vec<u8>>, StoreError> {
            Ok(None)
        }
        fn save(&self, _: &[u8]) -> Result<(), StoreError> {
            Err(std::io::Error::new(
                std::io::ErrorKind::PermissionDenied,
                "test store refused write",
            )
            .into())
        }
    }

    #[tokio::test]
    async fn persistence_failure_is_reported() {
        let controller = MatterController::open(Arc::new(UnwritableStore))
            .await
            .unwrap();
        assert!(controller.create_fabric(fabric_config()).await.is_err());
        // Candidate behavior: failed save still leaves an in-memory fabric.
        // An integration must discard this controller after a durable-save error.
        assert_eq!(controller.fabrics().await.unwrap().len(), 1);
        drop(controller);
        let reopened = MatterController::open(Arc::new(UnwritableStore))
            .await
            .unwrap();
        assert!(reopened.fabrics().await.unwrap().is_empty());
    }
}
