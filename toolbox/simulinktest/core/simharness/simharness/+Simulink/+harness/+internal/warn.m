function warn(msg,varargin)
















    assert(isa(msg,'MException')||...
    iscell(msg)||...
    ischar(msg));

    if(ischar(msg)||isa(msg,'MException'))


        msg={msg};
    else
        msg=message(msg{:});
        msg={msg};
    end

    narginchk(1,4);


    if nargin>1
        narginchk(4,4);



        uiMode=varargin{1};

        stage=DAStudio.message(varargin{2});
        modelName=varargin{3};

        if ishandle(modelName)
            modelName=get_param(modelName,'Name');
        end

        harnessStage=Simulink.output.Stage(stage,...
        'ModelName',modelName,...
        'UIMode',uiMode);%#ok
    end


    origSetting=warning('off','backtrace');


    if(isa(msg{:},'MException'))
        msle=MSLException(msg{:},'COMPONENT','Simulink Test','CATEGORY','Test Harness');
        MSLDiagnostic(msle).reportAsWarning;
    else
        MSLDiagnostic(msg{:},'COMPONENT','Simulink Test','CATEGORY','Test Harness').reportAsWarning;
    end


    warning(origSetting.state,origSetting.identifier);
end
