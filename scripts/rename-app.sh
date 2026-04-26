#!/usr/bin/env bash
# Rebrand this boilerplate for a new app.
#
# Usage:
#   ./scripts/rename-app.sh --bundle-id com.company.myapp --name "My App"
#   ./scripts/rename-app.sh --bundle-id com.company.myapp --name "My App" --version 1.0.0
#   ./scripts/rename-app.sh --help
#
# What it updates in project.pbxproj:
#   - PRODUCT_BUNDLE_IDENTIFIER (main target, Tests, UITests)
#   - INFOPLIST_KEY_CFBundleDisplayName (app display name on home screen)
#   - MARKETING_VERSION (if --version provided)
#
# After running: open Xcode, rename the target and scheme manually if desired.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$(dirname "$SCRIPT_DIR")"
PBXPROJ="$REPO_ROOT/swiftui_boilerplate.xcodeproj/project.pbxproj"

OLD_BUNDLE_ID="com.nebiberke.swiftui-boilerplate"
OLD_BUNDLE_TESTS="${OLD_BUNDLE_ID}Tests"
OLD_BUNDLE_UITESTS="${OLD_BUNDLE_ID}UITests"

# Parse args
bundle_id=""
display_name=""
version=""
help=false

while [[ $# -gt 0 ]]; do
  case "$1" in
    --bundle-id) bundle_id="$2"; shift 2 ;;
    --name)      display_name="$2"; shift 2 ;;
    --version)   version="$2"; shift 2 ;;
    --help|-h)   help=true; shift ;;
    *) echo "Unknown argument: $1" >&2; exit 1 ;;
  esac
done

if $help; then
  cat <<EOF
Rebrand the SwiftUI boilerplate.

Required:
  --bundle-id com.company.myapp   iOS/macOS bundle identifier (reverse DNS)
  --name "My App"                 Display name shown on home screen

Optional:
  --version 1.0.0                 Marketing version (default: unchanged)

Example:
  ./scripts/rename-app.sh --bundle-id com.acme.superapp --name "Super App"

After running:
  1. Create swiftui_boilerplate/Core/Config/APIConfig.swift from the .sample file
  2. Open Xcode — rename the target and scheme if desired (Product → Scheme → Manage Schemes)
  3. Remove the Supabase Swift Package (File → Packages → Reset Package Caches, then
     remove supabase-swift from project settings → Package Dependencies)
EOF
  exit 0
fi

if [[ -z "$bundle_id" || -z "$display_name" ]]; then
  echo "Error: --bundle-id and --name are required." >&2
  echo "Run with --help for usage." >&2
  exit 1
fi

if [[ ! -f "$PBXPROJ" ]]; then
  echo "Error: project.pbxproj not found at $PBXPROJ" >&2
  echo "Run from the repo root or swiftui_boilerplate directory." >&2
  exit 1
fi

new_bundle_tests="${bundle_id}Tests"
new_bundle_uitests="${bundle_id}UITests"

echo "Updating project.pbxproj..."

# Use Python 3 (available on macOS via Xcode CLI tools) for reliable text substitution.
python3 - "$PBXPROJ" "$OLD_BUNDLE_ID" "$bundle_id" \
               "$OLD_BUNDLE_TESTS" "$new_bundle_tests" \
               "$OLD_BUNDLE_UITESTS" "$new_bundle_uitests" \
               "$display_name" "${version:-}" <<'PYEOF'
import sys, re

pbxproj_path, old_id, new_id, old_tests, new_tests, old_ui, new_ui, name, ver = sys.argv[1:]

with open(pbxproj_path, 'r', encoding='utf-8') as f:
    content = f.read()

# Replace bundle identifiers
content = content.replace(f'PRODUCT_BUNDLE_IDENTIFIER = "{old_ui}"', f'PRODUCT_BUNDLE_IDENTIFIER = "{new_ui}"')
content = content.replace(f'PRODUCT_BUNDLE_IDENTIFIER = "{old_tests}"', f'PRODUCT_BUNDLE_IDENTIFIER = "{new_tests}"')
content = content.replace(f'PRODUCT_BUNDLE_IDENTIFIER = "{old_id}"', f'PRODUCT_BUNDLE_IDENTIFIER = "{new_id}"')

# Also handle unquoted form
content = content.replace(f'PRODUCT_BUNDLE_IDENTIFIER = {old_ui}', f'PRODUCT_BUNDLE_IDENTIFIER = {new_ui}')
content = content.replace(f'PRODUCT_BUNDLE_IDENTIFIER = {old_tests}', f'PRODUCT_BUNDLE_IDENTIFIER = {new_tests}')
content = content.replace(f'PRODUCT_BUNDLE_IDENTIFIER = {old_id}', f'PRODUCT_BUNDLE_IDENTIFIER = {new_id}')

# Set / update display name — add after each GENERATE_INFOPLIST_FILE = YES;
if 'INFOPLIST_KEY_CFBundleDisplayName' in content:
    content = re.sub(
        r'INFOPLIST_KEY_CFBundleDisplayName = "[^"]*";',
        f'INFOPLIST_KEY_CFBundleDisplayName = "{name}";',
        content
    )
else:
    content = content.replace(
        'GENERATE_INFOPLIST_FILE = YES;',
        f'GENERATE_INFOPLIST_FILE = YES;\n\t\t\t\tINFOPLIST_KEY_CFBundleDisplayName = "{name}";'
    )

# Update marketing version if requested
if ver:
    content = re.sub(r'MARKETING_VERSION = [^;]+;', f'MARKETING_VERSION = {ver};', content)

with open(pbxproj_path, 'w', encoding='utf-8') as f:
    f.write(content)

print(f"  Bundle ID:    {new_id}")
print(f"  Display name: {name}")
if ver:
    print(f"  Version:      {ver}")
PYEOF

echo ""
echo "Done. Next steps:"
echo "  1. cp swiftui_boilerplate/Core/Config/APIConfig.swift.sample \\"
echo "        swiftui_boilerplate/Core/Config/APIConfig.swift"
echo "     (then fill in your backend URL)"
echo "  2. Open Xcode and remove the Supabase package dependency:"
echo "     Project settings → Package Dependencies → remove supabase-swift"
echo "  3. Rename the Xcode target/scheme if desired (Xcode GUI only)"
