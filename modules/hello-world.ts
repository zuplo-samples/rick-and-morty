import { ZuploContext, ZuploRequest } from "@zuplo/runtime";

export default async function (request: ZuploRequest, context: ZuploContext) {
  if (request.user?.data?.customerType === "premium") {
    return request;
  }
  return "When are you gonna start paying?"
}
