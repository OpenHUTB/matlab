


classdef LatencyDrivenMode<fpconfig.FloatingPointMode
    properties(Constant,Hidden=true)
        LatencyStrategyDefault='MIN';
        ObjectiveDefault='SPEED';
    end

    properties(Access=public)
LatencyStrategy
Objective
    end

    methods
        function obj=LatencyDrivenMode(varargin)

            if(nargin==1&&isa(varargin{1},'fpconfig.ConstructArgs'))
                fpconfig.DeepCopiable.initWithPV(obj,varargin{:});
                return;
            end

            p=inputParser;
            p.addParameter('LatencyStrategy',fpconfig.LatencyDrivenMode.LatencyStrategyDefault,@fpconfig.LatencyDrivenMode.validateLatencyStrategy);
            p.addParameter('Objective',fpconfig.LatencyDrivenMode.ObjectiveDefault,@fpconfig.LatencyDrivenMode.validateObjective);
            p.parse(varargin{:});
            obj.LatencyStrategy=p.Results.LatencyStrategy;
            obj.Objective=p.Results.Objective;
        end

        function obj=set.LatencyStrategy(obj,val)
            fpconfig.LatencyDrivenMode.validateLatencyStrategy(val);
            obj.LatencyStrategy=upper(val);
        end

        function obj=set.Objective(obj,val)
            fpconfig.LatencyDrivenMode.validateObjective(val);
            obj.Objective=upper(val);
        end

        function latency=resolveLatencyFromIPSettings(obj,ips)
            if(ips.Latency~=-1)
                latency=ips.Latency;
            else
                if(strcmpi(obj.LatencyStrategy,'MIN'))
                    latency=ips.MinLatency;
                else
                    assert(strcmpi(obj.LatencyStrategy,'MAX'))
                    latency=ips.MaxLatency;
                end
            end
        end
    end

    methods(Access=public,Hidden=true)




        function scripts=serializeOutMScripts(this)
            scripts='';
            if(~isequal(this.LatencyStrategy,fpconfig.LatencyDrivenMode.LatencyStrategyDefault))
                scripts='''LatencyStrategy'', ''MAX''';
            end
            if(~isequal(this.Objective,fpconfig.LatencyDrivenMode.ObjectiveDefault))
                settingStr='''Objective'', ''AREA''';
                if(isempty(scripts))
                    scripts=settingStr;
                else
                    scripts=sprintf('%s, %s',scripts,settingStr);
                end
            end
        end
    end

    methods(Static=true)
        function validateLatencyStrategy(val)
            if(~strcmpi(val,'MIN')&&~strcmpi(val,'MAX'))
                error(message('hdlcommon:targetcodegen:InvalidLatencyStrategy'));
            end
        end

        function validateObjective(val)
            if(~strcmpi(val,'NONE')&&~strcmpi(val,'SPEED')&&~strcmpi(val,'AREA'))
                error(message('hdlcommon:targetcodegen:InvalidObjective'));
            end
        end
    end
end

