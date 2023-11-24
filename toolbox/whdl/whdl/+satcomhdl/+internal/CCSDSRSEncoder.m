classdef(StrictDefaults)CCSDSRSEncoder<matlab.System

%#codegen

    properties(Nontunable)

        MessageLength='223';

        InterleavingDepth='1';
    end

    properties(Hidden,Constant)
        MessageLengthSet=matlab.system.StringSet(...
        {'223','239'});
        InterleavingDepthSet=matlab.system.StringSet(...
        {'1','2','3','4','5','8'});
    end

    properties(Access=private,Constant)

        maxCodeLen=255;

        numPackets=2;

        latency=3;
    end

    properties(Nontunable,Access=private)

msgLen

intrlvDepth

errCapability

numParitySym

maxCodeBlkLen

maxMsgBlkLen

nextFrameLowTime

inPorts
    end

    properties(Access=private)

genPolyBeta
betaPow8


inputLen
packetValid


nextFrame
forceEnd
InPacket
counterLoad
firstStart


wrIntrlvIndex
rdIntrlvIndex
nextFrameCount
sampleCount
latencyCount
packetWrAddr
packetRdAddr
outputCount
outputRegCount
inputRegCount
remainderCount


dataInReg
validInReg
remainder
    end


    methods(Access=public)
        function latency=getLatency(~)
            latency=3;
        end
    end

    methods

        function obj=CCSDSRSEncoder(varargin)
            coder.allowpcode('plain');
            if coder.target('MATLAB')
                if~(builtin('license','checkout','LTE_HDL_Toolbox'))
                    error(message('whdl:whdl:NoLicenseAvailable'));
                end
            else
                coder.license('checkout','LTE_HDL_Toolbox');
            end

            setProperties(obj,nargin,varargin{:});
        end
    end

    methods(Access=protected)

        function supported=supportsMultipleInstanceImpl(~)

            supported=true;
        end

        function setupImpl(obj)
            obj.msgLen=str2double(obj.MessageLength);

            switch obj.InterleavingDepth
            case '2'
                obj.intrlvDepth=2;
            case '3'
                obj.intrlvDepth=3;
            case '4'
                obj.intrlvDepth=4;
            case '5'
                obj.intrlvDepth=5;
            case '8'
                obj.intrlvDepth=8;
            otherwise
                obj.intrlvDepth=1;
            end


            if(obj.msgLen==239)
                obj.errCapability=8;
                obj.numParitySym=16*obj.intrlvDepth;
                obj.maxMsgBlkLen=239*obj.intrlvDepth;
            else
                obj.errCapability=16;
                obj.numParitySym=32*obj.intrlvDepth;
                obj.maxMsgBlkLen=223*obj.intrlvDepth;
            end

            obj.maxCodeBlkLen=obj.maxCodeLen*obj.intrlvDepth;
            obj.wrIntrlvIndex=fi(0,0,nextpow2(obj.intrlvDepth+1),0);
            obj.rdIntrlvIndex=fi(0,0,nextpow2(obj.intrlvDepth+1),0);



            coder.extrinsic('HDLCCSDSRSCodeTables');
            if isempty(coder.target)
                [tgenPolyBeta,tbetaPow8]=HDLCCSDSRSCodeTables(obj.msgLen);
            else
                [tgenPolyBeta,tbetaPow8]=coder.internal.const(HDLCCSDSRSCodeTables(obj.msgLen));
            end
            obj.genPolyBeta=logical(int2bit(tgenPolyBeta',8,false)');
            obj.betaPow8=logical(int2bit(tbetaPow8,8,false)');

            obj.nextFrameLowTime=obj.numParitySym;
            obj.resetStates;
        end


        function resetStates(obj)
            obj.nextFrame=true;
            obj.firstStart=true;
            obj.nextFrameCount=fi(0,0,nextpow2(obj.numParitySym+1),0);
            obj.latencyCount=fi(zeros(obj.numPackets,1),0,nextpow2(obj.latency+1),0);
            obj.sampleCount=fi(0,0,nextpow2(obj.maxMsgBlkLen+1),0);
            obj.inputLen=fi(ones(obj.numPackets,1)*obj.maxMsgBlkLen,0,nextpow2(obj.maxMsgBlkLen+1),0);
            obj.dataInReg=fi(zeros(obj.latency,1),0,8,0);
            obj.validInReg=false(obj.latency,1);
            obj.remainder=fi((zeros(2*obj.errCapability,obj.intrlvDepth,obj.numPackets)),0,8,0);
            obj.packetWrAddr=fi(1,0,nextpow2(obj.numPackets+1),0);
            obj.packetRdAddr=fi(1,0,nextpow2(obj.numPackets+1),0);
            obj.outputCount=fi(0,0,nextpow2(obj.maxCodeBlkLen+1),0);
            obj.outputRegCount=fi(0,0,nextpow2(obj.latency+1),0);
            obj.inputRegCount=fi(0,0,nextpow2(obj.latency+1),0);
            obj.remainderCount=fi(0,0,nextpow2(2*obj.errCapability+1),0);
            obj.packetValid=false(obj.numPackets,1);
            obj.InPacket=false;
            obj.counterLoad=false;
            obj.forceEnd=false;
        end

        function resetImpl(obj)

            obj.resetStates;
        end


        function varargout=outputImpl(obj,varargin)
            x=varargin{1};


            y=cast(0,'like',x);
            startOut=false;
            endOut=false;
            validOut=false;



            if(obj.latencyCount(obj.packetRdAddr)==obj.latency)

                if(obj.outputCount<obj.inputLen(obj.packetRdAddr))

                    if(obj.outputRegCount==obj.latency)
                        obj.outputRegCount(:)=1;
                    else
                        obj.outputRegCount(:)=obj.outputRegCount+1;
                    end

                    if(obj.validInReg(obj.outputRegCount))
                        obj.outputCount(:)=obj.outputCount+1;

                        if(obj.outputCount==1)
                            startOut=true;
                        end

                        y=cast(obj.dataInReg(obj.outputRegCount),'like',x);
                        validOut=true;
                    end

                elseif(obj.outputCount<obj.inputLen(obj.packetRdAddr)+obj.numParitySym)

                    obj.outputCount(:)=obj.outputCount+1;

                    if(obj.rdIntrlvIndex==obj.intrlvDepth)
                        obj.rdIntrlvIndex(:)=1;
                    else
                        obj.rdIntrlvIndex(:)=obj.rdIntrlvIndex+1;
                    end

                    if(obj.rdIntrlvIndex==1)
                        if(obj.remainderCount==2*obj.errCapability)
                            obj.remainderCount(:)=1;
                        else
                            obj.remainderCount(:)=obj.remainderCount+1;
                        end
                    end

                    y=cast(fi(obj.remainder(obj.remainderCount,obj.rdIntrlvIndex,obj.packetRdAddr),0,9,0),'like',x);
                    validOut=true;

                    if(obj.outputCount==obj.inputLen(obj.packetRdAddr)+obj.numParitySym)
                        endOut=true;


                        obj.rdIntrlvIndex(:)=0;
                        obj.remainderCount(:)=0;
                        obj.outputCount(:)=0;
                        obj.inputLen(obj.packetRdAddr,:)=obj.maxMsgBlkLen;
                        obj.latencyCount(obj.packetRdAddr,:)=0;
                        obj.packetValid(obj.packetRdAddr)=false;


                        if(obj.packetRdAddr==obj.numPackets)
                            obj.packetRdAddr(:)=1;
                        else
                            obj.packetRdAddr(:)=obj.packetRdAddr+1;
                        end

                    end
                end
            end

            ctrl.start=startOut;
            ctrl.end=endOut;
            ctrl.valid=validOut;

            varargout{1}=y;
            varargout{2}=ctrl;
            varargout{3}=obj.nextFrame;
        end

        function updateImpl(obj,varargin)

            data=varargin{1};
            dataIn=fi(varargin{1},0,8,0);
            ctrl=varargin{2};

            startIn=ctrl.start;
            endIn=ctrl.end;
            validIn=ctrl.valid;

            if(validIn)



                if(isa(data,'double')||isa(data,'single'))
                    if(data<0||...
                        round(data)~=data||...
                        data>255)
                        coder.internal.warning('whdl:CCSDSRSEncoder:InvalidInputData');
                    end
                end
            end


            if isempty(obj.nextFrame)
                obj.resetStates;
            end


            if startIn&&validIn
                obj.InPacket=true;
                obj.sampleCount(:)=0;
                if(obj.nextFrame)
                    if(obj.firstStart)
                        obj.firstStart=false;
                    else
                        if(obj.packetWrAddr==obj.numPackets)
                            obj.packetWrAddr(:)=1;
                        else
                            obj.packetWrAddr(:)=obj.packetWrAddr+1;
                        end
                    end
                else


                    coder.internal.warning('whdl:CCSDSRSEncoder:StartNoNextFrame');
                    obj.outputCount(:)=0;
                    obj.rdIntrlvIndex(:)=0;
                    obj.remainderCount(:)=0;
                    obj.outputRegCount(:)=0;
                    obj.inputRegCount(:)=0;
                    obj.nextFrameCount(:)=0;
                end
                obj.remainder(:,:,obj.packetWrAddr)=zeros(2*obj.errCapability,obj.intrlvDepth);
                obj.nextFrame=false;
                obj.wrIntrlvIndex(:)=0;
                obj.counterLoad=false;
                obj.inputLen(obj.packetWrAddr,:)=obj.maxMsgBlkLen;
                obj.latencyCount(obj.packetWrAddr,:)=0;
                obj.packetValid(obj.packetWrAddr)=true;
            end


            if(obj.InPacket)
                if(obj.inputRegCount==obj.latency)
                    obj.inputRegCount(:)=1;
                else
                    obj.inputRegCount(:)=obj.inputRegCount+1;
                end


                obj.dataInReg(obj.inputRegCount,:)=dataIn;
                obj.validInReg(obj.inputRegCount)=validIn;
            end

            if obj.InPacket&&validIn
                obj.sampleCount(:)=obj.sampleCount+1;
                if(obj.sampleCount==obj.maxMsgBlkLen)
                    obj.forceEnd=true;
                end

                if(obj.wrIntrlvIndex==obj.intrlvDepth)
                    obj.wrIntrlvIndex(:)=1;
                else
                    obj.wrIntrlvIndex(:)=obj.wrIntrlvIndex+1;
                end


                inputXORed=bitxor(obj.remainder(1,obj.wrIntrlvIndex,obj.packetWrAddr),dataIn);


                trZG=false(2*obj.errCapability,8);
                zDBits2=logical(int2bit(uint8(inputXORed),8,true)');
                zDBits=repmat(zDBits2,2*obj.errCapability,1);
                for jj=1:8
                    trZG(:,jj)=xorReduce(obj,bitand(zDBits,obj.genPolyBeta(2:end,:)));
                    zDBits=[zDBits(:,2:end),xorReduce(obj,bitand(zDBits,obj.betaPow8))];
                end
                multOut=fi(bit2int(trZG',8,true)',0,8,0);

                obj.remainder(:,obj.wrIntrlvIndex,obj.packetWrAddr)=bitxor([obj.remainder(2:end,obj.wrIntrlvIndex,obj.packetWrAddr);fi(0,0,8,0)],multOut);

            end

            if obj.InPacket&&(endIn||obj.forceEnd)&&validIn

                obj.forceEnd=false;
                obj.InPacket=false;
                obj.inputLen(obj.packetWrAddr,:)=obj.sampleCount;

                if(obj.sampleCount<obj.intrlvDepth)
                    coder.internal.warning('whdl:CCSDSRSEncoder:InvalidInpLen1')

                    if(obj.packetWrAddr==obj.packetRdAddr)
                        obj.outputCount(:)=0;
                        obj.rdIntrlvIndex(:)=0;
                    end
                    obj.outputRegCount(:)=0;
                    obj.inputRegCount(:)=0;
                    obj.inputLen(obj.packetWrAddr,:)=obj.maxMsgBlkLen;
                    obj.latencyCount(obj.packetWrAddr,:)=0;
                    obj.packetValid(obj.packetWrAddr)=false;
                    if(obj.packetWrAddr==1)
                        obj.packetWrAddr(:)=obj.numPackets;
                    else
                        obj.packetWrAddr(:)=obj.packetWrAddr-1;
                    end
                    obj.remainderCount(:)=0;
                    obj.nextFrame=true;
                elseif(mod(obj.sampleCount,fi(obj.intrlvDepth,0,4,0))~=0)
                    coder.internal.warning('whdl:CCSDSRSEncoder:InvalidInpLen2')

                    if(obj.packetWrAddr==obj.packetRdAddr)
                        obj.outputCount(:)=0;
                        obj.rdIntrlvIndex(:)=0;
                    end
                    obj.outputRegCount(:)=0;
                    obj.inputRegCount(:)=0;
                    obj.inputLen(obj.packetWrAddr,:)=obj.maxMsgBlkLen;
                    obj.latencyCount(obj.packetWrAddr,:)=0;
                    obj.packetValid(obj.packetWrAddr)=false;
                    if(obj.packetWrAddr==1)
                        obj.packetWrAddr(:)=obj.numPackets;
                    else
                        obj.packetWrAddr(:)=obj.packetWrAddr-1;
                    end
                    obj.remainderCount(:)=0;
                    obj.nextFrame=true;
                else
                    obj.counterLoad=true;
                end
            end


            if obj.packetValid(obj.packetWrAddr)
                if(obj.latencyCount(obj.packetWrAddr,:)<obj.latency)
                    obj.latencyCount(obj.packetWrAddr,:)=obj.latencyCount(obj.packetWrAddr,:)+1;
                end
            end


            if(obj.counterLoad)
                obj.nextFrameCount(:)=obj.nextFrameCount(:)+1;
                if(obj.nextFrameCount(:)==obj.nextFrameLowTime+1)
                    obj.nextFrameCount(:)=0;
                    obj.counterLoad=false;
                    obj.nextFrame=true;
                end
            end

        end


        function xorOut=xorReduce(~,matrix)
            xorOut=logical(mod(uint8(sum(matrix,2)),2));
        end

        function flag=getExecutionSemanticsImpl(~)

            flag={'Classic','Synchronous'};
        end

        function num=getNumInputsImpl(~)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function s=saveObjectImpl(obj)



            s=saveObjectImpl@matlab.System(obj);


            if obj.isLocked
                s.msgLen=obj.msgLen;
                s.errCapability=obj.errCapability;
                s.intrlvDepth=obj.intrlvDepth;
                s.maxCodeBlkLen=obj.maxCodeBlkLen;
                s.maxMsgBlkLen=obj.maxMsgBlkLen;
                s.nextFrameLowTime=obj.nextFrameLowTime;
                s.numParitySym=obj.numParitySym;
                s.genPolyBeta=obj.genPolyBeta;
                s.betaPow8=obj.betaPow8;
                s.nextFrameCount=obj.nextFrameCount;
                s.sampleCount=obj.sampleCount;
                s.inputLen=obj.inputLen;
                s.counterLoad=obj.counterLoad;
                s.InPacket=obj.InPacket;
                s.firstStart=obj.firstStart;
                s.nextFrame=obj.nextFrame;
                s.wrIntrlvIndex=obj.wrIntrlvIndex;
                s.rdIntrlvIndex=obj.rdIntrlvIndex;
                s.forceEnd=obj.forceEnd;
                s.packetRdAddr=obj.packetRdAddr;
                s.packetWrAddr=obj.packetWrAddr;
                s.packetValid=obj.packetValid;
                s.inPorts=obj.inPorts;
                s.latencyCount=obj.latencyCount;
                s.outputCount=obj.outputCount;
                s.outputRegCount=obj.outputRegCount;
                s.inputRegCount=obj.inputRegCount;
                s.remainderCount=obj.remainderCount;
                s.dataInReg=obj.dataInReg;
                s.validInReg=obj.validInReg;
                s.remainder=obj.remainder;
            end
        end


        function obj=loadObjectImpl(obj,s,wasLocked)



            loadObjectImpl@matlab.System(obj,s,wasLocked);


            if wasLocked
                f=fieldnames(s);
                for ii=1:numel(f)
                    obj.(f{ii})=s.(f{ii});
                end
            end
        end

        function validateInputsImpl(obj,varargin)

            dataIn=varargin{1};
            ctrlIn=varargin{2};


            if isa(dataIn,'embedded.fi')
                if(strcmp(dataIn.Signedness,'Signed')||...
                    dataIn.WordLength~=8||dataIn.FractionLength~=0)
                    coder.internal.error('whdl:CCSDSRSEncoder:InvalidInputDataType');
                end
            elseif~(isa(dataIn,'double')||isa(dataIn,'single')||isa(dataIn,'uint8'))
                coder.internal.error('whdl:CCSDSRSEncoder:InvalidInputDataType');
            end

            if(~isreal(dataIn)||~isscalar(dataIn))
                coder.internal.error('whdl:CCSDSRSEncoder:InvalidInputDataFormat');
            end


            if isstruct(ctrlIn)
                test=fieldnames(ctrlIn);
                truth={'start';'end';'valid'};
                if isequal(test,truth)
                    validateattributes(ctrlIn.start,{'logical'},{'scalar'},'CCSDSRSEncoder','start');
                    validateattributes(ctrlIn.end,{'logical'},{'scalar'},'CCSDSRSEncoder','end');
                    validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'CCSDSRSEncoder','valid');
                else
                    coder.internal.error('whdl:CCSDSRSEncoder:InvalidSampleCtrlBus');
                end
            else
                coder.internal.error('whdl:CCSDSRSEncoder:InvalidSampleCtrlBus');
            end

            obj.inPorts=~isempty(dataIn);
        end


        function icon=getIconImpl(obj)
            if(obj.inPorts)
                icon=sprintf('CCSDS RS Encoder\nLatency = %d',getLatency(obj));
            else
                icon=sprintf('CCSDS RS Encoder\nLatency = --');
            end
        end

        function varargout=getInputNamesImpl(~)
            varargout{1}='data';
            varargout{2}='ctrl';
        end

        function varargout=getOutputNamesImpl(~)
            varargout{1}='data';
            varargout{2}='ctrl';
            varargout{3}='nextFrame';
        end

        function varargout=getOutputSizeImpl(obj)
            varargout{1}=propagatedInputSize(obj,1);
            varargout{2}=[1,1];
            varargout{3}=[1,1];
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout={propagatedInputDataType(obj,1),...
            samplecontrolbustype,'logical'};
        end

        function varargout=isOutputComplexImpl(~)
            varargout{1}=false;
            varargout{2}=false;
            varargout{3}=false;
        end

        function varargout=isOutputFixedSizeImpl(~)
            varargout{1}=true;
            varargout{2}=true;
            varargout{3}=true;
        end


    end

    methods(Access=protected,Static)

        function header=getHeaderImpl
            text1='Encode message into Reed-Solomon (RS) codeword according to the CCSDS standard.';
            header=matlab.system.display.Header('satcomhdl.internal.CCSDSRSEncoder',...
            'Title','CCSDS RS Encoder',...
            'Text',text1,...
            'ShowSourceLink',false);
        end

        function group=getPropertyGroupsImpl

            group=matlab.system.display.Section(...
            'Title','Parameters','PropertyList',{'MessageLength','InterleavingDepth'});
        end

        function flag=showSimulateUsingImpl

            flag=false;
        end

    end
end