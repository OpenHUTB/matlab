function error(msg,uiMode,varargin)

















    assert(isa(msg,'MException')||...
    iscell(msg)||...
    ischar(msg));

    if ischar(msg)


        msg={msg};
    end

    if nargin>2
        narginchk(4,4);

        stage=DAStudio.message(varargin{1});
        modelName=varargin{2};


        assert(uiMode);

        harnessStage=Simulink.output.Stage(stage,...
        'ModelName',modelName,...
        'UIMode',uiMode);%#ok
    end


    if uiMode
        Simulink.output.error(msg,'Component','Simulink Test','Category','Test Harness');
    else
        if isa(msg,'MException')
            throwAsCaller(msg);
        else
            DAStudio.error(msg{:});
        end
    end

end
