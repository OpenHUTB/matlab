function endOverlayLogging()

    message.publish('/sdi2/progressUpdate',...
    struct('operationForTesting','endOverlayLogging','appName','sdi'));
end