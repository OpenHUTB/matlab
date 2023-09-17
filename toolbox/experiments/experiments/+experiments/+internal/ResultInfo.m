classdef ResultInfo<handle
    properties(Constant,Access=protected,Transient)
        CurrentVersion_=1;
    end

    properties(Access=protected,Hidden=true)
        Version_=experiments.internal.ResultInfo.CurrentVersion_;
    end

    properties(Hidden)
resultMap
expCounter
    end

    methods
        function this=ResultInfo()
            this.resultMap=containers.Map('KeyType','char','ValueType','any');
            this.expCounter=containers.Map('KeyType','char','ValueType','uint64');
        end

        function disp(~)
            disp('Experiment Results');
        end
    end
end
