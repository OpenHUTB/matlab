


classdef LookupTable<coder.internal.mathfcngenerator.Config
    properties(Access=public)
NumberOfPoints
InterpolationDegree
ErrorThreshold
OptimizeLUTSize
OptimizeIterations
    end


    methods
        function this=set.NumberOfPoints(this,value)
            this.validateNpts(value);
            this.NumberOfPoints=value;
        end
        function this=set.OptimizeLUTSize(this,value)
            if(value)
                this.OptimizeLUTSize=true;
                this.Mode='CustomInterpolation';
            else
                this.OptimizeLUTSize=false;
                this.Mode='UniformInterpolation';
            end
        end
        function this=set.InterpolationDegree(this,value)
            if(isnumeric(value))
                this.InterpolationDegree=value;
            else
                error(message('float2fixed:MFG:UnimplementedInterp'));
            end
        end
    end

    methods(Access=public)
        function this=LookupTable(varargin)
            this=this@coder.internal.mathfcngenerator.Config(varargin{:});


            this.Architecture='LookupTable';
            this.Function='';
            this.Mode='UniformInterpolation';

            this.NumberOfPoints=1000;
            this.InterpolationDegree=1;
            this.ErrorThreshold=1e-3;
            this.CandidateFunction=[];
            this.OptimizeLUTSize=false;
            this.OptimizeIterations=25;
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

            disp('Architecture          : LookupTable')
            disp(['NumberOfPoints        : ',num2str(this.NumberOfPoints)])
            disp(['InterpolationDegree   : ',num2str(this.InterpolationDegree)])
            disp(['ErrorThreshold        : ',num2str(this.ErrorThreshold)])
            disp(['OptimizeLUTSize       : ',coder.internal.tools.TML.tostr(this.OptimizeLUTSize)])
            disp(['OptimizeIterations    : ',coder.internal.tools.TML.tostr(this.OptimizeIterations)])
            disp(' ')

        end

    end

end
