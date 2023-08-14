classdef(StrictDefaults)NRCRCDecoder<matlab.System



%#codegen

    properties(Nontunable)











        CRCType='CRC16';
    end

    properties(Constant,Hidden)


        CRCTypeSet=matlab.system.StringSet({'CRC6','CRC11','CRC16','CRC24A','CRC24B','CRC24C'});
    end

    properties(Nontunable)%#ok<*MTMAT>

        FullCheckSum(1,1)logical=false;


        EnableCRCMaskPort(1,1)logical=false;
    end

    properties(Nontunable,Access=private)
        crclen;
        datalen;
        depth;
        isUInt;
        Poly_Opt;
        InitialState=0;
        inDisp;
        isIntIn;
        isScalarIn;
        dataclass;

        DirectMethod(1,1)logical=false;
        ReflectInput(1,1)logical=false;
        ReflectCRCChecksum(1,1)logical=false;
    end

    properties(Access=private)

        commHDLCRCGenerator;
        commHDLCRCGenerator1;
        startReg;
        dataReg;
        endReg;
        flipFlop;
        startOutReg;
        startOut;
        endOut;
        validOut;
        dataOut;
        startInReg;
        validInReg;
        endInReg;
        datadelayReg;
        startDelayReg;
        endInReg2;
        delayCRCReg;
        dataInReg;
        crcReg;
        dataOutReg;
        crcInReg;
        crcBaseReg;
        endDelay;
        err;
