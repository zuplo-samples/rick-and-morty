#!/bin/bash

# =============================================================================
# Zuplo Monetization Setup Script
# =============================================================================
# This script sets up meters, features, plans, and Stripe integration for
# Zuplo's monetization feature.
#
# Usage:
#   ./setup-monetization.sh
#
# The script will prompt you for the required values.
# =============================================================================

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Base URL for the Zuplo API
BASE_URL="https://dev.zuplo.com"

# =============================================================================
# Helper Functions
# =============================================================================

print_step() {
    echo -e "\n${BLUE}==>${NC} $1"
}

print_success() {
    echo -e "${GREEN}✓${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

print_error() {
    echo -e "${RED}✗${NC} $1"
}

# Prompt for input with a default value
prompt() {
    local var_name=$1
    local prompt_text=$2
    local default_value=$3
    local is_secret=$4

    if [ -n "$default_value" ]; then
        prompt_text="${prompt_text} [${default_value}]"
    fi

    echo -en "${CYAN}?${NC} ${prompt_text}: "

    if [ "$is_secret" = "true" ]; then
        read -s value
        echo ""
    else
        read value
    fi

    # Use default if empty
    if [ -z "$value" ] && [ -n "$default_value" ]; then
        value="$default_value"
    fi

    eval "$var_name=\"$value\""
}

# Make an API call and extract the ID from the response
# Progress message goes to stderr so $(api_call ...) captures only the JSON response
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

    # Check for HTTP errors or error in response body
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
# Welcome & Input Collection
# =============================================================================

echo -e "${BLUE}"
echo "============================================="
echo "  Zuplo Monetization Setup"
echo "============================================="
echo -e "${NC}"
echo "This script will set up meters, features, plans, and Stripe"
echo "integration for your Zuplo project."
echo ""
echo "You'll need:"
echo "  • Your Zuplo API key (from portal.zuplo.com)"
echo "  • Your bucket ID (from your project settings)"
echo "  • Your Stripe test key (sk_test_...)"
echo ""

# Prompt for values (use env vars as defaults if set)
prompt ZUPLO_API_KEY "Enter your Zuplo API key" "$ZUPLO_API_KEY" "true"

if [ -z "$ZUPLO_API_KEY" ]; then
    print_error "Zuplo API key is required"
    exit 1
fi

prompt ZUPLO_BUCKET_ID "Enter your bucket ID" "$ZUPLO_BUCKET_ID"

if [ -z "$ZUPLO_BUCKET_ID" ]; then
    print_error "Bucket ID is required"
    exit 1
fi

prompt STRIPE_KEY "Enter your Stripe secret key" "$STRIPE_KEY" "true"

if [ -z "$STRIPE_KEY" ]; then
    print_error "Stripe key is required"
    exit 1
fi

# Warn if not using a test Stripe key
if [[ ! "$STRIPE_KEY" == sk_test_* ]]; then
    echo ""
    print_warning "Your Stripe key doesn't start with 'sk_test_'."
    print_warning "Are you sure you want to use a live key?"
    echo -en "${CYAN}?${NC} Continue? (y/N): "
    read -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

# Confirm before proceeding
echo ""
echo -e "${YELLOW}Ready to set up monetization with:${NC}"
echo "  Bucket ID: $ZUPLO_BUCKET_ID"
echo "  Stripe Key: ${STRIPE_KEY:0:12}..."
echo ""
echo -en "${CYAN}?${NC} Proceed with setup? (Y/n): "
read -n 1 -r
echo
if [[ $REPLY =~ ^[Nn]$ ]]; then
    echo "Setup cancelled."
    exit 0
fi

# =============================================================================
# Step 1: Create Meter
# =============================================================================

print_step "Creating meter..."

METER_RESPONSE=$(api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/meters" '{
    "slug": "api",
    "name": "API",
    "description": "API Calls",
    "eventType": "api",
    "aggregation": "SUM",
    "valueProperty": "$.total"
}' "Creating 'api' meter")

print_success "Meter created"

# =============================================================================
# Step 2: Create Features
# =============================================================================

print_step "Creating features..."

# API Feature (linked to meter)
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{
    "key": "api",
    "name": "API",
    "meterSlug": "api"
}' "Creating 'api' feature" > /dev/null

print_success "API feature created"

# Monthly Fee Feature
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{
    "key": "monthly_fee",
    "name": "Monthly Fee"
}' "Creating 'monthly_fee' feature" > /dev/null

print_success "Monthly Fee feature created"

# Metadata Support Feature
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{
    "key": "metadata_support",
    "name": "Metadata Support"
}' "Creating 'metadata_support' feature" > /dev/null

print_success "Metadata Support feature created"

# Rick & Morty themed flat_fee features (used in C-137 and Pickle Rick plans)
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "portal_gun_access", "name": "Portal Gun Access"}' "Creating 'portal_gun_access' feature" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "dimension_hopping_pass", "name": "Dimension Hopping Pass"}' "Creating 'dimension_hopping_pass' feature" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "plumbus_package", "name": "Plumbus Package"}' "Creating 'plumbus_package' feature" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "interdimensional_cable", "name": "Interdimensional Cable"}' "Creating 'interdimensional_cable' feature" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "pickle_enhancement_serum", "name": "Pickle Enhancement Serum"}' "Creating 'pickle_enhancement_serum' feature" > /dev/null
api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/features" '{"key": "szechuan_sauce_access", "name": "Szechuan Sauce Access"}' "Creating 'szechuan_sauce_access' feature" > /dev/null

