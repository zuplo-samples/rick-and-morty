import {
  RuntimeExtensions,
  GoogleCloudLoggingPlugin,
  environment,
} from "@zuplo/runtime";

export function runtimeInit(runtime: RuntimeExtensions) {
  runtime.addPlugin(
    new GoogleCloudLoggingPlugin({
      logName: "projects/zuplo-marketing/logs/rick-and-morty",
      serviceAccountJson: environment.GCP_SERVICE_ACCOUNT,
    }),
  );
}