crcMask
        maskBits;
    end

    methods
        function obj=NRCRCDecoder(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end
            setProperties(obj,nargin,varargin{:},'CRCType');
        end

        function set.CRCType(obj,val)
            obj.CRCType=val;
        end

    end

    methods(Access=public)
        function latency=getLatency(obj)
            latency=(obj.crclen/obj.datalen)*(3)+5;
        end
    end

    methods(Access=protected)

        function flag=getExecutionSemanticsImpl(~)
            flag={'Classic','Synchronous'};
        end

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function resetImpl(obj)
            reset(obj.commHDLCRCGenerator);
            reset(obj.commHDLCRCGenerator1);
            obj.dataReg(:)=0;
            obj.endReg(:)=0;
            obj.flipFlop(:)=0;
            obj.startOutReg(:)=0;
            obj.startOut(:)=0;
            obj.endOut(:)=0;
            obj.validOut(:)=0;
            obj.dataOut(:)=0;
            obj.startInReg(:)=0;
            obj.validInReg(:)=0;
            obj.endInReg(:)=0;
            obj.datadelayReg(:)=0;
            obj.startDelayReg(:)=0;
            obj.endInReg2(:)=0;
            obj.delayCRCReg(:)=0;
            obj.dataInReg(:)=0;
            obj.crcReg(:)=0;
            obj.dataOutReg(:)=0;
            obj.crcInReg(:)=0;
            obj.crcBaseReg(:)=0;
            obj.endDelay(:)=0;
            obj.err(:)=0;
        end

        function setupImpl(obj,dataIn)

            obj.Poly_Opt=getPoly(obj);
            obj.crclen=length(obj.Poly_Opt)-1;

            obj.isScalarIn=isscalar(dataIn);
            obj.isIntIn=obj.isScalarIn&&~isa(dataIn,'double')&&~isa(dataIn,'logical')&&~isa(dataIn,'single');

            if~obj.isIntIn
                obj.datalen=coder.const(length(dataIn));
            end

            if isempty(coder.target)||~eml_ambiguous_types
                obj.dataclass=class(dataIn);
                obj.isUInt=~isempty(strfind(obj.dataclass,'uint'));
                if obj.isIntIn
                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(dataIn));
                end
            end


            if obj.FullCheckSum
                obj.err=fi(0,0,24,0);
            else
                obj.err=false;
            end

            obj.depth=round(obj.crclen/obj.datalen);
            obj.crcMask=fi(0,0,24,0);

            obj.startInReg=false;
            obj.validInReg=false;
            obj.endInReg=false;

            obj.startOut=false(2,1);
            obj.endOut=false(2,1);
            obj.validOut=false(2,1);

            obj.endDelay=false;

            if obj.isScalarIn
                obj.datadelayReg=cast(false(1,obj.depth),'like',dataIn);
                obj.dataInReg=cast(false(1,1),'like',dataIn);
                obj.delayCRCReg=cast(false(1,obj.depth+2),'like',dataIn);
                obj.dataReg=cast(false(1,obj.depth),'like',dataIn);
                obj.crcReg=cast(false(1,obj.depth),'like',dataIn);
                obj.dataOutReg=cast(false(1,obj.depth),'like',dataIn);
                obj.crcInReg=cast(false(1,obj.depth),'like',dataIn);
                obj.crcBaseReg=cast(false(1,obj.depth),'like',dataIn);
                obj.dataOut=cast(false(1,2),'like',dataIn);
                obj.maskBits=cast(false(1,obj.depth),'like',dataIn);
            else
                obj.dataOut=cast(false(obj.datalen,2),'like',dataIn);
                obj.dataInReg=cast(false(obj.datalen,1),'like',dataIn);
                obj.datadelayReg=cast(false(obj.datalen,obj.depth),'like',dataIn);
                obj.delayCRCReg=cast(false(obj.datalen,obj.depth+2),'like',dataIn);
                obj.dataReg=cast(false(obj.datalen,obj.depth),'like',dataIn);
                obj.crcReg=cast(false(obj.datalen,obj.depth),'like',dataIn);
                obj.dataOutReg=cast(false(obj.datalen,obj.depth),'like',dataIn);
                obj.crcInReg=cast(false(obj.datalen,obj.depth),'like',dataIn);
                obj.crcBaseReg=cast(false(obj.datalen,obj.depth),'like',dataIn);
                obj.maskBits=cast(false(obj.datalen,obj.depth),'like',dataIn);
            end

            obj.startOutReg=false(obj.depth,1);
            obj.startDelayReg=false(obj.depth,1);
            obj.endInReg2=false(obj.depth,1);
            obj.endReg=false;
            obj.flipFlop=false;


            p=coder.const(feval('int2bit',(0),(obj.crclen)).');
            obj.commHDLCRCGenerator=commhdl.internal.CRCGenerator(...
            'Polynomial',obj.Poly_Opt,...
            'InitialState',obj.InitialState,...
            'DirectMethod',obj.DirectMethod,...
            'ReflectInput',obj.ReflectInput,...
            'ReflectCRCChecksum',obj.ReflectCRCChecksum,...
            'FinalXORValue',p);

            obj.commHDLCRCGenerator1=commhdl.internal.CRCGenerator(...
            'Polynomial',obj.Poly_Opt,...
            'InitialState',obj.InitialState,...
            'DirectMethod',obj.DirectMethod,...
            'ReflectInput',obj.ReflectInput,...
            'ReflectCRCChecksum',obj.ReflectCRCChecksum,...
            'FinalXORValue',p);
        end

        function varargout=outputImpl(obj,varargin)

            varargout{1}=obj.dataOut(:,1);
            varargout{2}.start=obj.startOut(1);
            varargout{2}.end=obj.endOut(1);
            varargout{2}.valid=obj.validOut(1);
            varargout{3}=obj.err;
        end

        function updateImpl(obj,varargin)

            data=obj.dataInReg(:,1);
            ctrl.start=obj.startInReg(1);
            ctrl.end=obj.endInReg(1);
            ctrl.valid=obj.validInReg(1);

            obj.dataInReg(:,1:end-1)=obj.dataInReg(:,2:end);
            obj.dataInReg(:,end)=varargin{1};

            obj.startInReg(1:end-1)=obj.startInReg(2:end);
            obj.startInReg(end)=varargin{2}.start;

            obj.endInReg(1:end-1)=obj.endInReg(2:end);
            obj.endInReg(end)=varargin{2}.end;

            obj.validInReg(1:end-1)=obj.validInReg(2:end);
            obj.validInReg(end)=varargin{2}.valid;

            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)

                finxorval=varargin{3};

                if varargin{2}.start&&varargin{2}.valid
                    obj.crcMask(:)=finxorval;
                end

                obj.maskBits(:)=maskCalculation(obj,obj.crcMask);
            end

            ctrlCRCGen.start=startDelayEnable(obj,ctrl.start,ctrl.valid);
            ctrlCRCGen.end=ctrl.end;
            ctrlCRCGen.valid=ctrl.valid;

            data_shift=lockdataIn(obj,data,ctrl);

            if isa(varargin{1},'double')||isa(varargin{1},'single')
                [~,~]=step(obj.commHDLCRCGenerator1,varargin{1},varargin{2});
            end

            [dataoutCRCGen,ctrloutCRCGen]=step(...
            obj.commHDLCRCGenerator,data_shift,ctrlCRCGen);

            endindelay=delayendIn(obj,ctrl.end)||ctrl.valid;

            dctrl.start=false;
            dctrl.end=false;
            dctrl.valid=endindelay;

            crcin=lockCRCIn(obj,data,dctrl);

            crcindelay=delayCRC(obj,crcin);

            startoutTemp=lockstartOut(obj,ctrloutCRCGen.start,ctrloutCRCGen.valid);

            validoutTemp=setResetFF(obj,startoutTemp,ctrloutCRCGen.end,ctrloutCRCGen.valid,ctrloutCRCGen.start);

            dataoutTemp=lockdataOut(obj,dataoutCRCGen,ctrloutCRCGen.valid,validoutTemp);

            enmask=obj.endDelay(1)||ctrloutCRCGen.end||ctrloutCRCGen.valid;

            obj.endDelay(1:end-1)=obj.endDelay(2:end);
            obj.endDelay(end)=ctrloutCRCGen.end&&validoutTemp;

            mask=maskGenerator(obj,dataoutCRCGen,crcindelay,enmask,ctrl.start);

            if(obj.datalen==1)||~obj.isScalarIn
                pow2=reshape(2.^(obj.crclen-1:-1:0),obj.datalen,obj.depth);
                zz=zeros(obj.datalen,obj.depth);
            else
                pow2=fliplr(2.^(obj.datalen.*(0:obj.depth-1)));
                zz=zeros(1,obj.depth);
            end

            if obj.endOut(2)
                errword=fi(sum(sum(mask.*pow2)),0,24,0);
                errbool=any(any((mask~=zz)));
            else
                errword=fi(0,0,24,0);
                errbool=false;
            end

            if obj.FullCheckSum
                obj.err(:)=errword;
            else
                obj.err(:)=errbool;
            end

            obj.dataOut(:,1:end-1)=obj.dataOut(:,2:end);
            obj.dataOut(:,end)=dataoutTemp;

            obj.startOut(1:end-1)=obj.startOut(2:end);
            obj.startOut(end)=startoutTemp;

            obj.endOut(1:end-1)=obj.endOut(2:end);
            obj.endOut(end)=ctrloutCRCGen.end&&validoutTemp;

            obj.validOut(1:end-1)=obj.validOut(2:end);
            obj.validOut(end)=validoutTemp;

            if~obj.validOut(1)
                obj.dataOut(:,1)=0;
            end

        end

        function maskout=maskGenerator(obj,crcbase,crcin,enable,reset)

            maskout=bitxor(double(obj.crcBaseReg),double(obj.crcInReg));

            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)
                maskout=bitxor(double(maskout),double(obj.maskBits));
            end

            if reset
                obj.crcBaseReg(:,:)=false;
                obj.crcInReg(:,:)=false;
            elseif enable
                obj.crcBaseReg(:,1:end-1)=obj.crcBaseReg(:,2:end);
                obj.crcInReg(:,1:end-1)=obj.crcInReg(:,2:end);

                obj.crcBaseReg(:,end)=crcbase;
                obj.crcInReg(:,end)=crcin;
            end
        end

        function maskBits=maskCalculation(obj,crcMask)
            maskbits=comm.internal.utilities.de2biBase2LeftMSB(double(crcMask),obj.crclen)';
            y=(obj.crclen)/obj.datalen;
            maskBits=zeros(1,y);
            x=[];
            if obj.datalen~=1
                if obj.isScalarIn
                    x=fi(reshape(maskbits,obj.datalen,y),0,1,0);
                    for i=1:size(x,2)
                        maskBits(i)=bitconcat(x(:,i));
                    end
                else
                    maskBits=reshape(maskbits,obj.datalen,y);
                end
            else
                maskBits=maskbits;
            end

        end

        function y=startDelayEnable(obj,data,enable)
            y=obj.startDelayReg(1)&&enable;
            if enable
                obj.startDelayReg(1:end-1)=obj.startDelayReg(2:end);
                obj.startDelayReg(end)=data;
            end
        end

        function dataout=lockdataIn(obj,data,ctrl)
            if ctrl.valid
                dataout=obj.dataReg(:,1);
            else
                if obj.isScalarIn
                    dataout=cast(0,'like',data);
                else
                    dataout=cast(zeros(obj.datalen,1),'like',data);
                end
            end

            if ctrl.valid
                obj.dataReg(:,1:end-1)=obj.dataReg(:,2:end);
                obj.dataReg(:,end)=data;
            end

        end

        function endout=delayendIn(obj,data)
            endout=any(obj.endInReg2)||data;
            obj.endInReg2(1:end-1)=obj.endInReg2(2:end);
            obj.endInReg2(end)=data;
        end

        function crcout=lockCRCIn(obj,data,ctrl)
            if ctrl.valid
                crcout=obj.crcReg(:,1);
            else
                if obj.isScalarIn
                    crcout=cast(0,'like',data);
                else
                    crcout=cast(zeros(obj.datalen,1),'like',data);
                end

            end
            if ctrl.valid
                obj.crcReg(:,1:end-1)=obj.crcReg(:,2:end);
                obj.crcReg(:,end)=data;
            end
        end

        function y=delayCRC(obj,data)
            y=obj.delayCRCReg(:,1);

            obj.delayCRCReg(:,1:end-1)=obj.delayCRCReg(:,2:end);
            obj.delayCRCReg(:,end)=data;
        end

        function startout=lockstartOut(obj,data,enable)
            startout=obj.startOutReg(1)&&enable;

            if enable
                obj.startOutReg(1:end-1)=obj.startOutReg(2:end);
                obj.startOutReg(end)=data;
            end
        end

        function y=setResetFF(obj,start,reset,valid,resetGlobal)

            y=valid&&(start||(not(obj.endReg(1))&&obj.flipFlop(1))&&not(resetGlobal));
            if resetGlobal
                obj.flipFlop=false;
                obj.endReg=false;
            else
                obj.endReg(1:end-1)=obj.endReg(2:end);
                obj.flipFlop(1:end-1)=obj.flipFlop(2:end);
                obj.flipFlop(end)=start||(not(obj.endReg(1))&&obj.flipFlop(1));
                obj.endReg(end)=reset;
            end

        end

        function dataout=lockdataOut(obj,data,enable,gatedata)
            if enable&&gatedata
                dataout=obj.dataOutReg(:,1);
            else
                if obj.isScalarIn
                    dataout=cast(0,'like',data);
                else
                    dataout=cast(zeros(obj.datalen,1),'like',data);
                end
            end
            if enable
                obj.dataOutReg(:,1:end-1)=obj.dataOutReg(:,2:end);
                obj.dataOutReg(:,end)=data;
            end
        end

        function y=getPoly(obj)
            if strcmp(obj.CRCType,'CRC6')
                y=[1,1,0,0,0,0,1];
            elseif strcmp(obj.CRCType,'CRC11')
                y=[1,1,1,0,0,0,1,0,0,0,0,1];
            elseif strcmp(obj.CRCType,'CRC16')
                y=[1,0,0,0,1,0,0,0,0,0,0,1,0,0,0,0,1];
            elseif strcmp(obj.CRCType,'CRC24A')
                y=[1,1,0,0,0,0,1,1,0,0,1,0,0,1,1,0,0,1,1,1,1,1,0,1,1];
            elseif strcmp(obj.CRCType,'CRC24B')
                y=[1,1,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,1,1,0,0,0,1,1];
            else
                y=[1,1,0,1,1,0,0,1,0,1,0,1,1,0,0,0,1,0,0,0,1,0,1,1,1];
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            props={};
            switch~(strcmp(obj.CRCType,'CRC24C'))
            case 1
                props={'EnableCRCMaskPort'};
            end
            flag=ismember(prop,props);
        end

        function validateInputsImpl(obj,varargin)

            dataIn=varargin{1};
            ctrlIn=varargin{2};

            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)
                crcmask=varargin{3};
                validateattributes(crcmask,{'embedded.fi'},{'scalar','integer'},'NRCRCDecoder','CRCMask');
                if isa(crcmask,'embedded.fi')
                    if(issigned(crcmask))
                        coder.internal.error('whdl:NRCRCDecoder:InvalidSignedType');
                    end
                end
                coder.internal.errorIf(crcmask.WordLength~=24,...
                'whdl:NRCRCDecoder:InvMaskFixptExpected',tostringInternalSlName(crcmask.numerictype));

                coder.internal.errorIf(crcmask.FractionLength~=0,...
                'whdl:NRCRCDecoder:InvMaskFixptExpected',tostringInternalSlName(crcmask.numerictype));
            end

            obj.Poly_Opt=getPoly(obj);
            obj.crclen=length(obj.Poly_Opt)-1;
            isScalar=isscalar(dataIn);
            obj.isIntIn=isScalar&&~isa(dataIn,'double')&&~isa(dataIn,'logical')&&~isa(dataIn,'single');

            if~obj.isIntIn
                obj.datalen=coder.const(length(dataIn));
            end

            if isempty(coder.target)||~eml_ambiguous_types

                obj.dataclass=class(dataIn);
                obj.isUInt=~isempty(strfind(obj.dataclass,'uint'));
                if isa(dataIn,'embedded.fi')
                    if(issigned(dataIn))
                        coder.internal.error('whdl:NRCRCDecoder:InvalidSignedType');
                    end
                end
                if obj.isIntIn
                    validateattributes(dataIn,{'uint8','uint16','uint32','uint64','embedded.fi'},{'scalar','integer'},'NRCRCDecoder','data');
                else
                    validateattributes(dataIn,{'logical','double','single','embedded.fi'},{'vector','binary','column'},'NRCRCDecoder','data');
                end

                if~obj.isIntIn&&dsphdlshared.hdlgetwordsizefromdata(dataIn)>1
                    validateattributes(dataIn,{'embedded.fi'},{'scalar','binary','column'},'NRCRCDecoder','data');
                end
                if obj.isIntIn
                    obj.datalen=coder.const(dsphdlshared.hdlgetwordsizefromdata(dataIn));
                    if~obj.isUInt
                        coder.internal.errorIf(dataIn.FractionLength~=0,...
                        'whdl:NRCRCDecoder:InvFixptExpected');
                    end
                end


                coder.internal.errorIf(mod(obj.crclen,obj.datalen)~=0,...
                'whdl:NRCRCDecoder:InvDataWidth');


                if~isstruct(ctrlIn)
                    coder.internal.error('whdl:NRCRCDecoder:InvalidSampleCtrlBus');
                end

                ctrlNames=fieldnames(ctrlIn);
                if~isequal(numel(ctrlNames),3)
                    coder.internal.error('whdl:NRCRCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{1})&&strcmp(ctrlNames{1},'start')
                    validateattributes(ctrlIn.start,{'logical'},{'scalar'},'NRCRCDecoder','start');
                else
                    coder.internal.error('whdl:NRCRCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{2})&&strcmp(ctrlNames{2},'end')
                    validateattributes(ctrlIn.end,{'logical'},{'scalar'},'NRCRCDecoder','end');
                else
                    coder.internal.error('whdl:NRCRCDecoder:InvalidSampleCtrlBus');
                end

                if isfield(ctrlIn,ctrlNames{3})&&strcmp(ctrlNames{3},'valid')
                    validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'NRCRCDecoder','valid');
                else
                    coder.internal.error('whdl:NRCRCDecoder:InvalidSampleCtrlBus');
                end
                obj.inDisp=~isempty(dataIn);
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked

                s.commHDLCRCGenerator=matlab.System.saveObject(obj.commHDLCRCGenerator);
                s.startOutReg=obj.startOutReg;
                s.dataReg=obj.dataReg;
                s.endReg=obj.endReg;
                s.flipFlop=obj.flipFlop;
                s.startOut=obj.startOut;
                s.endOut=obj.endOut;
                s.validOut=obj.validOut;
                s.dataOut=obj.dataOut;

                s.datadelayReg=obj.datadelayReg;
                s.startInReg=obj.startInReg;
                s.validInReg=obj.validInReg;
                s.endInReg=obj.endInReg;

                s.startDelayReg=obj.startDelayReg;
                s.endInReg2=obj.endInReg2;
                s.delayCRCReg=obj.delayCRCReg;
                s.dataInReg=obj.dataInReg;
                s.crcReg=obj.crcReg;
                s.dataOutReg=obj.dataOutReg;
                s.crcInReg=obj.crcInReg;
                s.crcBaseReg=obj.crcBaseReg;
                s.endDelay=obj.endDelay;
                s.err=obj.err;
            end
        end

        function loadObjectImpl(obj,s,wasLocked)
            if wasLocked
                obj.commHDLCRCGenerator=matlab.System.loadObject(s.commHDLCRCGenerator);
                s=rmfield(s,'commHDLCRCGenerator');
                obj.commHDLCRCGenerator1=matlab.System.loadObject(s.commHDLCRCGenerator1);
                s=rmfield(s,'commHDLCRCGenerator1');
            end
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

        function num=getNumInputsImpl(obj)
            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)
                num=3;
            else
                num=2;
            end
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function icon=getIconImpl(obj)
            if isempty(obj.inDisp)
                icon='NR CRC Decoder\nLatency = --';
            else
                icon=['NR CRC Decoder\nLatency = ',num2str(getLatency(obj))];
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            if(strcmp(obj.CRCType,'CRC24C')&&obj.EnableCRCMaskPort)
                varargout{3}='CRCMask';
            end
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            varargout{3}='err';
        end

        function varargout=getOutputSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=propagatedInputSize(obj,2);
            varargout{3}=1;

        end

        function varargout=isOutputComplexImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputComplexity(obj,1);
            varargout{2}=propagatedInputComplexity(obj,2);
            varargout{3}=false;
        end

        function varargout=getOutputDataTypeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputDataType(obj,1);
            varargout{2}=samplecontrolbustype;
            if obj.FullCheckSum
                varargout{3}=numerictype(0,24,0);
            else
                varargout{3}='logical';
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            numOuts=getNumOutputs(obj);
            varargout=cell(1,numOuts);
            varargout{1}=propagatedInputFixedSize(obj,1);
            varargout{2}=propagatedInputFixedSize(obj,2);
            varargout{3}=1;
        end

    end

    methods(Static,Access=protected)
        function header=getHeaderImpl

            header=matlab.system.display.Header('nrhdl.internal.NRCRCDecoder',...
            'Title','NR CRC Decoder',...
            'ShowSourceLink',false,...
            'Text',...
            sprintf('Detect errors in input data using CRC.'));

        end

        function group=getPropertyGroupsImpl

            group=matlab.system.display.Section(...
            'Title','Parameters',...
            'PropertyList',{'CRCType','FullCheckSum','EnableCRCMaskPort'});
        end

        function isVisible=showSimulateUsingImpl

            isVisible=false;
        end
    end

end
