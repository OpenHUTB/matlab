classdef OFDMModulatorCheckType<matlab.System
%#codegen



    methods
        function obj=OFDMModulatorCheckType(varargin)
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

        function validateInputsImpl(~,datain,validin,NDLRB,cyclicPrefixType,rst,winLen)

            validateattributes(winLen,{'embedded.fi'},{'vector','real'},'OFDMModulator','window length');



            if isa(winLen,'vector')
                if length(winLen)~=6
                    coder.internal.error('whdl:OFDMModulator:InValidWinLenVecErr');
                end
            end
            if isa(datain,'uint8')||isa(datain,'uint16')||isa(datain,'uint32')||(isa(datain,'embedded.fi')&&~datain.Signed)
                coder.internal.error('whdl:OFDMModulator:InvalidDatatype');
            end
            validateattributes(datain,{'double','single','embedded.fi','int32','int16','int8'},{'scalar'},'OFDMModulator','dataIn');
            validateattributes(NDLRB,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMModulator','NDLRB');
            if(isa(NDLRB,'embedded.fi')&&dsphdlshared.hdlgetwordsizefromdata(NDLRB)<7)
                coder.internal.error('whdl:OFDMModulator:InvalidNDLRBWordlength');
            end
            if isa(NDLRB,'embedded.fi')
                [~,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(NDLRB);
                if FL>0||signedBit~=0
                    coder.internal.error('whdl:OFDMModulator:InvalidNDLRBWordlength');
                end
            end
            validateattributes(cyclicPrefixType,{'logical'},{'scalar','real'},'OFDMModulator','cyclicPrefixType');
            validateattributes(validin,{'logical'},{'scalar','real'},'OFDMModulator','validIn');
            validateattributes(rst,{'logical'},{'scalar','real'},'OFDMModulator','reset');
        end

        function num=getNumInputsImpl(~)

            num=6;
        end
        function num=getNumOutputsImpl(~)
            num=0;
        end
    end

    methods(Access=protected,Static)
        function flag=showSimulateUsingImpl

            flag=false;
        end
    end
end
