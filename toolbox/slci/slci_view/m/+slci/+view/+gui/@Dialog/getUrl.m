



function url=getUrl(obj)

    pm=slci.view.Manager.getInstance;
    debugMode=pm.getDebugMode;
    if debugMode
        url=connector.getUrl(obj.fDebugUrl);
    else
        url=connector.getUrl(obj.fUrl);
    end

    SLCIJustification=slci.toolstrip.util.isJustificationFeatureOn;
    readOnly=~slci.toolstrip.util.checkoutLicense;
    url=[url,'&SLCIJustification=',num2str(SLCIJustification),...
    '&channel=',obj.fChannel(2:end),'&readOnly=',num2str(readOnly)];

    if(slcifeature('SLCIJustification')==1&&isequal(obj.id,'SLCIJustification'))
        justificationParameter=['&blockSid=',obj.getBlockSidforUrl(),...
        '&clickedFrom=',obj.getDataFromUi(),'&codeLines=',obj.getCodeLinesforUrl()];
        url=[url,justificationParameter];

    end
