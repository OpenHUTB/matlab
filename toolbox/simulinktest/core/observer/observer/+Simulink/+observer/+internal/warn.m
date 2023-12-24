function warn(msg,varargin)

    assert(isa(msg,'MException')||...
    iscell(msg)||...
    ischar(msg));

    if(ischar(msg)||isa(msg,'MException'))
        msg={msg};
    end

    if nargin>1
        narginchk(4,4);
        uiMode=varargin{1};
        stage=DAStudio.message(varargin{2});
        modelName=varargin{3};

        if ishandle(modelName)
            modelName=get_param(modelName,'Name');
        end
        observerStage=Simulink.output.Stage(stage,...
        'ModelName',modelName,...
        'UIMode',uiMode);%#ok
    end
    origSetting=warning('off','backtrace');
    if uiMode
        MSLDiagnostic(msg{:},'COMPONENT','Simulink Test','CATEGORY','Observer').reportAsWarning;
    else
        MSLDiagnostic(msg{:}).reportAsWarning;
    end
    warning(origSetting.state,origSetting.identifier);
end
