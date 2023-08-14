classdef UniformDecoder<matlab.system.SFunSystem























































%#function mdspudecode2

    properties(Nontunable)







        PeakValue=1;








        NumBits=3;




        OverflowAction='Saturate';



        OutputDataType='double';
    end

    properties(Constant,Hidden)
        OverflowActionSet=dsp.CommonSets.getSet('OverflowAction');
        OutputDataTypeSet=matlab.system.StringSet({'double','single'});
    end

    methods

        function obj=UniformDecoder(varargin)
            obj@matlab.system.SFunSystem('mdspudecode2');
            coder.internal.warning('dsp:system:UniformDecoder_NotSupported');
            setProperties(obj,nargin,varargin{:},'PeakValue','NumBits');
            setVarSizeAllowedStatus(obj,false);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            OutputDataTypeIdx=getIndex(...
            obj.OutputDataTypeSet,obj.OutputDataType);
            OverflowActionIdx=getIndex(...
            obj.OverflowActionSet,obj.OverflowAction);



            OverflowActionIdx=3-OverflowActionIdx;

            obj.compSetParameters({...
            obj.PeakValue,...
            obj.NumBits,...
            OutputDataTypeIdx,...
            OverflowActionIdx,...
            });
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspquant2/Uniform Decoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'PeakValue'...
            ,'NumBits'...
            ,'OverflowAction'...
            ,'OutputDataType'...
            };
        end

        function b=generatesCode
            b=false;
        end


        function props=getValueOnlyProperties()
            props={'PeakValue','NumBits'};
        end
    end

end


