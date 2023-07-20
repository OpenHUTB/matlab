function fevalHandler(action,clientID,varargin)




    dsp.webscopes.internal.BaseWebScope.fevalHandler(action,clientID,varargin{:});
    Simulink.scopes.SLWebScopeUtils.fevalHandler(action,clientID,varargin{:});
    switch action
    case 'showHelp'
        helpview(fullfile(docroot,'phased','helptargets.map'),'phased_rti_scope_block');
    case 'printPreviewDisplay'
        printPreviewDisplay(clientID);
    case 'setParameters'
        params=varargin{1};
        numParameters=numel(params);
        wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
        block=wsBlock.FullPath;

        for indx=1:numParameters
            paramName=params(indx).name;
            paramType=params(indx).type;
            paramValue=params(indx).value;
            if isequal(paramType,'bool')
                if isequal(paramValue,true)
                    paramValue='on';
                else
                    paramValue='off';
                end
            end

            try
                set_param(block,paramName,paramValue);
            catch
            end
        end
    end
end


function printPreviewDisplay(clientId)
    import dsp.webscopes.internal.*;
    webWindow=BaseWebScope.getWebWindowFromClientID(clientId);
    if isempty(webWindow)
        return;
    end
    fig=prepareWebWindowForSharing(webWindow,'print');

    BaseWebScope.publishMessage(clientId,'onPrePrintPreview',true);
    if~isMATLABOnline()

        printpreview(fig);
    else

        desiredName='Range-Time Intensity plot';
        uniqueName=BaseWebScope.getUniqueFileName(desiredName);
        print(uniqueName,'-dpdf');
    end
    delete(fig);

    BaseWebScope.publishMessage(clientId,'onPostPrintPreview',true);
end



function fig=prepareWebWindowForSharing(webWindow,action)
    screenshot=flipud(getScreenshot(webWindow));
    pos=webWindow.Position;
    fig=figure(...
    'HandleVisibility',uiservices.logicalToOnOff(strcmpi(action,'copy')),...
    'Visible','off',...
    'Position',pos);
    a=axes(...
    'Parent',fig,...
    'Position',[0,0,1,1]);

    img=image(...
    'Parent',a,...
    'CData',screenshot);

    xLim=a.XLim;
    yLim=a.YLim;

    img.XData=[1,xLim(2)-1];
    img.YData=[1,yLim(2)-1];
end


function flag=isMATLABOnline(~)

    flag=matlab.internal.environment.context.isMATLABOnline||...
    matlab.ui.internal.desktop.isMOTW;
end
