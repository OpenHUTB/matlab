function beginOverlayLogging()

    message.publish('/sdi2/progressUpdate',...
    struct('operationForTesting','beginOverlayLogging','appName','sdi'));
end