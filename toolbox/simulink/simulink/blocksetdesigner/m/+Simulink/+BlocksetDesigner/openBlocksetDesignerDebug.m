


message.subscribe('/blocksetdesigner/jspublish',@(msg)messageReceived(msg));
connector.ensureServiceOn;
connector.newNonce;
url=connector.getUrl('toolbox/simulink/simulink/blocksetdesigner/web/index-debug.html');
web(url,'-browser');

function messageReceived(msg)
    Simulink.BlocksetDesigner.invokeCommand(msg);
end