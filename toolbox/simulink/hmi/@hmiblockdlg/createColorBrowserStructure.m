function colorWebBrowser=createColorBrowserStructure(obj,htmlPath,isSlimDialog,optionalParameters)
    model=get_param(bdroot(get(obj.blockObj,'handle')),'Name');

    url=[htmlPath,'?widgetID=',obj.widgetId,'&model=',model,...
    '&isLibWidget=',num2str(obj.isLibWidget)];
    if isSlimDialog==true
        url=[url,'&isSlimDialog=',num2str(isSlimDialog)];
    end

    if(nargin>3)
        for index=1:length(optionalParameters)
            url=strcat(url,'&',optionalParameters{index});
        end
    end

    colorWebBrowser.Type='webbrowser';
    colorWebBrowser.Tag='color_webbrowser';
    colorWebBrowser.Url=Simulink.HMI.ConnectorAPI.getAPI().getURL(url);
    colorWebBrowser.DisableContextMenu=true;
    colorWebBrowser.MatlabMethod='slDialogUtil';
    colorWebBrowser.MatlabArgs={obj,'sync','%dialog','webbrowser','%tag'};

    if Simulink.HMI.isLibrary(model)||utils.isLockedLibrary(model)
        colorWebBrowser.Enabled=false;
    else
        colorWebBrowser.Enabled=true;
    end
end
