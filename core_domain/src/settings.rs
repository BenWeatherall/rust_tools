//! Application settings types and persistence contract.

/// Window size and position persisted between sessions.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct WindowGeometry {
    /// Window width in physical pixels.
    pub width: u32,
    /// Window height in physical pixels.
    pub height: u32,
    /// Window x position; `None` when the platform cannot report or restore position (e.g. Wayland).
    pub position_x: Option<i32>,
    /// Window y position; `None` when the platform cannot report or restore position (e.g. Wayland).
    pub position_y: Option<i32>,
    /// Whether the window was maximized when last saved.
    pub maximized: bool,
}

impl Default for WindowGeometry {
    fn default() -> Self {
        Self {
            width: 480,
            height: 320,
            position_x: None,
            position_y: None,
            maximized: false,
        }
    }
}

/// User-facing application settings persisted between sessions.
#[derive(Debug, Clone, PartialEq, Eq, Default)]
pub struct AppSettings {
    /// Last known window geometry.
    pub window: WindowGeometry,
}

/// Persistence contract for [`AppSettings`].
pub trait SettingsStore: Send + Sync {
    /// Loads settings, returning defaults when no persisted data exists.
    ///
    /// # Errors
    ///
    /// Returns [`crate::DomainError::SettingsLoadFailed`] when persisted data is unreadable.
    fn load(&self) -> Result<AppSettings, crate::DomainError>;

    /// Persists the given settings.
    ///
    /// # Errors
    ///
    /// Returns [`crate::DomainError::SettingsSaveFailed`] when persistence fails.
    fn save(&self, settings: &AppSettings) -> Result<(), crate::DomainError>;
}
