#!/bin/bash

# =============================================================================
# Create and publish Dimension C-137 and Pickle Rick plans only
# =============================================================================
# Requires: meter "api" and features "api", "monthly_fee", plus 6 R&M themed
# features (created by this script if missing). C-137 has 4 flat_fee add-ons,
# Pickle Rick has 6.
#
# Usage:
#   ./scripts/create-c137-and-pickle-rick-plans.sh
# =============================================================================

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

BASE_URL="https://dev.zuplo.com"

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
    response=$(curl -s -w "\n%{http_code}" -X "$method" "${BASE_URL}${endpoint}" \
        -H "Authorization: Bearer ${ZUPLO_API_KEY}" \
        -H "Content-Type: application/json" \
        -d "$data")
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

# =============================================================================
# Input
# =============================================================================

echo -e "${BLUE}"
echo "============================================="
echo "  Create C-137 & Pickle Rick Plans"
echo "============================================="
echo -e "${NC}"

prompt ZUPLO_API_KEY "Zuplo API key" "$ZUPLO_API_KEY"
prompt ZUPLO_BUCKET_ID "Bucket ID" "$ZUPLO_BUCKET_ID"

[ -z "$ZUPLO_API_KEY" ] && { print_error "ZUPLO_API_KEY required"; exit 1; }
[ -z "$ZUPLO_BUCKET_ID" ] && { print_error "ZUPLO_BUCKET_ID required"; exit 1; }

# =============================================================================
# Ensure Rick & Morty themed features exist (ignore if already exist)
# =============================================================================

print_step "Ensuring R&M features exist..."
set +e
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "portal_gun_access", "name": "Portal Gun Access"}' "portal_gun_access" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "dimension_hopping_pass", "name": "Dimension Hopping Pass"}' "dimension_hopping_pass" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "plumbus_package", "name": "Plumbus Package"}' "plumbus_package" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "interdimensional_cable", "name": "Interdimensional Cable"}' "interdimensional_cable" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "pickle_enhancement_serum", "name": "Pickle Enhancement Serum"}' "pickle_enhancement_serum" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "szechuan_sauce_access", "name": "Szechuan Sauce Access"}' "szechuan_sauce_access" > /dev/null
set -e

# =============================================================================
# Create Dimension C-137 plan
# =============================================================================

print_step "Creating Dimension C-137 plan..."

