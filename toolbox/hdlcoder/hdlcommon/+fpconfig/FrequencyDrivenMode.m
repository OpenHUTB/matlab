


classdef FrequencyDrivenMode<fpconfig.FloatingPointMode
    properties(Constant,Hidden=true)
        InitializeIPPipelinesToZeroDefault=true;
    end

    properties(Access=public)
InitializeIPPipelinesToZero
    end

    methods
        function obj=FrequencyDrivenMode(varargin)

            if(nargin==1&&isa(varargin{1},'fpconfig.ConstructArgs'))
                fpconfig.DeepCopiable.initWithPV(obj,varargin{:});
                return;
            end

            p=inputParser;
            p.addParameter('InitializeIPPipelinesToZero',fpconfig.FrequencyDrivenMode.InitializeIPPipelinesToZeroDefault,@fpconfig.FrequencyDrivenMode.validateInitializeIPPipelinesToZero);
            p.parse(varargin{:});
            obj.InitializeIPPipelinesToZero=p.Results.InitializeIPPipelinesToZero;
        end

        function obj=set.InitializeIPPipelinesToZero(obj,val)
            fpconfig.FrequencyDrivenMode.validateInitializeIPPipelinesToZero(val);
            obj.InitializeIPPipelinesToZero=logical(val);
        end
    end

    methods(Access=public,Hidden=true)
        function latency=resolveLatencyFromIPSettings(~,ips)
            latency=ips.Latency;
        end

        function scripts=serializeOutMScripts(this)
            scripts='';
            if(~isequal(this.InitializeIPPipelinesToZero,fpconfig.FrequencyDrivenMode.InitializeIPPipelinesToZeroDefault))
                scripts='''InitializeIPPipelinesToZero'', false';
            end
        end
    end

    methods(Static=true,Hidden=true)
        function validateInitializeIPPipelinesToZero(val)
            if(~(islogical(val)||val==1||val==0))
                error(message('hdlcommon:targetcodegen:InvalidInitialSequentialLogic'));
            end
        end
    end
end

