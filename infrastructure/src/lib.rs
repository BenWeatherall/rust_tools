//! Infrastructure adapters: persistence and external integrations.

pub mod in_memory_storage;
pub mod json_settings_store;

pub use in_memory_storage::InMemoryStorage;
pub use json_settings_store::JsonSettingsStore;
