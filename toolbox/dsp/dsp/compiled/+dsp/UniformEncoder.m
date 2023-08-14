classdef UniformEncoder<matlab.system.SFunSystem
































































%#function mdspuencode2

    properties(Nontunable)







        PeakValue=1;





        NumBits=8;









        OutputDataType='Unsigned integer';
    end

    properties(Constant,Hidden)
        OutputDataTypeSet=matlab.system.StringSet(...
        {'Unsigned integer','Signed integer'});
    end

    methods

        function obj=UniformEncoder(varargin)
            coder.internal.warning('dsp:system:UniformEncoder_NotSupported');
            obj@matlab.system.SFunSystem('mdspuencode2');
            setProperties(obj,nargin,varargin{:},'PeakValue','NumBits');
            setVarSizeAllowedStatus(obj,false);
        end
    end

    methods(Hidden)
        function setParameters(obj)

            OutputDataTypeIdx=getIndex(...
            obj.OutputDataTypeSet,obj.OutputDataType);

            obj.compSetParameters({...
            obj.PeakValue,...
            obj.NumBits,...
OutputDataTypeIdx...
            });
        end
    end

    methods(Static,Hidden)
        function a=getAlternateBlock
            a='dspquant2/Uniform Encoder';
        end

        function props=getDisplayPropertiesImpl()
            props={...
'PeakValue'...
            ,'NumBits'...
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


