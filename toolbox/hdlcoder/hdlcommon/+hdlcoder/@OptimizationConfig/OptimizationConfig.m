



















































classdef OptimizationConfig<hgsetget

    properties
        Archive=hdlcoder.OptimizationConfig.Archive.Minimum;
        ExplorationMode=hdlcoder.OptimizationConfig.ExplorationMode.BestFrequency;
        IterationLimit=1;
        ResumptionPoint='';
        TargetFrequency=inf;
        TimingStrategy='Synthesis';
    end

    methods
        function obj=OptimizationConfig()
        end

        function obj=set.Archive(obj,val)
            if(~isa(val,'hdlcoder.OptimizationConfig.Archive'))
                error(message('hdlcoder:optimization:InvalidArchive'));
            end
            obj.Archive=val;
        end

        function obj=set.ExplorationMode(obj,val)
            if(~isa(val,'hdlcoder.OptimizationConfig.ExplorationMode'))
                error(message('hdlcoder:optimization:InvalidExplorationMode'));
            end
            obj.ExplorationMode=val;
        end

        function obj=set.IterationLimit(obj,val)
            if(~isscalar(val)||val<=0||val-double(int64(val))~=0)
                error(message('hdlcoder:optimization:InvalidIterationLimit'));
            end
            obj.IterationLimit=val;
        end

        function obj=set.ResumptionPoint(obj,val)
            if(~ischar(val))
                error(message('hdlcoder:optimization:InvalidIterationLimit'));
            end
            obj.ResumptionPoint=val;
        end

        function obj=set.TargetFrequency(obj,val)
            if(~isnumeric(val)||~isscalar(val)||val<=0)
                error(message('hdlcoder:optimization:InvalidTargetFrequency'));
            end
            obj.TargetFrequency=val;
        end

        function obj=set.TimingStrategy(obj,val)
            TimingStrategyVals={'Synthesis','CriticalPathEstimation'};
            if(~strcmpi(val,TimingStrategyVals))
                error(message('hdlcoder:optimization:InvalidTimingStrategy'));
            end
            obj.TimingStrategy=TimingStrategyVals{strcmpi(val,TimingStrategyVals)};
        end

        function msg=sanitycheck(obj,msg)





            if(~isempty(obj.ResumptionPoint))
                return;
            end

            if(obj.ExplorationMode==hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency&&...
                obj.TargetFrequency==inf)
                error(message('hdlcoder:optimization:InvalidTargetFrequencyInf'));
            end
        end

        function display(obj)
            fprintf(1,'ExplorationMode: ');
            switch(obj.ExplorationMode)
            case{hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency}
                fprintf(1,'hdlcoder.OptimizationConfig.ExplorationMode.TargetFrequency\n');
            case{hdlcoder.OptimizationConfig.ExplorationMode.BestFrequency}
                fprintf(1,'hdlcoder.OptimizationConfig.ExplorationMode.BestFrequency\n');
            otherwise
                fprintf(1,'Unknown!\n');
            end
            fprintf(1,'     IterationLimit: %d\n',obj.IterationLimit);
            fprintf(1,'    TargetFrequency: %d\n',obj.TargetFrequency);
            fprintf(1,'    ResumptionPoint: ''%s''\n',obj.ResumptionPoint);
            fprintf(1,'    TimingStrategy: ''%s''\n',obj.TimingStrategy);
        end

        function newObj=duplicate(obj)
            newObj=hdlcoder.OptimizationConfig;
            newObj.Archive=obj.Archive;
            newObj.ExplorationMode=obj.ExplorationMode;
            newObj.IterationLimit=obj.IterationLimit;
            newObj.ResumptionPoint=obj.ResumptionPoint;
            newObj.TargetFrequency=obj.TargetFrequency;
            newObj.TimingStrategy=obj.TimingStrategy;
        end
    end
end