print_success "Rick & Morty themed features created"

# =============================================================================
# Step 3: Create Plans
# =============================================================================

print_step "Creating plans..."

# Don't exit on api_call failure so we create all three plans (set -e would stop after first failure)
set +e

# Dimension C-137 Plan
DEVELOPER_RESPONSE=$(api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans" '{
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
}' "Creating Developer plan")

# Cronenberg Plan
PRO_RESPONSE=$(api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans" '{
    "billingCadence": "P1M",
    "currency": "USD",
    "description": "Mutated reality with enhanced capabilities - 5000 requests per month with overages",
    "key": "cronenberg",
    "metadata": {
        "zuplo_plan_order": "2"
    },
    "name": "Cronenberg",
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
                        "amount": "19.99",
                        "paymentTerm": "in_advance",
                        "type": "flat"
                    },
                    "type": "flat_fee"
                },
                {
                    "billingCadence": "P1M",
                    "entitlementTemplate": {
                        "isSoftLimit": true,
                        "issueAfterReset": 5000,
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
                                "upToAmount": "5000"
                            },
                            {
                                "flatPrice": null,
                                "unitPrice": {
                                    "amount": "0.05",
                                    "type": "unit"
                                }
                            }
                        ],
                        "type": "tiered"
                    },
                    "type": "usage_based"
                },
                {
                    "type": "flat_fee",
                    "key": "metadata_support",
                    "name": "Metadata Support",
                    "featureKey": "metadata_support",
                    "billingCadence": null,
                    "price": null,
                    "entitlementTemplate": {
                        "type": "boolean",
                        "config": true
                    }
                }
            ]
        }
    ]
}' "Creating Pro plan")

# Pickle Rick Plan
BUSINESS_RESPONSE=$(api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans" '{
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
}' "Creating Business plan")

set -e

# Extract plan IDs (only from successful responses)
DEVELOPER_PLAN_ID=$(echo "$DEVELOPER_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
PRO_PLAN_ID=$(echo "$PRO_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)
BUSINESS_PLAN_ID=$(echo "$BUSINESS_RESPONSE" | grep -o '"id":"[^"]*"' | head -1 | cut -d'"' -f4)

[ -n "$DEVELOPER_PLAN_ID" ] && print_success "Dimension C-137 plan created (ID: $DEVELOPER_PLAN_ID)" || { print_error "Dimension C-137 plan creation failed"; echo "$DEVELOPER_RESPONSE" | grep -q . && echo "$DEVELOPER_RESPONSE" | sed 's/^/  /' >&2; }
[ -n "$PRO_PLAN_ID" ] && print_success "Cronenberg plan created (ID: $PRO_PLAN_ID)" || { print_error "Cronenberg plan creation failed"; echo "$PRO_RESPONSE" | grep -q . && echo "$PRO_RESPONSE" | sed 's/^/  /' >&2; }
[ -n "$BUSINESS_PLAN_ID" ] && print_success "Pickle Rick plan created (ID: $BUSINESS_PLAN_ID)" || { print_error "Pickle Rick plan creation failed"; echo "$BUSINESS_RESPONSE" | grep -q . && echo "$BUSINESS_RESPONSE" | sed 's/^/  /' >&2; }

# =============================================================================
# Step 4: Publish Plans
# =============================================================================

print_step "Publishing plans..."

if [ -n "$DEVELOPER_PLAN_ID" ]; then
  api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans/${DEVELOPER_PLAN_ID}/publish" '{}' "Publishing Dimension C-137 plan" > /dev/null
  print_success "Dimension C-137 plan published"
fi
if [ -n "$PRO_PLAN_ID" ]; then
  api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans/${PRO_PLAN_ID}/publish" '{}' "Publishing Cronenberg plan" > /dev/null
  print_success "Cronenberg plan published"
fi
if [ -n "$BUSINESS_PLAN_ID" ]; then
  api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/plans/${BUSINESS_PLAN_ID}/publish" '{}' "Publishing Pickle Rick plan" > /dev/null
  print_success "Pickle Rick plan published"
fi

# =============================================================================
# Step 5: Connect Stripe
# =============================================================================

print_step "Connecting Stripe..."

api_call POST "/v3/metering/${ZUPLO_BUCKET_ID}/setup/stripe" "{
    \"apiKey\": \"${STRIPE_KEY}\",
    \"name\": \"Monetization Getting Started\"
}" "Setting up Stripe integration" > /dev/null

print_success "Stripe connected"

# =============================================================================
# Done!
# =============================================================================

echo -e "\n${GREEN}"
echo "============================================="
echo "  Setup Complete!"
echo "============================================="
echo -e "${NC}"
echo "Your monetization setup is ready. Here's what was created:"
echo ""
echo "  Meter:"
echo "    • api (tracks API calls)"
echo ""
echo "  Features:"
echo "    • api (usage-based, linked to meter)"
echo "    • monthly_fee (flat rate)"
echo "    • metadata_support (boolean)"
echo ""
echo "  Plans:"
echo "    • Dimension C-137: \$9.99/mo, 1,000 requests, \$0.10 overage"
echo "    • Cronenberg: \$19.99/mo, 5,000 requests, \$0.05 overage"
echo "    • Pickle Rick: \$29.99/mo, 10,000 requests, \$0.01 overage"
echo ""
echo -e "${YELLOW}Next steps:${NC}"
echo "  1. Add the monetization policy to your routes (see README)"
echo "  2. Push your changes to trigger a deployment"
echo "  3. Have a user sign up and subscribe to a plan"
echo ""