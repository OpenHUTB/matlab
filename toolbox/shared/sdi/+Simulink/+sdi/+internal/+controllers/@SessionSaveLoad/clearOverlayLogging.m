function clearOverlayLogging()

    message.publish('/sdi2/progressUpdate',...
    struct('operationForTesting','clearOverlayLogging','appName','sdi'));
end