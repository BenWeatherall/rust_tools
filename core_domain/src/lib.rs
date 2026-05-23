//! Core domain logic: pure business rules with no UI or infrastructure dependencies.

pub mod error;
pub mod settings;
pub mod storage;
pub mod user;

pub use error::DomainError;
pub use settings::{AppSettings, SettingsStore, WindowGeometry};
pub use storage::Storage;
pub use user::{User, UserId, UserRegistrationValidator};
