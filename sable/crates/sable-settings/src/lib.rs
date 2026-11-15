//! Settings shared by the SableOS Native shell, its daemons and the Settings app.
//!
//! One crate owns every schema so that `sable-inputd`, the Flow gesture engine and
//! Settings agree on keys and defaults. Device defaults live in
//! `sable/device/<device>/*.toml`; a missing field takes the default below.

use serde::{Deserialize, Serialize};

/// Error from reading or checking a settings file.
#[derive(Debug, PartialEq)]
pub enum SettingsError {
    /// The text is not valid TOML for the schema.
    Parse(String),
    /// A value is outside its allowed range.
    Invalid {
        /// The settings field that failed.
        field: &'static str,
        /// Why the value was refused.
        reason: &'static str,
    },
}

impl std::fmt::Display for SettingsError {
    fn fmt(&self, f: &mut std::fmt::Formatter<'_>) -> std::fmt::Result {
        match self {
            Self::Parse(msg) => write!(f, "cannot parse settings: {msg}"),
            Self::Invalid { field, reason } => write!(f, "{field}: {reason}"),
        }
    }
}

impl std::error::Error for SettingsError {}

/// Thresholds for the Flow gesture engine (`flow.toml`).
///
/// Sizes are density-independent units; fractions are of the screen height or
/// width, so the same file works at 720x720 and at 1440x1440.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct FlowConfig {
    /// Width of the touch zone along each screen edge, in dp.
    pub edge_zone_dp: f32,
    /// Upward travel, as a fraction of screen height, after which release minimises the app.
    pub minimise_fraction: f32,
    /// Sideways travel, as a fraction of screen width, after which release opens the Hub.
    pub hub_commit_fraction: f32,
}

impl Default for FlowConfig {
    fn default() -> Self {
        Self {
            edge_zone_dp: 16.0,
            minimise_fraction: 0.15,
            hub_commit_fraction: 0.5,
        }
    }
}

impl FlowConfig {
    /// Parses `flow.toml` and checks every value.
    pub fn from_toml(text: &str) -> Result<Self, SettingsError> {
        let config: Self = toml::from_str(text).map_err(|e| SettingsError::Parse(e.to_string()))?;
        config.validate()?;
        Ok(config)
    }

    /// Checks that every value is in range.
    pub fn validate(&self) -> Result<(), SettingsError> {
        if !(4.0..=64.0).contains(&self.edge_zone_dp) {
            return Err(SettingsError::Invalid {
                field: "edge_zone_dp",
                reason: "must be 4 to 64 dp",
            });
        }
        if !(0.05..=0.5).contains(&self.minimise_fraction) {
            return Err(SettingsError::Invalid {
                field: "minimise_fraction",
                reason: "must be 0.05 to 0.5",
            });
        }
        if !(0.2..=0.9).contains(&self.hub_commit_fraction) {
            return Err(SettingsError::Invalid {
                field: "hub_commit_fraction",
                reason: "must be 0.2 to 0.9",
            });
        }
        Ok(())
    }
}

/// What a key does, as the shell's key router understands it.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(rename_all = "kebab-case")]
pub enum KeyAction {
    /// Answer a ringing call; otherwise open Phone.
    AnswerOrPhone,
    /// End a call; otherwise go to Frames.
    EndOrFrames,
    /// Back; at an app's root, minimise to Frames; close a menu.
    Back,
    /// The focused app's action menu.
    ActionMenu,
    /// The focused app's application menu.
    AppMenu,
    /// The power menu.
    PowerMenu,
    /// Voice dialling.
    VoiceDial,
    /// Nothing.
    None,
}

/// Press and hold meanings for one physical key.
#[derive(Debug, Clone, Copy, PartialEq, Eq, Serialize, Deserialize)]
#[serde(deny_unknown_fields)]
pub struct KeyBinding {
    /// Meaning of a short press.
    pub press: KeyAction,
    /// Meaning of a press held longer than `hold_ms`.
    pub hold: KeyAction,
}

