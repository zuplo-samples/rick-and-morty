import {
  RuntimeExtensions,
  StripeMonetizationPlugin,
  GoogleCloudLoggingPlugin,
  environment,
} from "@zuplo/runtime";

export function runtimeInit(runtime: RuntimeExtensions) {
  // Create the Stripe Plugin
  const stripe = new StripeMonetizationPlugin({
    webhooks: {
      signingSecret: environment.STRIPE_WEBHOOK_SIGNING_SECRET,
    },
    stripeSecretKey: environment.STRIPE_SECRET_KEY,
  });
  // Register the plugin
  runtime.addPlugin(stripe);

  runtime.addPlugin(
    new GoogleCloudLoggingPlugin({
      logName: "projects/zuplo-marketing/logs/rick-and-morty",
      serviceAccountJson: environment.GCP_SERVICE_ACCOUNT,
    }),
  );
}