function error(msg,uiMode,varargin)

    assert(isa(msg,'MException')||...
    iscell(msg)||...
    ischar(msg));

    if ischar(msg)
        msg={msg};
    end

    if uiMode
        if nargin>2
            narginchk(4,4);
        end
        stage=DAStudio.message(varargin{1});
        modelName=varargin{2};
        harnessStage=Simulink.output.Stage(stage,...
        'ModelName',modelName,...
        'UIMode',uiMode);%#ok
        Simulink.output.error(msg,'Component','Simulink Test','Category','Injector');
    else
        if isa(msg,'MException')
            throwAsCaller(msg);
        else
            DAStudio.error(msg{:});
        end
    end

end
