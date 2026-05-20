//! Slint application entry point.

#![allow(missing_docs)] // Slint-generated UI modules do not carry documentation.
#![allow(clippy::unwrap_used, clippy::expect_used)] // Slint runtime uses unwrap internally.

use anyhow::{Context, Result};
use core_domain::{Storage, User, UserId, UserRegistrationValidator};
use infrastructure::InMemoryStorage;
use slint::ComponentHandle;

slint::include_modules!();

/// Runs the Slint UI application.
fn main() -> Result<()> {
    let ui = AppWindow::new().context("failed to create Slint window")?;
    let storage = InMemoryStorage::new();

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
