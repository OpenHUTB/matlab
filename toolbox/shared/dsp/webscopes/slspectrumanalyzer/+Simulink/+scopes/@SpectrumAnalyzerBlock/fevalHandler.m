function fevalHandler(action,clientID,varargin)





    dsp.webscopes.internal.BaseWebScope.fevalHandler(action,clientID,varargin{:});


    Simulink.scopes.SLWebScopeUtils.fevalHandler(action,clientID,varargin{:});
    switch action
    case 'showHelp'

        mapFileLocation=fullfile(docroot,'toolbox','dsp','dsp.map');
        helpview(mapFileLocation,varargin{1});

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
                paramValue=utils.logicalToOnOff(paramValue);
            end


            if isequal(paramName,'GraphicalSettings')
                cfg=get_param(block,'ScopeConfiguration');
                updateGraphicalSettings(cfg,paramValue);
            end

            try
                set_param(block,paramName,paramValue);
            catch
                assert(false,sprintf('Unable to set the parameter %s value',paramName));
            end
        end

    end
end
