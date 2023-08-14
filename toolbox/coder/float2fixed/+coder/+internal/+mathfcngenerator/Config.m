



classdef Config<handle
    properties(Access=public)
InputRange
CandidateFunction
PipelinedArchitecture
FunctionNamePrefix
Parameters
    end

    properties(Access=protected)
Architecture
    end

    properties(Hidden)
Mode
Function
Homogenize
    end


    methods
        function set.FunctionNamePrefix(this,value)
            value=convertStringsToChars(value);

            assert(ischar(value));
            this.FunctionNamePrefix=value;
        end

        function set.CandidateFunction(this,value)
            if(isempty(value))
                this.CandidateFunction=[];
                return
            end

            if(isa(value,'function_handle'))
                this.CandidateFunction=value;
                return
            end

            if(isa(value,'char'))
                this.CandidateFunction=str2func(value);
                return
            end
            error(message('float2fixed:MFG:ConfigUnsupportedCandidateFunction',this.Function))%#ok<MCSUP>
        end

        function set.Mode(this,value)
            value=convertStringsToChars(value);
            if~coder.internal.mathfcngenerator.HDLLookupTable.isModeAllowed(value)
                AllowedValues=coder.internal.mathfcngenerator.HDLLookupTable.getAllowedModes();
                cellfun(@disp,AllowedValues);
                error(message('float2fixed:MFG:ConfigUnsupportedMode',value));
            end
            this.Mode=value;
        end

        function set.InputRange(this,value)

            if(size(value,2)~=2)
                error(message('float2fixed:MFG:ConfigArgError'));
            end
            this.InputRange=value;
        end
    end

    methods(Access=protected)
        function this=Config(varargin)
            this.Mode='UniformInterpolation';
            this.CandidateFunction=[];



            this.Homogenize=false;
            this.FunctionNamePrefix='replacement_';
            this.PipelinedArchitecture=false;
            this.Parameters=containers.Map('KeyType','char','ValueType','any');

            this.initParams();
        end



        function this=initParams(this)
            paramFcns=coder.internal.mathfcngenerator.MathFunctionGenerator.getParameterizedFunctions();
            pos=find(strcmpi(paramFcns.keys,this.Function));
            if(~isempty(pos))
                keys=paramFcns.keys;pv=paramFcns(keys{pos});
                prop_key=pv{1};prop_value=pv{2};
                this.Parameters(prop_key)=prop_value;
            end
        end


        function validateNpts(this,value)%#ok<INUSL>
            if(any([~isnumeric(value),~isscalar(value),value<=0]))
                error(message('float2fixed:MFG:PositiveNpts'));
            end
        end
    end

    methods(Access=public)
        function disp(this)
            tab=char(9);
            disp([this.Architecture,' function replacement for ',this.Function])
            disp(' ')
            disp(['Auto-replace function : ',this.Function])
            disp(['InputRange            : ',coder.internal.tools.TML.tostr(this.InputRange)])
            disp(['FunctionNamePrefix    : ',this.FunctionNamePrefix])
            fprintf('CandidateFunction     :');disp(this.CandidateFunction);
            if(this.Parameters.Count>0)
                disp(['Parameters            : (Total = ',num2str(this.Parameters.Count),')'])
                for itr=this.Parameters.keys
                    key=itr{1};
                    disp([tab,key,' = ',coder.internal.tools.TML.tostr(this.Parameters(key))])
                end
            end
            disp(' ')



        end

        function val=getName(this)
            val=this.Function;
        end
    end
end
