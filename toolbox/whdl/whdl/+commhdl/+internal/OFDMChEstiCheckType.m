classdef OFDMChEstiCheckType<matlab.System




%#codegen

    properties(Nontunable)
        ResetInputPort(1,1)logical=false;
    end
    methods
        function obj=OFDMChEstiCheckType(varargin)
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

        function validateInputsImpl(~,datain,validin,refData,refValid,numScPerSym,rst,numSymAvgVal,maxnScPerSymVal,interpolFacVal)

            if isa(datain,'uint8')||isa(datain,'uint16')||isa(datain,'uint32')||isa(datain,'uint64')||(isa(datain,'embedded.fi')&&~datain.Signed)
                coder.internal.error('whdl:OFDMChEstimator:InvalidDatatype');
            end
            validateattributes(datain,{'double','single','embedded.fi','int64','int32','int16','int8'},{'scalar'},'OFDMChannelEstimator','dataIn');
            validateattributes(validin,{'logical'},{'scalar','real'},'OFDMChannelEstimator','validIn');
            if isa(refData,'uint8')||isa(refData,'uint16')||isa(refData,'uint32')||isa(refData,'uint64')||(isa(refData,'embedded.fi')&&~refData.Signed)
                coder.internal.error('whdl:OFDMChEstimator:InvalidRefDatatype');
            end
            validateattributes(refData,{'double','single','embedded.fi','int64','int32','int16','int8'},{'scalar'},'OFDMChannelEstimator','refData');
            validateattributes(refValid,{'logical'},{'scalar','real'},'OFDMChannelEstimator','refValid');
            validateattributes(numScPerSym,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMChannelEstimator','numScPerSym');
            if isa(numScPerSym,'embedded.fi')
                [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(numScPerSym);
                if FL>0||signedBit~=0||WL<2
                    coder.internal.error('whdl:OFDMChEstimator:InvalidNumScPerSymWordlength');
                end
            end
            validateattributes(rst,{'logical'},{'scalar','real'},'OFDMChannelEstimator','reset');
            validateattributes(numSymAvgVal,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMChannelEstimator','Number of symbols to be averaged');
            if isa(numSymAvgVal,'embedded.fi')
                [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(numSymAvgVal);
                if FL>0||signedBit~=0||WL<2
                    coder.internal.error('whdl:OFDMChEstimator:InvDataNumSymToBeAvgd');
                end
            end
            validateattributes(maxnScPerSymVal,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMChannelEstimator','Maximum number of subcarriers per symbol');
            if isa(maxnScPerSymVal,'embedded.fi')
                [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(maxnScPerSymVal);
                if FL>0||signedBit~=0||WL<2
                    coder.internal.error('whdl:OFDMChEstimator:InvDataMaxNumScPerSym');
                end
            end
            validateattributes(interpolFacVal,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMChannelEstimator','Interpolation factor');
            if isa(interpolFacVal,'embedded.fi')
                [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(interpolFacVal);
                if FL>0||signedBit~=0||WL<2
                    coder.internal.error('whdl:OFDMChEstimator:InvalidDataTypeInterpFac');
                end
            end
        end

        function flag=getExecutionSemanticsImpl(obj)
            if obj.ResetInputPort
                flag={'Classic','SynchronousWithResetPort'};
            else
                flag={'Classic','Synchronous'};
            end
        end

        function num=getNumInputsImpl(~)

            num=9;
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
