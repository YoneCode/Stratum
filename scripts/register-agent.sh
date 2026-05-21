#!/bin/bash
set -e

RPC="https://rpc.testnet.arc.network"
IDENTITY="0x8004A818BFB912233c491871b3d84c89A494BD9e"
DEPLOYER="0x057442C1788c349891F86C09050C8bC1dc68392B"
AGENT_URI="data:application/json;base64,ewogICJ0eXBlIjogImFnZW50IiwKICAibmFtZSI6ICJMZWdhbEJvdCB2MS4wIiwKICAiZGVzY3JpcHRpb24iOiAiQUkgbGVnYWwgcmVzZWFyY2ggYXNzaXN0YW50IOKAlCBhbmFseXNlcyBjYXNlIGxhdywgZHJhZnRzIG1lbW9zLCBjaGVja3MgcmVndWxhdG9yeSBjb21wbGlhbmNlLiBQb3dlcmVkIGJ5IFN0cmF0dW0gb24gQXJjLiIsCiAgImltYWdlIjogIiIsCiAgImVuZHBvaW50cyI6IFsKICAgIHsKICAgICAgIm5hbWUiOiAiQTJBIiwKICAgICAgImVuZHBvaW50IjogImh0dHBzOi8vc3RyYXR1bS5kZXYvYWdlbnRzL2xlZ2FsYm90L2EyYSIsCiAgICAgICJ2ZXJzaW9uIjogIjAuMy4wIgogICAgfQogIF0sCiAgIng0MDJTdXBwb3J0IjogZmFsc2UsCiAgImFjdGl2ZSI6IHRydWUsCiAgInJlZ2lzdHJhdGlvbnMiOiBbXSwKICAic3VwcG9ydGVkVHJ1c3QiOiBbCiAgICAicmVwdXRhdGlvbiIKICBdCn0K"

echo "=== Registering LegalBot on ERC-8004 Identity Registry ==="
echo "RPC: $RPC"
echo "Identity: $IDENTITY"
echo "Deployer: $DEPLOYER"
echo ""

cast send "$IDENTITY" "register(string)" "$AGENT_URI" \
  --rpc-url "$RPC" \
  --account stratum-deployer \
  --from "$DEPLOYER"
