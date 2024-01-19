function fevalHandler(action,clientID,varargin)
    Simulink.scopes.SLWebScopeUtils.fevalHandler(action,clientID,varargin{:});
    block=clientIdToBlock(clientID);

    switch action
    case 'setParameters'
        Simulink.scopes.SLWebScopeUtils.fevalHandler(action,clientID,varargin{:});

        params=varargin{1};
        numParameters=numel(params);
        wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
        for indx=1:numParameters
            wsBlock.PublishParamValues=false;
            paramName=params(indx).name;
            paramType=params(indx).type;
            paramValue=params(indx).value;

            if isequal(paramType,'bool')
                paramValue=utils.logicalToOnOff(paramValue);
            end

            try
                set_param(block,paramName,paramValue);
            catch
                wsBlock.PublishParamValues=true;

                if strcmp(paramName,'YLimits')||strcmp(paramName,'ExpandToolstrip')||strcmp(paramName,'LayoutDimensions')
                    continue
                else

                    fprintf('Unable to set the parameter %s value\n',paramName);
                end
            end
        end
        wsBlock.PublishParamValues=true;
    case 'copyDisplay'
        dsp.webscopes.internal.BaseWebScope.fevalHandler(action,clientID,varargin{:});
    case 'printDisplay'
        dsp.webscopes.internal.BaseWebScope.fevalHandler(action,clientID,varargin{:});
    case 'dock'
        set_param(clientIdToBlock(clientID),'ScopeFrameLocation','container');

    case 'printToFigure'
        wp=matlabshared.scopes.WebScopePrinter(PreserveColors=varargin{2});
        printConfig=wp.getPrintConfigurationFromBlock(block);
        Data=Simulink.scopes.SLWebScopeUtils.getDataForPrintToFig(clientID);
        try
            wp.printToFigure(Data,printConfig);
        catch E

            errordlg(E.message,'Print to Figure Error');
        end
    end
end


function block=clientIdToBlock(clientID)
    wsBlock=matlabshared.scopes.WebScope.getInstance(clientID);
    block=wsBlock.FullPath;

end