/// The phone keys (`keys.toml`). Defaults follow the BlackBerry Classic table in
/// the BB10 UI guidelines; a device file overrides what differs.
#[derive(Debug, Clone, PartialEq, Serialize, Deserialize)]
#[serde(default, deny_unknown_fields)]
pub struct KeysConfig {
    /// How long a press lasts before it counts as a hold, in milliseconds.
    pub hold_ms: u32,
    /// The green Call key.
    pub call: KeyBinding,
    /// The Menu (BlackBerry) key.
    pub menu: KeyBinding,
    /// The Back key.
    pub back: KeyBinding,
    /// The red End key.
    pub end: KeyBinding,
}

impl Default for KeysConfig {
    fn default() -> Self {
        Self {
            hold_ms: 500,
            call: KeyBinding {
                press: KeyAction::AnswerOrPhone,
                hold: KeyAction::VoiceDial,
            },
            menu: KeyBinding {
                press: KeyAction::ActionMenu,
                hold: KeyAction::AppMenu,
            },
            back: KeyBinding {
                press: KeyAction::Back,
                hold: KeyAction::None,
            },
            end: KeyBinding {
                press: KeyAction::EndOrFrames,
                hold: KeyAction::PowerMenu,
            },
        }
    }
}

impl KeysConfig {
    /// Parses `keys.toml` and checks every value.
    pub fn from_toml(text: &str) -> Result<Self, SettingsError> {
        let config: Self = toml::from_str(text).map_err(|e| SettingsError::Parse(e.to_string()))?;
        config.validate()?;
        Ok(config)
    }

    /// Checks that every value is in range, and that the power menu stays reachable.
    pub fn validate(&self) -> Result<(), SettingsError> {
        if !(200..=2000).contains(&self.hold_ms) {
            return Err(SettingsError::Invalid {
                field: "hold_ms",
                reason: "must be 200 to 2000 ms",
            });
        }
        let reachable = [self.call, self.menu, self.back, self.end]
            .iter()
            .any(|b| b.press == KeyAction::PowerMenu || b.hold == KeyAction::PowerMenu);
        if !reachable {
            return Err(SettingsError::Invalid {
                field: "keys",
                reason: "one key must open the power menu",
            });
        }
        Ok(())
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn empty_files_give_defaults() {
        assert_eq!(FlowConfig::from_toml(""), Ok(FlowConfig::default()));
        assert_eq!(KeysConfig::from_toml(""), Ok(KeysConfig::default()));
    }

    #[test]
    fn device_file_overrides_one_field() {
        let flow = FlowConfig::from_toml("minimise_fraction = 0.2\n");
        assert_eq!(flow.map(|f| f.minimise_fraction), Ok(0.2));
    }

    #[test]
    fn out_of_range_is_refused() {
        let err = FlowConfig::from_toml("edge_zone_dp = 100.0\n");
        assert!(matches!(
            err,
            Err(SettingsError::Invalid {
                field: "edge_zone_dp",
                ..
            })
        ));
    }

    #[test]
    fn unknown_field_is_refused() {
        assert!(matches!(
            FlowConfig::from_toml("edge = 3\n"),
            Err(SettingsError::Parse(_))
        ));
    }

    #[test]
    fn end_key_hold_opens_power_menu_by_default() {
        assert_eq!(KeysConfig::default().end.hold, KeyAction::PowerMenu);
    }

    #[test]
    fn power_menu_must_stay_reachable() {
        let text = "[end]\npress = \"end-or-frames\"\nhold = \"none\"\n";
        let err = KeysConfig::from_toml(text);
        assert!(matches!(
            err,
            Err(SettingsError::Invalid { field: "keys", .. })
        ));
    }

    #[test]
    fn shipped_q25_files_are_valid() {
        let flow = include_str!("../../../device/zinwa-q25/flow.toml");
        let keys = include_str!("../../../device/zinwa-q25/keys.toml");
        assert!(FlowConfig::from_toml(flow).is_ok());
        assert!(KeysConfig::from_toml(keys).is_ok());
    }
}
