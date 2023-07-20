
function[statusCode,contentType,responseHeaders,data]=cppMatlabService(method,fullPath,queryString,requestParameters)

    [statusCode,contentType,responseHeaders,data]=connector.internal.MatlabService.service(method,fullPath,queryString,requestParameters);
