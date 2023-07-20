classdef OFDMChEqualizerCheckType<matlab.System




%#codegen

    properties(Nontunable)
        ResetInputPort(1,1)logical=false;
    end
    methods
        function obj=OFDMChEqualizerCheckType(varargin)
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

        function validateInputsImpl(~,data,hEst,nVar,valid,hEstLen,loadhEst,rst,maxChanLenEstPerSym)

            if isempty(coder.target)||~coder.internal.isAmbiguousTypes


                if isa(data,'embedded.fi')
                    [WLdata,FLdata,signedBitdata]=dsphdlshared.hdlgetwordsizefromdata(data);
                end
                if isa(data,'uint8')||isa(data,'uint16')||isa(data,'uint32')||...
                    isa(data,'uint64')||isa(data,'int64')||...
                    (isa(data,'embedded.fi')&&(~signedBitdata))||...
                    (isa(data,'embedded.fi')&&(WLdata>32))||...
                    (isa(data,'embedded.fi')&&(FLdata>=WLdata))
                    coder.internal.error('whdl:OFDMEqualizer:InvalidDatatype');
                end

                validateattributes(data,{'double','single','embedded.fi','int32','int16','int8'},{'scalar'},'OFDMEqualizer','dataIn');


                if isa(hEst,'embedded.fi')
                    [WLhEst,FLhEst,signedBithEst]=dsphdlshared.hdlgetwordsizefromdata(hEst);
                end
                if isa(hEst,'uint8')||isa(hEst,'uint16')||isa(hEst,'uint32')||...
                    isa(hEst,'uint64')||isa(hEst,'int32')||isa(hEst,'int64')||...
                    (isa(hEst,'embedded.fi')&&(~signedBithEst))||...
                    (isa(hEst,'embedded.fi')&&(WLhEst>30))||...
                    (isa(hEst,'embedded.fi')&&(FLhEst>=WLhEst))
                    coder.internal.error('whdl:OFDMEqualizer:InvalidhEstDatatype');
                end
                validateattributes(hEst,{'double','single','embedded.fi','int16','int8'},{'scalar'},'OFDMEqualizer','hEst');


                if isa(nVar,'embedded.fi')
                    [WLnVar,FLnVar,signedBitnVar]=dsphdlshared.hdlgetwordsizefromdata(nVar);
                end
                if isa(nVar,'int8')||isa(nVar,'int16')||isa(nVar,'int32')||...
                    isa(nVar,'int64')||isa(nVar,'uint32')||isa(nVar,'uint64')||...
                    (isa(nVar,'embedded.fi')&&signedBitnVar)||...
                    (isa(nVar,'embedded.fi')&&(WLnVar>16))||...
                    (isa(nVar,'embedded.fi')&&(FLnVar>WLnVar))
                    coder.internal.error('whdl:OFDMEqualizer:InvalidnVarDatatype');
                end
                validateattributes(nVar,{'double','single','embedded.fi','uint16','uint8'},{'scalar','real','nonnegative'},'OFDMEqualizer','nVar');


                validateattributes(valid,{'logical'},{'scalar','real'},'OFDMEqualizer','validIn');


                validateattributes(hEstLen,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMEqualizer','hEstLen');
                if isa(hEstLen,'embedded.fi')
                    [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(hEstLen);
                    if FL>0||signedBit~=0||WL<2
                        coder.internal.error('whdl:OFDMEqualizer:InvalidhEstLenDataType');
                    end
                end

                validateattributes(loadhEst,{'logical'},{'scalar','real'},'OFDMEqualizer','loadhEst');


                validateattributes(rst,{'logical'},{'scalar','real'},'OFDMEqualizer','reset');


                validateattributes(maxChanLenEstPerSym,{'double','single','uint32','uint16','uint8','embedded.fi'},{'scalar','real'},'OFDMEqualizer','Maximum length of channel estimate per symbol');
                if isa(maxChanLenEstPerSym,'embedded.fi')
                    [WL,FL,signedBit]=dsphdlshared.hdlgetwordsizefromdata(maxChanLenEstPerSym);
                    if FL>0||signedBit~=0||WL<2
                        coder.internal.error('whdl:OFDMEqualizer:InvDataMaxhEstLen');
                    end
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

            num=8;
        end
        function num=getNumOutputsImpl(~)
            num=0;
        end
    end

    methods(Access=protected)
        function updateImpl(~,data,hEst,nVar,valid,hEstLen,loadhEst,rst,maxChanLenEstPerSym)
            if valid
                validateattributes(nVar,{'double','single','embedded.fi','uint16','uint8'},{'scalar','real','nonnegative'},'OFDMEqualizer','nVar');
            end
        end
    end

    methods(Access=protected,Static)
        function flag=showSimulateUsingImpl

            flag=false;
        end
    end
end
