


classdef FlatLookupTable<coder.internal.mathfcngenerator.Config
    properties(Access=public)
NumberOfPoints
    end


    methods
        function this=set.NumberOfPoints(this,value)
            this.validateNpts(value);
            if(isnumeric(value)&&value>0)

                this.NumberOfPoints=2^nextpow2(value);
                if(this.NumberOfPoints~=value)
                    warning(message('float2fixed:MFG:InvalidNptsPow2',value,this.NumberOfPoints));
                end
            else
                error(message('float2fixed:MFG:InvalidNptsError',value))
            end
        end
    end

    methods(Access=public)
        function this=FlatLookupTable(varargin)
            this=this@coder.internal.mathfcngenerator.Config(varargin{:});


            this.Architecture='FlatLookupTable';
            this.Function='';
            this.Mode='UniformInterpolation';

            this.NumberOfPoints=256;
            this.PipelinedArchitecture=false;


            try
                for itr=1:2:length(varargin)
                    this.(varargin{itr})=varargin{itr+1};
                end
            catch mEx
                mEx2=MException(message('float2fixed:MFG:FailedCodeGen')).addCause(mEx);
                throw(mEx2);
            end

            this.initParams();
        end

        function disp(this)
            disp@coder.internal.mathfcngenerator.Config(this)

            disp('Architecture          : FlatLookupTable')
            disp(['NumberOfPoints        : ',num2str(this.NumberOfPoints)])
            disp(' ')

        end

    end

end
