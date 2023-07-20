classdef(StrictDefaults)ConvEncCheckType<matlab.System




%#codegen

    methods
        function obj=ConvEncCheckType(varargin)
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

        function validateInputsImpl(~,datain,startin,endin,validin)

            validateattributes(datain,{'double','single','logical','embedded.fi'},{'scalar','binary'},'ConvolutionalEncoder','dataIn');

            if(isa(datain,'embedded.fi')&&dsphdlshared.hdlgetwordsizefromdata(datain)>1)
                coder.internal.error('whdl:ConvolutionalCode:InvalidDataType',tostringInternalSlName(datain.numerictype));
            end

            validateattributes(startin,{'logical'},{'scalar'},'ConvolutionalEncoder','startIn');
            validateattributes(endin,{'logical'},{'scalar'},'ConvolutionalEncoder','endIn');
            validateattributes(validin,{'logical'},{'scalar'},'ConvolutionalEncoder','validIn');
        end

        function num=getNumInputsImpl(~)

            num=4;
        end

        function num=getNumOutputsImpl(~)
            num=0;
        end
    end
end
