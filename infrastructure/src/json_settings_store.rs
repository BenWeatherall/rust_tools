//! JSON file adapter for [`SettingsStore`].

use core_domain::{AppSettings, DomainError, SettingsStore, WindowGeometry};
use std::fs;
use std::path::{Path, PathBuf};

use serde::{Deserialize, Serialize};

/// Serializable mirror of [`WindowGeometry`] for JSON persistence.
#[derive(Debug, Serialize, Deserialize, PartialEq, Eq)]
struct SerializableWindowGeometry {
    width: u32,
    height: u32,
    position_x: Option<i32>,
    position_y: Option<i32>,
    maximized: bool,
}

impl From<WindowGeometry> for SerializableWindowGeometry {
    fn from(geometry: WindowGeometry) -> Self {
        Self {
            width: geometry.width,
            height: geometry.height,
            position_x: geometry.position_x,
            position_y: geometry.position_y,
            maximized: geometry.maximized,
        }
    }
}

impl From<SerializableWindowGeometry> for WindowGeometry {
    fn from(geometry: SerializableWindowGeometry) -> Self {
        Self {
            width: geometry.width,
            height: geometry.height,
            position_x: geometry.position_x,
            position_y: geometry.position_y,
            maximized: geometry.maximized,
        }
    }
}

/// Serializable mirror of [`AppSettings`] for JSON persistence.
#[derive(Debug, Serialize, Deserialize, PartialEq, Eq)]
struct SerializableAppSettings {
    window: SerializableWindowGeometry,
}

impl From<AppSettings> for SerializableAppSettings {
    fn from(settings: AppSettings) -> Self {
        Self {
            window: settings.window.into(),
        }
    }
}

impl From<SerializableAppSettings> for AppSettings {
    fn from(settings: SerializableAppSettings) -> Self {
        Self {
            window: settings.window.into(),
        }
    }
}

/// Persists [`AppSettings`] as JSON at a fixed file path.
#[derive(Debug, Clone)]
pub struct JsonSettingsStore {
    path: PathBuf,
}

impl JsonSettingsStore {
    /// Creates a store that reads and writes settings at `path`.
    #[must_use]
    pub fn new(path: PathBuf) -> Self {
        Self { path }
    }

    /// Returns the platform-specific default settings file path.
    #[must_use]
    pub fn default_path() -> PathBuf {
        let config_dir = dirs::config_dir().unwrap_or_else(|| PathBuf::from("."));
        config_dir
            .join("rust-agent-foundation")
            .join("settings.json")
    }

    /// Creates a store using [`Self::default_path`].
    #[must_use]
    pub fn from_default_path() -> Self {
        Self::new(Self::default_path())
    }

    fn read_file(path: &Path) -> Result<AppSettings, DomainError> {
        let contents = fs::read_to_string(path).map_err(|error| {
            DomainError::SettingsLoadFailed(format!("failed to read {}: {error}", path.display()))
        })?;
        let serialized: SerializableAppSettings =
            serde_json::from_str(&contents).map_err(|error| {
                DomainError::SettingsLoadFailed(format!(
                    "failed to parse {}: {error}",
                    path.display()
                ))
            })?;
        Ok(serialized.into())
    }

    fn write_file(path: &Path, settings: &AppSettings) -> Result<(), DomainError> {
        if let Some(parent) = path.parent() {
            fs::create_dir_all(parent).map_err(|error| {
                DomainError::SettingsSaveFailed(format!(
                    "failed to create settings directory {}: {error}",
                    parent.display()
                ))
            })?;
        }

        let serialized = SerializableAppSettings::from(settings.clone());
        let contents = serde_json::to_string_pretty(&serialized).map_err(|error| {
            DomainError::SettingsSaveFailed(format!("failed to serialize settings: {error}"))
        })?;
        fs::write(path, contents).map_err(|error| {
            DomainError::SettingsSaveFailed(format!("failed to write {}: {error}", path.display()))
        })
    }
}

impl SettingsStore for JsonSettingsStore {
    fn load(&self) -> Result<AppSettings, DomainError> {
        if self.path.exists() {
            Self::read_file(&self.path)
        } else {
            Ok(AppSettings::default())
        }
    }

    fn save(&self, settings: &AppSettings) -> Result<(), DomainError> {
        Self::write_file(&self.path, settings)
    }
}

#[cfg(test)]
mod tests {
    use super::JsonSettingsStore;
    use core_domain::{AppSettings, SettingsStore, WindowGeometry};

    #[test]
    fn round_trips_settings() -> Result<(), core_domain::DomainError> {
        let temp_dir =
            std::env::temp_dir().join(format!("rust-agent-foundation-test-{}", std::process::id()));
        let _ = std::fs::remove_dir_all(&temp_dir);
        let path = temp_dir.join("settings.json");
        let store = JsonSettingsStore::new(path.clone());

        let settings = AppSettings {
            window: WindowGeometry {
                width: 640,
                height: 480,
                position_x: Some(100),
                position_y: Some(50),
                maximized: true,
            },
        };

        store.save(&settings)?;
        let loaded = store.load()?;
        assert_eq!(loaded, settings);

        let _ = std::fs::remove_dir_all(temp_dir);
        Ok(())
    }

    #[test]
    fn load_returns_defaults_when_missing() -> Result<(), core_domain::DomainError> {
        let temp_dir = std::env::temp_dir().join(format!(
            "rust-agent-foundation-missing-{}",
            std::process::id()
        ));
        let _ = std::fs::remove_dir_all(&temp_dir);
        let path = temp_dir.join("missing.json");
        let store = JsonSettingsStore::new(path);

        let loaded = store.load()?;
        assert_eq!(loaded, AppSettings::default());

        let _ = std::fs::remove_dir_all(temp_dir);
        Ok(())
    }
}