C137_RESPONSE=$(api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans" '{
    "billingCadence": "P1M",
    "currency": "USD",
    "description": "Rick'\''s home dimension - 1000 requests per month with overages",
    "key": "dimension_c137",
    "metadata": {
        "zuplo_plan_order": "1"
    },
    "name": "Dimension C-137",
    "proRatingConfig": {
        "enabled": false,
        "mode": "prorate_prices"
    },
    "phases": [
        {
            "duration": null,
            "key": "default",
            "name": "Default",
            "rateCards": [
                {
                    "billingCadence": "P1M",
                    "featureKey": "monthly_fee",
                    "key": "monthly_fee",
                    "name": "Monthly Fee",
                    "price": {
                        "amount": "9.99",
                        "paymentTerm": "in_advance",
                        "type": "flat"
                    },
                    "type": "flat_fee"
                },
                {
                    "billingCadence": "P1M",
                    "entitlementTemplate": {
                        "isSoftLimit": true,
                        "issueAfterReset": 1000,
                        "preserveOverageAtReset": false,
                        "type": "metered",
                        "usagePeriod": "P1M"
                    },
                    "featureKey": "api",
                    "key": "api",
                    "name": "api",
                    "price": {
                        "mode": "graduated",
                        "tiers": [
                            {
                                "flatPrice": {
                                    "amount": "0",
                                    "type": "flat"
                                },
                                "unitPrice": null,
                                "upToAmount": "1000"
                            },
                            {
                                "flatPrice": null,
                                "unitPrice": {
                                    "amount": "0.10",
                                    "type": "unit"
                                }
                            }
                        ],
                        "type": "tiered"
                    },
                    "type": "usage_based"
                },
                {"type": "flat_fee", "key": "portal_gun_access", "name": "Portal Gun Access", "featureKey": "portal_gun_access", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
                {"type": "flat_fee", "key": "dimension_hopping_pass", "name": "Dimension Hopping Pass", "featureKey": "dimension_hopping_pass", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
                {"type": "flat_fee", "key": "plumbus_package", "name": "Plumbus Package", "featureKey": "plumbus_package", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
                {"type": "flat_fee", "key": "interdimensional_cable", "name": "Interdimensional Cable", "featureKey": "interdimensional_cable", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}}
            ]
        }
    ]
}' "Creating Dimension C-137 plan")

C137_PLAN_ID=$(echo "$C137_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$C137_PLAN_ID" ] && print_success "Dimension C-137 plan created (ID: $C137_PLAN_ID)" || { print_error "Dimension C-137 plan creation failed"; exit 1; }

# =============================================================================
# Create Pickle Rick plan
# =============================================================================

print_step "Creating Pickle Rick plan..."

PICKLE_RICK_RESPONSE=$(api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans" '{
    "billingCadence": "P1M",
    "currency": "USD",
    "description": "Ultimate transformation - 10000 requests per month with overages",
    "key": "pickle_rick",
    "metadata": {
        "zuplo_plan_order": "3"
    },
    "name": "Pickle Rick",
    "proRatingConfig": {
        "enabled": false,
        "mode": "prorate_prices"
    },
    "phases": [
        {
            "duration": null,
            "key": "default",
            "name": "Default",
            "rateCards": [
                {
                    "billingCadence": "P1M",
                    "featureKey": "monthly_fee",
                    "key": "monthly_fee",
                    "name": "Monthly Fee",
                    "price": {
                        "amount": "29.99",
                        "paymentTerm": "in_advance",
                        "type": "flat"
                    },
                    "type": "flat_fee"
                },
                {
                    "billingCadence": "P1M",
                    "entitlementTemplate": {
                        "isSoftLimit": true,
                        "issueAfterReset": 10000,
                        "preserveOverageAtReset": false,
                        "type": "metered",
                        "usagePeriod": "P1M"
                    },
                    "featureKey": "api",
                    "key": "api",
                    "name": "api",
                    "price": {
                        "mode": "graduated",
                        "tiers": [
                            {
                                "flatPrice": {
                                    "amount": "0",
                                    "type": "flat"
                                },
                                "unitPrice": null,
                                "upToAmount": "10000"
                            },
                            {
                                "flatPrice": null,
                                "unitPrice": {
                                    "amount": "0.01",
                                    "type": "unit"
                                }
                            }
                        ],
                        "type": "tiered"
                    },
                    "type": "usage_based"
                },
                {"type": "flat_fee", "key": "portal_gun_access", "name": "Portal Gun Access", "featureKey": "portal_gun_access", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
                {"type": "flat_fee", "key": "dimension_hopping_pass", "name": "Dimension Hopping Pass", "featureKey": "dimension_hopping_pass", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
                {"type": "flat_fee", "key": "plumbus_package", "name": "Plumbus Package", "featureKey": "plumbus_package", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
                {"type": "flat_fee", "key": "interdimensional_cable", "name": "Interdimensional Cable", "featureKey": "interdimensional_cable", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
                {"type": "flat_fee", "key": "pickle_enhancement_serum", "name": "Pickle Enhancement Serum", "featureKey": "pickle_enhancement_serum", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}},
                {"type": "flat_fee", "key": "szechuan_sauce_access", "name": "Szechuan Sauce Access", "featureKey": "szechuan_sauce_access", "billingCadence": null, "price": null, "entitlementTemplate": {"type": "boolean", "config": true}}
            ]
        }
    ]
}' "Creating Pickle Rick plan")

PICKLE_RICK_PLAN_ID=$(echo "$PICKLE_RICK_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
[ -n "$PICKLE_RICK_PLAN_ID" ] && print_success "Pickle Rick plan created (ID: $PICKLE_RICK_PLAN_ID)" || { print_error "Pickle Rick plan creation failed"; exit 1; }

# =============================================================================
# Publish both plans
# =============================================================================

print_step "Publishing plans..."

api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans/${C137_PLAN_ID}/publish" '{}' "Publishing Dimension C-137 plan" > /dev/null
print_success "Dimension C-137 plan published"

api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans/${PICKLE_RICK_PLAN_ID}/publish" '{}' "Publishing Pickle Rick plan" > /dev/null
print_success "Pickle Rick plan published"

echo -e "\n${GREEN}Done.${NC}"
