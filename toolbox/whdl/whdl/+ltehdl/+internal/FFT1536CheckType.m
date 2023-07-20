classdef FFT1536CheckType<matlab.System






%#codegen

    properties(Nontunable)
        ResetInputPort(1,1)logical=false;
    end
    methods
        function obj=FFT1536CheckType(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
        end
    end

    methods(Access=protected)

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function[dataOut,validOut,resetOut]=stepImpl(obj,dataIn,validIn,resetIn)


            dataOut=dataIn;
            validOut=validIn;
            resetOut=resetIn;
        end

        function validateInputsImpl(obj,data,valid,reset)

            if~isscalar(data)
                coder.internal.error('whdl:FFT1536:InputNotScalar');
            end

            if~isscalar(valid)
                coder.internal.error('whdl:FFT1536:InvalidInputValidType');
            end

            if~isscalar(reset)
                coder.internal.error('whdl:FFT1536:InvalidInputResetType');
            end
            if isfi(data)
                dataType=numerictype(data);
            else
                dataType=class(data);
            end
            if isfi(valid)
                validType=numerictype(valid);
            else
                validType=class(valid);
            end
            if isfi(reset)
                resetType=numerictype(reset);
            else
                resetType=class(reset);
            end
            validateInputsDataTypes(obj,dataType,validType,resetType);
        end

        function num=getNumInputsImpl(~)
            num=3;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function[out,out2,out3]=getOutputSizeImpl(obj)

            out=[1,1];
            out2=[1,1];
            out3=[1,1];



        end

        function[data,valid,reset]=getOutputDataTypeImpl(obj)

            data=propagatedInputDataType(obj,1);
            valid=propagatedInputDataType(obj,2);
            reset=propagatedInputDataType(obj,3);

            validateInputsDataTypes(obj,data,valid,reset);



        end

        function[out,out2,out3]=isOutputComplexImpl(obj)

            out=propagatedInputComplexity(obj,1);
            out2=false;
            out3=false;



        end

        function[out,out2,out3]=isOutputFixedSizeImpl(obj)

            out=true;
            out2=true;
            out3=true;



        end

        function flag=getExecutionSemanticsImpl(obj)
            if obj.ResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end

    end

    methods(Access=private)
        function validateInputsDataTypes(obj,data,valid,reset)
            if~isnumerictype(valid)
                if~strcmp(valid,'logical')
                    coder.internal.error('whdl:FFT1536:InvalidInputValidType');
                end
            else
                coder.internal.error('whdl:FFT1536:InvalidInputValidType');
            end

            if~isnumerictype(reset)
                if~strcmp(reset,'logical')
                    coder.internal.error('whdl:FFT1536:InvalidInputResetType');
                end
            else
                coder.internal.error('whdl:FFT1536:InvalidInputResetType');
            end

            if~isnumerictype(data)
                if~(strcmp(data,'double')||strcmp(data,'single')||...
                    strcmp(data,'int8')||strcmp(data,'int16')||...
                    strcmp(data,'int32'))
                    coder.internal.error('whdl:FFT1536:InvalidInputDataType');
                end
            end

            if isnumerictype(data)
                if~data.Signed
                    coder.internal.error('whdl:FFT1536:InvalidInputSigned');
                end
            end
        end
    end

    methods(Access=protected,Static)

        function flag=showSimulateUsingImpl
            flag=true;
        end
    end
end


















































































































































