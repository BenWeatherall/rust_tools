//! Slint application entry point.

#![allow(missing_docs)] // Slint-generated UI modules do not carry documentation.
#![allow(clippy::unwrap_used, clippy::expect_used)] // Slint runtime uses unwrap internally.

use anyhow::{Context, Result};
use core_domain::{
    AppSettings, SettingsStore, Storage, User, UserId, UserRegistrationValidator, WindowGeometry,
};
use infrastructure::{InMemoryStorage, JsonSettingsStore};
use slint::{CloseRequestResponse, ComponentHandle, PhysicalPosition, PhysicalSize};
use std::sync::Arc;

slint::include_modules!();

/// Runs the Slint UI application.
fn main() -> Result<()> {
    let settings_store = Arc::new(JsonSettingsStore::from_default_path());
    let settings = settings_store
        .load()
        .context("failed to load application settings")?;

    let ui = AppWindow::new().context("failed to create Slint window")?;
    let storage = InMemoryStorage::new();

    schedule_apply_window_settings(ui.as_weak(), settings);

    ui.window().on_close_requested({
        let ui_handle = ui.as_weak();
        let settings_store = Arc::clone(&settings_store);
        move || handle_close_requested(settings_store.as_ref(), &ui_handle)
    });

    ui.on_request_exit({
        let ui_handle = ui.as_weak();
        move || {
            if let Some(ui) = ui_handle.upgrade() {
                ui.window().hide().ok();
            }
        }
    });

    ui.on_register_user({
        let ui_handle = ui.as_weak();
        move |display_name| {
            let ui_handle = ui_handle.clone();
            let result = register_user(&storage, display_name.as_str());
            if let Some(ui) = ui_handle.upgrade() {
                let message = match result {
                    Ok(user_id) => format!("Registered user: {user_id}"),
                    Err(error) => format!("Registration failed: {error}"),
                };
                ui.set_status_message(message.into());
            }
        }
    });

    ui.run().context("Slint event loop failed")?;
    Ok(())
}

fn register_user(storage: &InMemoryStorage, display_name: &str) -> Result<String> {
    UserRegistrationValidator::validate_display_name(display_name).context("validation failed")?;

    let user_id = UserId::new(format!("user-{display_name}")).context("invalid user id")?;
    let user = User::new(user_id.clone(), display_name.to_string());
    storage.save_user(&user).context("failed to persist user")?;

    Ok(user_id.as_str().to_string())
}

fn schedule_apply_window_settings(ui: slint::Weak<AppWindow>, settings: AppSettings) {
    slint::invoke_from_event_loop(move || {
        if let Some(ui) = ui.upgrade() {
            apply_window_settings(&ui, &settings);
        }
    })
    .context("failed to schedule window settings")
    .ok();
}

fn apply_window_settings(ui: &AppWindow, settings: &AppSettings) {
    let window = ui.window();
    let geometry = &settings.window;

    if geometry.maximized {
        window.set_maximized(true);
        return;
    }

    window.set_size(PhysicalSize::new(geometry.width, geometry.height));

    // Programmatic position restore is unavailable on some platforms (notably Wayland).
    if let (Some(x), Some(y)) = (geometry.position_x, geometry.position_y) {
        window.set_position(PhysicalPosition::new(x, y));
    }
}

/// Captures the current window geometry from the live UI.
#[must_use]
pub fn capture_window_settings(ui: &AppWindow) -> AppSettings {
    let window = ui.window();
    let size = window.size();
    let position = window.position();

    AppSettings {
        window: WindowGeometry {
            width: size.width,
            height: size.height,
            position_x: Some(position.x),
            position_y: Some(position.y),
            maximized: window.is_maximized(),
        },
    }
}

/// Persists the current window geometry from the live UI.
///
/// # Errors
///
/// Returns [`core_domain::DomainError`] when persistence fails.
pub fn persist_window_settings(
    store: &dyn SettingsStore,
    ui: &AppWindow,
) -> Result<(), core_domain::DomainError> {
    store.save(&capture_window_settings(ui))
}

fn handle_close_requested(
    store: &dyn SettingsStore,
    ui: &slint::Weak<AppWindow>,
) -> CloseRequestResponse {
    if let Some(ui) = ui.upgrade() {
        if let Err(error) = persist_window_settings(store, &ui) {
            eprintln!("failed to save settings on close: {error}");
        }
    }

    // Future: return `KeepWindowShown` when a confirm-before-close dialog rejects exit.
    CloseRequestResponse::HideWindow
}
