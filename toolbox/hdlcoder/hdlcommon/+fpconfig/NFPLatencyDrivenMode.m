




classdef NFPLatencyDrivenMode<fpconfig.FloatingPointMode
    properties(Access=public)
LatencyStrategy
HandleDenormals
MantissaMultiplyStrategy
PartAddShiftMultiplierSize
Version
    end

    properties(Dependent,Hidden=true)
LatencyStrategyInt
HandleDenormalsInt
MantissaMultiplyStrategyInt
PartAddShiftMultiplierSizeInt
    end

    properties(Access=private,Constant=true)
        LatencyStrategyVals={'Max','Min','Zero'};
        HandleDenormalsVals={'On','Off','Auto'};
        MantissaMultiplyStrategyVals={'Auto','FullMultiplier',...
        'PartMultiplierPartAddShift','NoMultiplierFullAddShift'};
        PartAddShiftMultiplierSizeVals={'18x24','18x18','17x17'};
    end

    methods
        function obj=NFPLatencyDrivenMode(varargin)

            if(nargin==1&&isa(varargin{1},'fpconfig.ConstructArgs'))
                fpconfig.DeepCopiable.initWithPV(obj,varargin{:});
                return;
            end

            p=inputParser;
            p.addParameter('LatencyStrategy','Max');
            p.addParameter('HandleDenormals','Auto');
            p.addParameter('MantissaMultiplyStrategy','Auto');
            p.addParameter('PartAddShiftMultiplierSize','18x24');
            p.parse(varargin{:});
            obj.LatencyStrategy=p.Results.LatencyStrategy;
            obj.HandleDenormals=p.Results.HandleDenormals;
            obj.MantissaMultiplyStrategy=p.Results.MantissaMultiplyStrategy;
            obj.PartAddShiftMultiplierSize=p.Results.PartAddShiftMultiplierSize;
            obj.Version='3.0.0';
        end

        function set.LatencyStrategy(obj,val)
            obj.validateLatencyStrategy(val);
            obj.LatencyStrategy=...
            obj.LatencyStrategyVals{strcmpi(val,obj.LatencyStrategyVals)};
        end

        function set.HandleDenormals(obj,val)
            obj.validateHandleDenormals(val);
            obj.HandleDenormals=...
            obj.HandleDenormalsVals{strcmpi(val,obj.HandleDenormalsVals)};
        end

        function set.MantissaMultiplyStrategy(obj,val)
            obj.validateMantissaMultiplyStrategy(val);
            obj.MantissaMultiplyStrategy=...
            obj.MantissaMultiplyStrategyVals{strcmpi(val,obj.MantissaMultiplyStrategyVals)};
        end

        function set.PartAddShiftMultiplierSize(obj,val)
            obj.validatePartAddShiftMultiplierSize(val);
            obj.PartAddShiftMultiplierSize=...
            obj.PartAddShiftMultiplierSizeVals{strcmpi(val,obj.PartAddShiftMultiplierSizeVals)};
        end

        function val=get.LatencyStrategyInt(obj)
            val=find(strcmpi(obj.LatencyStrategy,obj.LatencyStrategyVals));
        end

        function val=get.HandleDenormalsInt(obj)
            val=find(strcmpi(obj.HandleDenormals,obj.HandleDenormalsVals));
        end

        function val=get.MantissaMultiplyStrategyInt(obj)
            val=find(strcmpi(obj.MantissaMultiplyStrategy,obj.MantissaMultiplyStrategyVals));
        end

        function val=get.PartAddShiftMultiplierSizeInt(obj)
            val=find(strcmpi(obj.PartAddShiftMultiplierSize,obj.PartAddShiftMultiplierSizeVals));
        end

        function latency=resolveLatencyFromIPSettings(obj,ips)
            if(ips.Latency~=-1)
                latency=ips.Latency;
            else
                switch obj.LatencyStrategyInt
                case 1
                    latency=ips.MaxLatency;
                case 2
                    latency=ips.MinLatency;
                case 3
                    latency=0;
                otherwise
                    error('Unexpected latency setting for NFP');
                end
            end
        end
    end

    methods(Access=public,Hidden=true)




        function scripts=serializeOutMScripts(this)
            scripts='';
            if(~strcmpi(this.LatencyStrategy,'Max'))
                scripts=sprintf('''LatencyStrategy'', ''%s''',this.LatencyStrategy);
            end
            if(~strcmpi(this.HandleDenormals,'Auto'))
                if~isempty(scripts)
                    scripts=sprintf('%s, ',scripts);
                end
                scripts=sprintf('%s ''HandleDenormals'', ''%s''',scripts,this.HandleDenormals);
            end

            if(~strcmpi(this.MantissaMultiplyStrategy,'Auto'))
                if~isempty(scripts)
                    scripts=sprintf('%s, ',scripts);
                end
                scripts=sprintf('%s ''MantissaMultiplyStrategy'', ''%s''',scripts,this.MantissaMultiplyStrategy);
            end

            if(~strcmpi(this.PartAddShiftMultiplierSize,'18x24'))
                if~isempty(scripts)
                    scripts=sprintf('%s, ',scripts);
                end
                scripts=sprintf('%s ''PartAddShiftMultiplierSize'', ''%s''',scripts,this.PartAddShiftMultiplierSize);
            end
        end
    end

    methods(Access=private)
        function validateLatencyStrategy(obj,val)
            if~any(strcmpi(val,obj.LatencyStrategyVals))
                error(message('hdlcommon:targetcodegen:NFPInvalidLatencyStrategy'));
            end
        end

        function validateHandleDenormals(obj,val)
            if~any(strcmpi(val,obj.HandleDenormalsVals))
                error(message('hdlcommon:targetcodegen:InvalidObjective'));
            end
        end

        function validateMantissaMultiplyStrategy(obj,val)
            if~any(strcmpi(val,obj.MantissaMultiplyStrategyVals))
                error(message('hdlcommon:nativefloatingpoint:InvalidMantissaMultiplyStrategy'));
            end
        end

        function validatePartAddShiftMultiplierSize(obj,val)
            if~any(strcmpi(val,obj.PartAddShiftMultiplierSizeVals))
                error(message('hdlcommon:nativefloatingpoint:InvalidPartAddShiftMultiplierSize'));
            end
        end
    end
end

