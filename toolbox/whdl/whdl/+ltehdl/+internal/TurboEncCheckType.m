classdef(StrictDefaults)TurboEncCheckType<matlab.System




%#codegen

    methods
        function obj=TurboEncCheckType(varargin)
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

        function validateInputsImpl(~,datain,blocksize,startin,endin,validin)

            validateattributes(datain,{'double','single','logical','embedded.fi'},{'scalar','binary'},'TurboEncoder','dataIn');

            if(isa(datain,'embedded.fi')&&dsphdlshared.hdlgetwordsizefromdata(datain)>1)
                coder.internal.error('whdl:TurboCode:InvalidEncDataType',tostringInternalSlName(datain.numerictype));
            end

            if~((isa(blocksize,'embedded.fi')&&dsphdlshared.hdlgetwordsizefromdata(blocksize)==13)||isa(blocksize,'uint16'))
                coder.internal.error('whdl:TurboCode:InvalidBlkSizeType');
            end
            validateattributes(startin,{'logical'},{'scalar'},'TurboEncoder','startIn');
            validateattributes(endin,{'logical'},{'scalar'},'TurboEncoder','endIn');
            validateattributes(validin,{'logical'},{'scalar'},'TurboEncoder','validIn');
        end

        function num=getNumInputsImpl(~)

            num=5;
        end

        function num=getNumOutputsImpl(~)
            num=0;
        end
    end
end
