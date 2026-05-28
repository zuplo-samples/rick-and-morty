#!/bin/bash

# =============================================================================
# Update Cronenberg plan with Rick & Morty themed flat_fee features
# =============================================================================
# Fetches the existing Cronenberg plan, adds 4 R&M features to it (Portal Gun
# Access, Dimension Hopping Pass, Plumbus Package, Interdimensional Cable),
# and updates the plan via the API. Requires: jq, meter "api", features "api",
# "monthly_fee", "metadata_support", and the 4 R&M features (created if missing).
#
# Usage:
#   ./scripts/update-cronenberg-plan.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

BASE_URL="https://dev.zuplo.com"

if ! command -v jq >/dev/null 2>&1; then
    echo -e "${RED}Error: jq is required. Install with: brew install jq${NC}" >&2
    exit 1
fi

print_step() { echo -e "\n${BLUE}==>${NC} $1"; }
print_success() { echo -e "${GREEN}✓${NC} $1"; }
print_error() { echo -e "${RED}✗${NC} $1"; }

prompt() {
    local var_name=$1
    local prompt_text=$2
    local default_value=$3
    echo -en "${CYAN}?${NC} ${prompt_text}"
    [ -n "$default_value" ] && echo -n " [${default_value}]"
    echo -n ": "
    read value
    [ -z "$value" ] && [ -n "$default_value" ] && value="$default_value"
    eval "$var_name=\"$value\""
}

api_call() {
    local method=$1
    local endpoint=$2
    local data=$3
    local description=$4
    echo -e "  ${description}..." >&2
    if [ "$method" = "GET" ]; then
        response=$(curl -s -w "\n%{http_code}" -X "$method" "${BASE_URL}${endpoint}" \
            -H "Authorization: Bearer ${ZUPLO_API_KEY}" \
            -H "Content-Type: application/json")
    else
        response=$(curl -s -w "\n%{http_code}" -X "$method" "${BASE_URL}${endpoint}" \
            -H "Authorization: Bearer ${ZUPLO_API_KEY}" \
            -H "Content-Type: application/json" \
            -d "$data")
    fi
    http_code=$(echo "$response" | tail -n1)
    response=$(echo "$response" | sed '$d')

    if [ "$http_code" -ge 400 ] 2>/dev/null || echo "$response" | grep -q '"error"'; then
        echo -e "\n${RED}━━━ API Error ━━━${NC}" >&2
        print_error "Step: ${description}" >&2
        print_error "Endpoint: ${method} ${endpoint}" >&2
        [ -n "$http_code" ] && print_error "HTTP status: ${http_code}" >&2
        echo -e "${RED}Response body:${NC}" >&2
        echo "$response" | sed 's/^/  /' >&2
        echo -e "${RED}━━━━━━━━━━━━━━${NC}\n" >&2
        return 1
    fi
    echo "$response"
}

# JSON array of 4 R&M flat_fee rate cards to add
NEW_RATE_CARDS='[
  {"type": "flat_fee", "key": "portal_gun_access", "name": "Portal Gun Access", "featureKey": "portal_gun_access", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
  {"type": "flat_fee", "key": "dimension_hopping_pass", "name": "Dimension Hopping Pass", "featureKey": "dimension_hopping_pass", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
  {"type": "flat_fee", "key": "plumbus_package", "name": "Plumbus Package", "featureKey": "plumbus_package", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
  {"type": "flat_fee", "key": "interdimensional_cable", "name": "Interdimensional Cable", "featureKey": "interdimensional_cable", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}}
]'

# =============================================================================
# Input
# =============================================================================

echo -e "${BLUE}"
echo "============================================="
echo "  Update Cronenberg Plan"
echo "============================================="
echo -e "${NC}"

prompt ZUPLO_API_KEY "Zuplo API key" "$ZUPLO_API_KEY"
prompt ZUPLO_BUCKET_ID "Bucket ID" "$ZUPLO_BUCKET_ID"

[ -z "$ZUPLO_API_KEY" ] && { print_error "ZUPLO_API_KEY required"; exit 1; }
[ -z "$ZUPLO_BUCKET_ID" ] && { print_error "ZUPLO_BUCKET_ID required"; exit 1; }

# =============================================================================
# Ensure R&M features exist
# =============================================================================

print_step "Ensuring R&M features exist..."
set +e
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "portal_gun_access", "name": "Portal Gun Access"}' "portal_gun_access" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "dimension_hopping_pass", "name": "Dimension Hopping Pass"}' "dimension_hopping_pass" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "plumbus_package", "name": "Plumbus Package"}' "plumbus_package" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "interdimensional_cable", "name": "Interdimensional Cable"}' "interdimensional_cable" > /dev/null
set -e

# =============================================================================
# Find Cronenberg plan ID
# =============================================================================

print_step "Finding Cronenberg plan..."
PLANS_RESPONSE=$(api_call GET "/v3/metering/${ZUPLO_BUCKET_ID}/plans" "" "Listing plans")

# Support both array response and { "items": [...] }
CRONENBERG_PLAN_ID=$(echo "$PLANS_RESPONSE" | jq -r '
  (if type == "array" then . else (.items // .data // empty) end) // empty
  | if type == "array" then .[] else . end
  | select(.key == "cronenberg") | .id
' 2>/dev/null | head -1)

if [ -z "$CRONENBERG_PLAN_ID" ] || [ "$CRONENBERG_PLAN_ID" = "null" ]; then
    print_error "Cronenberg plan not found. Create it first with setup-monetization.sh"
    exit 1
fi

print_success "Found Cronenberg plan (ID: $CRONENBERG_PLAN_ID)"

# =============================================================================
# Get current plan and add new rate cards
# =============================================================================

print_step "Fetching current plan..."
PLAN_JSON=$(api_call GET "/v3/metering/${ZUPLO_BUCKET_ID}/plans/${CRONENBERG_PLAN_ID}" "" "Get plan")

# Add the 4 new rate cards only if not already present
EXISTING_KEYS=$(echo "$PLAN_JSON" | jq -r '.phases[0].rateCards | map(.key) | @json')
UPDATED_JSON=$(echo "$PLAN_JSON" | jq --argjson new "$NEW_RATE_CARDS" --argjson keys "$EXISTING_KEYS" '
  .phases[0].rateCards += ($new | map(select(.key as $k | ($keys | index($k)) == null)))
')

# Remove read-only fields that API might reject on PUT
UPDATED_JSON=$(echo "$UPDATED_JSON" | jq 'del(.["id"], .["createdAt"], .["updatedAt"], .["version"])' 2>/dev/null || echo "$UPDATED_JSON")

# =============================================================================
# Update plan
# =============================================================================

print_step "Updating Cronenberg plan with new features..."
api_call PUT "/v3/metering/${ZUPLO_BUCKET_ID}/plans/${CRONENBERG_PLAN_ID}" "$UPDATED_JSON" "Update plan" > /dev/null

print_success "Cronenberg plan updated with: Portal Gun Access, Dimension Hopping Pass, Plumbus Package, Interdimensional Cable"

echo -e "\n${GREEN}Done.${NC}"
