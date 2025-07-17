# CHANGELOG

All notable changes to UrchinScreen (fork of FluffyDisplay) will be documented in this file.

---

## [1.0.0] - 2025-07-17 - Initial UrchinScreen Release

### Added
- **Rotation Menu System**: Hierarchical submenus under 'New' for creating displays with Standard (0°), 90° Clockwise, 180°, and 270° Clockwise orientations
- **Rotation-Aware Virtual Display Creation**: Width/height swapping for 90°/270° rotations to enable vertical display workflows
- **Two-Mac Workflow Support**: Designed specifically for creating vertical displays using Sidecar between two Macs
- **Comprehensive Documentation**: Added detailed workflow documentation, attribution, and setup instructions
- **180° Rotation Support**: Menu option and logging for 180° rotation (visual flip requires renderer implementation)

### Changed
- **Project Name**: Forked as UrchinScreen with proper attribution to original FluffyDisplay
- **Menu System**: Complete refactor from flat menu to hierarchical rotation-aware submenus
- **Display Creation**: Enhanced createVirtualDisplay to properly handle rotation parameters
- **Documentation**: Complete rewrite of README for UrchinScreen use cases and workflows

### Technical Improvements
- Restored width/height swapping logic for 90°/270° rotations
- Added rotation parameter throughout the codebase
- Improved display naming to include rotation information
- Enhanced copyright headers with proper attribution

---

## [Orig. Fork Point]: 67180e3 (2024-02-15)
- Forked from tml1024/FluffyDisplay main branch (latest upstream as of July 2025).

---

For a line-by-line view of all changes, see:
- [Compare view on GitHub](https://github.com/sliprub/UrchinScreen/compare/67180e3...main)
- Or view `FORK_DOCUMENTATION.md` for exact before/after code for each change.

---

**License:**
- This fork inherits and retains the Apache 2.0 license of the original project
- Major modifications copyright © 2025 sliprub and contributors (see code headers)
- All enhancements, build/deployment scripting, and documentation are also under Apache 2.0

