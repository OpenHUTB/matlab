classdef(StrictDefaults)PolarDecoder<matlab.System
%#codegen





    properties(Nontunable)

        LinkDirection='Downlink';


        ListLength='2';


        ConfigurationSource='Property';


        MessageLength=56;

        Rate=864;

        DebugPortsEn=0;


        RNTIPort(1,1)logical=false;

        TargetRNTIPort(1,1)logical=false;

        OutputCRCBits(1,1)logical=false;
    end

    properties(Nontunable,Access=private)
        CoreOrder=16;
        DupLimOpts=[6,7,8];
        DupLim;
        infoDecCyclesOpts=[3,5,8];
        infoDecCycles;

        ListLengthInt;
        DownlinkMode;
        ConfigFromPort;



        reinterpType;

        inDisp;


        nMax;
        iIL;
        TreeDepth;

        CrcPolyOpts={[1,1,0,1,1,0,0,1,0,1,0,1,1,0,0,0,1,0,0,0,1,0,1,1,1]',...
        [1,1,0,0,0,0,1]',...
        [1,1,1,0,0,0,1,0,0,0,0,1]'};




        CrcLen;

        LOAD=0;
        LATENCY_MATCH=1;
        OUTPUT=2;

        StageIts;
    end

    properties(Constant,Hidden)
        LinkDirectionSet=matlab.system.StringSet({...
        'Downlink',...
        'Uplink'});

        ConfigurationSourceSet=matlab.system.StringSet({...
        'Property',...
        'Input port'});

        ListLengthSet=matlab.system.StringSet({...
        '2',...
        '4',...
        '8'});
    end

    properties(Access=private)
        KPort;
        EPort;

        SorterOps;

        targetRnti;


        K;
        E;
        N;
        n;
        F;
        ItlvMap;

        ValidConfig;
        Configured;

        DecoderState;

        ConfigLatency;
        ProcLatency;
        PathSelLatency;

        DupIndices;
        activePaths;

        Started;
        channelLoaded;
        CrcAndOutput;


        ChannelMemory;
        ChannelMemoryIdx;
        ChannelBuffer;
        ChannelBufferIdx;


        AlphaMem;
        BetaMem;
        BetaProp;
        PathMem;

        Metrics;

        SelPath;
        SelCrcErr;


        ConfigLatencyCount;
        ProcLatencyCount;
        PathSelLatencyCount;
        OutputCount;

        PrevK;

        ParityCheck;
PrevParityCheck
        Qpc;


        DataOutReg;
        StartReg;
        EndReg;
        ValidReg;
        ErrReg;
        NextFrameReg;

DebugPipe
        DecLlrReg;
        DecLlrValidReg;


        DecLlrs;
        DecLlrIdx;


        OutputSoftDec;
        rdBlkAddr;
        rdStage;
        stageCounter;
        leafCount;
        pathIdx;
        PathCnt;
    end

    methods(Access=public)
        function latency=getLatency(obj,varargin)
            latency=[];
            if~obj.ConfigFromPort
                latency=getProcLatency(obj)+getPathSelLatency(obj)+obj.N+1;
            end
        end
    end

    methods
        function obj=PolarDecoder(varargin)
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

        function[dataOut,ctrlOut,err,nextFrame,decLlr,decLlrValid]=outputImpl(obj,varargin)
            dataOut=obj.DataOutReg;
            ctrlOut.start=obj.StartReg;
            ctrlOut.end=obj.EndReg;
            ctrlOut.valid=obj.ValidReg;
            err=obj.ErrReg;
            nextFrame=obj.NextFrameReg;

            decLlr=obj.DecLlrReg(:,1);
            decLlrValid=obj.DecLlrValidReg(1);

        end

        function updateImpl(obj,varargin)
            dataIn=varargin{1};
            ctrlIn=varargin{2};

            if isa(dataIn,'double')||isa(dataIn,'single')
                dataInReinterp=dataIn;
            else

                dataInReinterp=reinterpretcast(dataIn,obj.reinterpType);
            end

            if ctrlIn.start&&ctrlIn.valid
                if obj.ConfigFromPort
                    obj.KPort=double(varargin{3});
                    obj.EPort=double(varargin{4});

                    if obj.DownlinkMode
                        KIn=mod(obj.KPort,256);
                    else
                        KIn=obj.KPort;
                    end

                    EIn=obj.EPort;

                    if obj.K~=KIn||obj.E~=EIn
                        obj.K=KIn;
                        obj.E=EIn;
                        configure(obj);
                        validatePortConfig(obj);
                        obj.ConfigLatency=getConfigLatency(obj);
                        obj.ConfigLatencyCount=0;
                        obj.Configured=false;
                    elseif obj.Configured
                        obj.ConfigLatency=0;
                        obj.ConfigLatencyCount=0;
                    end
                end

                if obj.TargetRNTIPort&&obj.DownlinkMode
                    obj.targetRnti=double(varargin{end});
                end
                obj.channelLoaded=false;
                obj.NextFrameReg=false;
                obj.DecoderState=obj.LOAD;
            end

            switch obj.DecoderState
            case obj.LOAD
                done=channelLoader(obj,dataInReinterp,ctrlIn);
                if done
                    obj.channelLoaded=true;
                end
                if obj.channelLoaded&&~obj.CrcAndOutput&&obj.ConfigLatencyCount>=obj.ConfigLatency

                    [obj.SelPath(1:obj.K,1),obj.SelCrcErr]=polarDecode(obj);
                    obj.DecoderState=obj.LATENCY_MATCH;
                    obj.ProcLatencyCount=0;
                    obj.ConfigLatencyCount=0;
                    obj.channelLoaded=false;
                    obj.Configured=true;


                    obj.ProcLatency=getProcLatency(obj);

                    if obj.DebugPortsEn
                        obj.rdStage=obj.n-1;
                    end
                else
                    if obj.ConfigLatencyCount==obj.ConfigLatency
                        obj.Configured=true;
                    else
                        obj.ConfigLatencyCount=obj.ConfigLatencyCount+1;
                    end
                end
            case obj.LATENCY_MATCH
                if obj.ProcLatencyCount==obj.ProcLatency
                    obj.DecoderState=obj.LOAD;
                    obj.OutputCount=0;
                    obj.PathSelLatencyCount=0;
                    obj.PrevK=obj.K;
                    obj.PrevParityCheck=obj.ParityCheck;

                    if obj.ConfigFromPort
                        obj.PathSelLatency=getPathSelLatency(obj);
                    end

                    obj.CrcAndOutput=true;
                    obj.NextFrameReg=true;

                    if obj.DebugPortsEn
                        obj.OutputSoftDec=0;
                        obj.rdBlkAddr=0;
                        obj.rdStage=0;
                        obj.stageCounter=0;
                        obj.leafCount=0;
                        obj.pathIdx=0;
                        obj.PathCnt=0;
                        obj.DecLlrIdx=0;
                        obj.DecLlrReg(:,4)=0;
                    end
                else
                    obj.ProcLatencyCount=obj.ProcLatencyCount+1;

                    if obj.DebugPortsEn
                        if obj.OutputSoftDec
                            if obj.DecLlrIdx<obj.N
                                if obj.stageCounter==0
                                    obj.DecLlrReg(:,obj.DebugPipe)=obj.DecLlrs(:,obj.DecLlrIdx+1);
                                    obj.DecLlrValidReg(obj.DebugPipe)=1;
                                else
                                    obj.DecLlrReg(:,obj.DebugPipe)=0;
                                    obj.DecLlrValidReg(obj.DebugPipe)=0;
                                end

                                if obj.F(obj.leafCount+1)
                                    if obj.stageCounter==obj.infoDecCycles-1
                                        decMade=true;

                                        if obj.PathCnt~=obj.ListLengthInt-1
                                            if(obj.leafCount+1)==obj.DupIndices(log2(obj.PathCnt+1)+1)
                                                obj.PathCnt=obj.PathCnt*2+1;
                                            end
                                        end
                                    else
                                        decMade=false;
                                        obj.stageCounter=obj.stageCounter+1;
                                    end
                                else
                                    decMade=true;
                                end

                                if decMade
                                    obj.rdStage=nextStage(obj,obj.leafCount);
                                    obj.leafCount=obj.leafCount+1;

                                    obj.DecLlrIdx=obj.DecLlrIdx+1;
                                    obj.OutputSoftDec=0;
                                    obj.stageCounter=0;
                                end
                            end
                        else
                            obj.DecLlrReg(:,obj.DebugPipe)=0;
                            obj.DecLlrValidReg(obj.DebugPipe)=0;
                            if obj.rdBlkAddr==obj.StageIts(obj.rdStage+1)
                                obj.stageCounter=obj.stageCounter+1;
                                if obj.pathIdx==obj.PathCnt
                                    if~(obj.rdStage==log2(obj.CoreOrder)+2&&obj.stageCounter<=1...
                                        ||obj.rdStage<log2(obj.CoreOrder)+2&&obj.rdStage~=0&&obj.stageCounter<=2...
                                        ||obj.rdStage==0&&obj.stageCounter<=1)

                                        obj.stageCounter=0;
                                        obj.pathIdx=0;
                                        obj.rdBlkAddr=0;

                                        if obj.rdStage==0
                                            obj.OutputSoftDec=1;
                                        else
                                            obj.rdStage=obj.rdStage-1;
                                        end
                                    end
                                else
                                    obj.pathIdx=obj.pathIdx+1;
                                    obj.rdBlkAddr=0;
                                end
                            else
                                obj.rdBlkAddr=obj.rdBlkAddr+1;
                            end
                        end

                    end
                end
            otherwise
            end

            obj.DecLlrReg(:,1:obj.DebugPipe-1)=obj.DecLlrReg(:,2:obj.DebugPipe);
            obj.DecLlrValidReg(1:obj.DebugPipe-1)=obj.DecLlrValidReg(2:obj.DebugPipe);

            if obj.CrcAndOutput
                if obj.PathSelLatencyCount==obj.PathSelLatency
                    if obj.RNTIPort
                        obj.ErrReg=obj.SelCrcErr;
                    else
                        obj.ErrReg=any(obj.SelCrcErr);
                    end

                    if obj.OutputCRCBits
                        targetCount=obj.PrevK;
                    else
                        if obj.PrevParityCheck
                            targetCount=obj.PrevK-6;
                        else
                            targetCount=obj.PrevK-obj.CrcLen;
                        end
                    end

                    if obj.OutputCount==0
                        obj.StartReg=true;
                    elseif obj.OutputCount==targetCount-1
                        obj.EndReg=true;
                    else
                        obj.StartReg=false;
                        obj.EndReg=false;
                    end

                    if obj.OutputCount==targetCount
                        obj.DataOutReg(:)=0;
                        obj.ErrReg(:)=0;
                        obj.ValidReg=false;
                        obj.CrcAndOutput=false;
                        obj.PathSelLatencyCount=0;
                    else
                        obj.DataOutReg(:)=obj.SelPath(obj.OutputCount+1);
                        obj.ValidReg=true;
                        obj.OutputCount=obj.OutputCount+1;
                    end
                else
                    obj.PathSelLatencyCount=obj.PathSelLatencyCount+1;
                end
            end
        end

        function channelLoaded=channelLoader(obj,dataIn,ctrlIn)
            channelLoaded=false;
            if ctrlIn.valid
                if ctrlIn.start

                    obj.ChannelMemory(1:2^obj.n)=obj.AlphaMem{obj.n+1}(1,:);
                    obj.ChannelMemoryIdx=0;
                    obj.ChannelBufferIdx=0;
                    obj.Started=true;
                end
                if obj.Started
                    obj.ChannelBuffer(obj.ChannelBufferIdx+1)=dataIn;
                    if obj.ChannelBufferIdx==obj.CoreOrder-1
                        channelMemoryStart=mod(obj.ChannelMemoryIdx*obj.CoreOrder,obj.N);
                        channelMemoryEnd=channelMemoryStart+obj.CoreOrder;

                        obj.ChannelMemory(channelMemoryStart+1:channelMemoryEnd)=obj.ChannelBuffer;

                        obj.ChannelMemoryIdx=obj.ChannelMemoryIdx+1;
                        obj.ChannelBufferIdx=0;
                    else
                        obj.ChannelBufferIdx=obj.ChannelBufferIdx+1;
                    end
                end

                if ctrlIn.end&&obj.Started&&~ctrlIn.start
                    messageLength=obj.ChannelMemoryIdx*obj.CoreOrder+obj.ChannelBufferIdx;
                    if messageLength~=obj.N
                        coder.internal.warning('whdl:PolarCode:ChannelSizeMismatch',messageLength,obj.N);
                        obj.NextFrameReg=true;
                    elseif~obj.ValidConfig
                        obj.NextFrameReg=true;
                    else
                        channelLoaded=true;
                    end
                    obj.Started=false;
                end
            end
        end

        function[decBits,crcErr]=polarDecode(obj)
            if isa(obj.ChannelMemory,'embedded.fi')
                metricMax=upperbound(obj.Metrics);
                bound=upperbound(obj.ChannelMemory);
                llrs=clampLLRs(obj,obj.ChannelMemory(1:obj.N),-bound,bound);
            else
                metricMax=realmax('double');
                llrs=obj.ChannelMemory(1:obj.N);
            end

            obj.AlphaMem{obj.n+1}=repmat(llrs,obj.ListLengthInt,1);
            obj.Metrics(:)=0;
            obj.DupIndices(:)=0;
            obj.activePaths=1;

            leafIdx=0;
            msgIdx=0;

            curNode=obj.n-1;
            decRight=0;
            if obj.ListLengthInt==2
                dupCount=0;
                prevPtr=0;
            else
                dupCount=zeros(obj.ListLengthInt,1);
            end


            obj.DecLlrs(:)=zeros(obj.ListLengthInt,2.^obj.TreeDepth);

            while leafIdx<obj.N
                if decRight
                    obj.AlphaMem{curNode+1}=alphaRight(obj,obj.AlphaMem{curNode+1+1},obj.BetaMem{curNode+1});
                    decRight=0;
                else
                    obj.AlphaMem{curNode+1}=alphaLeft(obj,obj.AlphaMem{curNode+1+1});
                end

                if curNode==0
                    decision=false(obj.ListLengthInt,1);
                    beta=false(obj.ListLengthInt,1);
                    decision(:)=(obj.AlphaMem{1}<0);

                    obj.DecLlrs(1:obj.activePaths,leafIdx+1)=obj.AlphaMem{1}(1:obj.activePaths,1);

                    if obj.F(leafIdx+1)
                        if obj.activePaths<2||obj.activePaths<obj.ListLengthInt&&obj.Metrics(1,1)~=0&&all(dupCount<obj.DupLim-1)
                            obj.Metrics(obj.activePaths+1:obj.activePaths*2,1)=obj.Metrics(1:obj.activePaths,1)+abs(obj.AlphaMem{1}(1:obj.activePaths,1));

                            if~(obj.ParityCheck&&any(obj.Qpc==leafIdx))
                                obj.PathMem(obj.activePaths+1:obj.activePaths*2,1:obj.K)=obj.PathMem(1:obj.activePaths,1:obj.K);
                                obj.PathMem(1:obj.activePaths,msgIdx+1)=decision(1:obj.activePaths);
                                obj.PathMem(obj.activePaths+1:obj.activePaths*2,msgIdx+1)=~decision(1:obj.activePaths);
                            end

                            beta(1:obj.activePaths*2)=[decision(1:obj.activePaths);~decision(1:obj.activePaths)];
                            for ii=1:obj.n
                                obj.AlphaMem{ii}(obj.activePaths+1:obj.activePaths*2,1:2^(ii-1))=obj.AlphaMem{ii}(1:obj.activePaths,:);
                            end
                            for ii=1:obj.n-1
                                obj.BetaMem{ii}(obj.activePaths+1:obj.activePaths*2,1:2^(ii-1))=obj.BetaMem{ii}(1:obj.activePaths,:);
                            end

                            obj.DupIndices(log2(obj.activePaths)+1)=leafIdx+1;

                            if obj.activePaths>1
                                dupCount(obj.activePaths+1:obj.activePaths*2)=dupCount(1:obj.activePaths)+1;
                            end

                            obj.activePaths=obj.activePaths*2;
                        else
                            obj.Metrics(obj.activePaths+1:obj.activePaths*2,1)=obj.Metrics(1:obj.activePaths,1)+abs(obj.AlphaMem{1}(1:obj.activePaths,1));

                            indx=transpose(1:obj.activePaths);

                            if all(dupCount<obj.DupLim-1)
                                if obj.ListLengthInt==2
                                    [oldMetrics,oldIdx]=sort(obj.Metrics(1:obj.activePaths,1));
                                    [newMetrics,newIdx]=sort(obj.Metrics(obj.activePaths+1:obj.activePaths*2,1));
                                else
                                    [oldMetrics,oldIdx]=optSort(obj,[obj.Metrics(1:obj.activePaths,1);repmat(metricMax,obj.ListLengthInt-obj.activePaths,1)]);
                                    [newMetrics,newIdx]=optSort(obj,[obj.Metrics(obj.activePaths+1:obj.activePaths*2,1);repmat(metricMax,obj.ListLengthInt-obj.activePaths,1)]);

                                    oldMetrics=oldMetrics(1:obj.activePaths);
                                    oldIdx=oldIdx(1:obj.activePaths);
                                    newMetrics=newMetrics(1:obj.activePaths);
                                    newIdx=newIdx(1:obj.activePaths);
                                end
                                newMetrics=flip(newMetrics);
                                replace=oldMetrics>newMetrics;
                                replIdx=oldIdx(replace);

                                indx(replIdx)=flip(uint8(newIdx(1:sum(replace)))+uint8(obj.activePaths));
                                obj.Metrics(1:obj.activePaths,1)=obj.Metrics(indx,1);
                            end

                            if any(indx~=transpose(1:obj.activePaths))
                                if~(obj.ParityCheck&&any(obj.Qpc==leafIdx))
                                    obj.PathMem(1:obj.activePaths,1:obj.K)=obj.PathMem(mod(indx(1:obj.activePaths)-1,obj.activePaths)+1,1:obj.K);
                                end

                                for ii=1:obj.n
                                    obj.AlphaMem{ii}(1:obj.activePaths,:)=obj.AlphaMem{ii}(mod(indx(1:obj.activePaths)-1,obj.activePaths)+1,:);
                                end
                                for ii=1:obj.n-1
                                    obj.BetaMem{ii}(1:obj.activePaths,:)=obj.BetaMem{ii}(mod(indx(1:obj.activePaths)-1,obj.activePaths)+1,:);
                                end

                                if obj.ListLengthInt==2
                                    newPtr=indx(indx~=transpose(1:2))-2;
                                    if dupCount==0||prevPtr~=newPtr(1)
                                        dupCount=dupCount+1;
                                        prevPtr=newPtr(1);
                                    end
                                else
                                    updatePtr=(indx~=transpose(1:obj.activePaths));
                                    dupCount(updatePtr)=dupCount(indx(updatePtr)-obj.activePaths)+1;%#ok
                                end
                            end
                            if~(obj.ParityCheck&&any(obj.Qpc==leafIdx))
                                obj.PathMem(1:obj.activePaths,msgIdx+1)=xor(decision(mod(indx(1:obj.activePaths)-1,obj.activePaths)+1),indx(1:obj.activePaths)>obj.activePaths);
                            end
                            beta(1:obj.activePaths,1)=xor(decision(mod(indx(1:obj.activePaths)-1,obj.activePaths)+1),indx(1:obj.activePaths)>obj.activePaths);
                        end
                        if~(obj.ParityCheck&&any(obj.Qpc==leafIdx))
                            msgIdx=msgIdx+1;
                        end
                    else
                        if any(decision)
                            obj.Metrics(decision)=obj.Metrics(decision)+abs(obj.AlphaMem{1}(decision));
                        end
                        beta=false(obj.ListLengthInt,1);
                    end
                    curNode=nextStage(obj,leafIdx);
                    obj.BetaProp(1:obj.ListLengthInt,1)=beta;
                    if curNode>0
                        for ii=0:curNode-1
                            betaRight=obj.BetaProp(1:obj.ListLengthInt,1:2^ii);
                            betaLeft=obj.BetaMem{ii+1}(1:obj.ListLengthInt,:);
                            obj.BetaProp(1:obj.ListLengthInt,1:2^(ii+1))=[xor(betaRight,betaLeft),betaRight];
                        end
                    end
                    obj.BetaMem{curNode+1}(1:obj.ListLengthInt,:)=obj.BetaProp(1:obj.ListLengthInt,1:2^(curNode));
                    leafIdx=leafIdx+1;
                    decRight=1;
                else
                    curNode=curNode-1;
                end
            end

            [decBits,crcErr]=selCorPath(obj);
        end

        function[decBits,crcErr]=selCorPath(obj)
            if isa(obj.Metrics,'embedded.fi')
                metricMax=upperbound(obj.Metrics);
            else
                metricMax=realmax('double');
            end

            crcPasses=false(obj.ListLengthInt,1);
            err=fi(zeros(obj.ListLengthInt,1),0,obj.CrcLen,0);
            for ii=1:obj.activePaths
                canMsg=obj.PathMem(ii,1:obj.K).';
                if obj.iIL
                    canMsg(obj.ItlvMap(1:obj.K)+1)=canMsg;
                end
                if(obj.K~=56||obj.E~=864)&&obj.DownlinkMode
                    err(ii)=crcDecode(obj,[ones(24,1);canMsg]);
                else
                    err(ii)=crcDecode(obj,canMsg);
                end

                crcPasses(ii)=(err(ii)==fi(obj.targetRnti,0,obj.CrcLen,0));
            end

            if obj.ListLengthInt==2
                [~,metricsOrder]=sort(obj.Metrics(1:obj.activePaths,1));
            else
                [~,metricsOrder]=optSort(obj,[obj.Metrics(1:obj.activePaths,1);repmat(metricMax,obj.ListLengthInt-obj.activePaths,1)]);
            end

            if any(crcPasses)
                rankPassedPaths=metricsOrder(crcPasses(metricsOrder));
                selPathIdx=rankPassedPaths(1);
            else
                selPathIdx=metricsOrder(1);
            end

            corPath=obj.PathMem(selPathIdx,1:obj.K).';
            crcErr=err(selPathIdx);

            if obj.iIL
                corPath(obj.ItlvMap(1:obj.K)+1)=corPath;
            end

            if obj.iIL
                for ii=1:obj.ListLengthInt
                    obj.PathMem(ii,obj.ItlvMap(1:obj.K).'+1)=obj.PathMem(ii,1:obj.K);
                end
            end

            if obj.TargetRNTIPort&&obj.DownlinkMode

                maskBits=comm.internal.utilities.de2biBase2LeftMSB(...
                double(obj.targetRnti),obj.CrcLen)';

                crcErrBits=comm.internal.utilities.de2biBase2LeftMSB(...
                double(crcErr),obj.CrcLen)';

                crcErr=fi(bitconcat(fi(xor(crcErrBits,maskBits),0,1,0)),0,obj.CrcLen,0);
            end

            decBits=corPath(:,1);

        end

        function err=crcDecode(obj,canMsg)

            if obj.DownlinkMode
                crcLen=24;
                crcPoly=obj.CrcPolyOpts{1};
            else
                if obj.ParityCheck
                    crcLen=6;
                    crcPoly=obj.CrcPolyOpts{2};
                else
                    crcLen=11;
                    crcPoly=obj.CrcPolyOpts{3};
                end

            end

            errArr=fi(zeros(obj.CrcLen,1),0,1,0);

            canMsgPad=[canMsg(1:end-crcLen);zeros(crcLen,1)];


            remBits=[0;canMsgPad(1:crcLen,1)];
            for ii=1:length(canMsgPad)-crcLen
                dividendBlk=[remBits(2:end);canMsgPad(ii+crcLen)];
                if dividendBlk(1)==1
                    remBits=rem(crcPoly+dividendBlk,2);
                else
                    remBits=dividendBlk;
                end
            end
            parityBits=remBits(2:end);

            recalCrc=logical([canMsg(1:end-crcLen);parityBits]);


            errArr(1:crcLen)=xor(recalCrc(end-crcLen+1:end)>0,...
            canMsg(end-crcLen+1:end));

            err=bitconcat(errArr);
        end

        function alphaOut=alphaLeft(~,alphaIn)
            stageSize=size(alphaIn,2);
            lower=alphaIn(:,1:stageSize/2);
            upper=alphaIn(:,stageSize/2+1:stageSize);

            sgn=xor(lower<0,upper<0);
            alphaOut=min(abs(lower),abs(upper));
            alphaOut(sgn)=-1*alphaOut(sgn);
        end

        function alphaOut=alphaRight(obj,alphaIn,beta)
            stageSize=size(alphaIn,2);
            lower=alphaIn(:,1:stageSize/2);
            upper=alphaIn(:,stageSize/2+1:stageSize);

            negLower=uminus(lower);
            lower(beta(:,1:stageSize/2))=negLower(beta(:,1:stageSize/2));

            if isa(alphaIn,'embedded.fi')
                bound=upperbound(alphaIn);
                alpha=clampLLRs(obj,lower+upper,-bound,bound);
            else
                alpha=lower+upper;
            end

            alphaOut=cast(alpha,'like',alphaIn);
        end

        function y=clampLLRs(~,x,lLim,uLim)
            x(x<lLim)=lLim;
            x(x>uLim)=uLim;

            y=x;
        end

        function stage=nextStage(~,leafIdx)
            stage=9;
            for ii=1:9
                if mod(leafIdx,2^ii)==(2^(ii-1)-1)
                    stage=ii-1;
                    break;
                end
            end
        end

        function[sorted,indices]=optSort(obj,unsorted)
            sorted=cast(zeros(obj.ListLengthInt,1),'like',unsorted);
            indices=zeros(obj.ListLengthInt,1);

            stageIn=unsorted;
            indsIn=transpose(1:obj.ListLengthInt);

            stageOut=cast(zeros(obj.ListLengthInt,1),'like',unsorted);
            indsOut=zeros(obj.ListLengthInt,1);
            for ii=1:length(obj.SorterOps)
                stageOps=obj.SorterOps{ii};

                for jj=1:size(stageOps,2)
                    [stageOut(stageOps(:,jj)),indsOut(stageOps(:,jj))]=optSortComp(obj,stageIn(stageOps(:,jj)),indsIn(stageOps(:,jj)));
                end

                stageIn=stageOut;
                indsIn=indsOut;
            end

            sorted(:)=stageIn;
            indices(:)=indsOut;
        end

        function[sorted,indices]=optSortComp(~,unsorted,unsortedInd)
            sorted=cast(zeros(2,1),'like',unsorted);
            indices=zeros(2,1);
            comp=(unsorted(1)<=unsorted(2));
            sorted(1)=unsorted(2-comp);
            sorted(2)=unsorted(comp+1);
            indices(1)=unsortedInd(2-comp);
            indices(2)=unsortedInd(comp+1);
        end

        function configure(obj)
            [obj.n,obj.N]=nrhdl.internal.PolarHelper.getN(obj.K,obj.E,obj.nMax);

            [obj.F(1:obj.N),obj.Qpc]=nrhdl.internal.PolarHelper.construct(obj.K,obj.E,obj.N);

            if obj.DownlinkMode
                obj.ItlvMap(1:obj.K)=nrhdl.internal.PolarHelper.interleaveMap(obj.K);
                obj.ParityCheck=false;
            else
                obj.ParityCheck=obj.MessageLength>=18&&obj.K<=25;
            end
        end

        function configLatency=getConfigLatency(obj)
            pipelineDelay=2;
            configLatency=obj.N;

            if obj.E<obj.N
                configLatency=configLatency+obj.N;
            end

            configLatency=configLatency+pipelineDelay;
        end

        function procLatency=getProcLatency(obj)
            pipelineDelay=2;
            frozenDecCycles=1;

            if obj.ParityCheck
                nPC=3;
            else
                nPC=0;
            end

            decisionLatency=(obj.N-obj.K-nPC)*frozenDecCycles+(obj.K+nPC)*obj.infoDecCycles;


            nodeIts=ceil(2.^(1:obj.n)./obj.CoreOrder./2);

            if obj.ListLengthInt==2
                dupCnt=1;
                dupIdxs=find(obj.F,1);
            else
                dupCnt=log2(obj.activePaths);
                dupIdxs=obj.DupIndices;
            end

            cumNodeOps=zeros(1,obj.n);
            descendLatency=0;
            for ii=1:dupCnt+1
                if ii==dupCnt+1
                    nodeOps=ceil(obj.N./(2.^(0:obj.n-1)))-cumNodeOps;
                else
                    nodeOps=ceil(dupIdxs(ii)./(2.^(0:obj.n-1)))-cumNodeOps;
                end

                nodeLatency=nodeIts*2.^(ii-1);
                if obj.n>=7
                    nodeLatency(log2(obj.CoreOrder)+3)=nodeLatency(log2(obj.CoreOrder)+3)+max(1-(2.^(ii-1)-1),0);
                end
                nodeLatency(2:min(log2(obj.CoreOrder)+2,obj.n))=nodeLatency(2:min(log2(obj.CoreOrder)+2,obj.n))+max(2-(2.^(ii-1)-1),0);
                nodeLatency(1)=nodeLatency(1)+max(1-(2.^(ii-1)-1),0);

                descendLatency=descendLatency+sum(nodeLatency.*nodeOps);

                cumNodeOps=cumNodeOps+nodeOps;
            end

            procLatency=descendLatency+decisionLatency+pipelineDelay;
        end

        function pathSelLatency=getPathSelLatency(obj)
            pipelineDelay=8;

            if obj.ParityCheck
                crcLen=6;
            else
                crcLen=obj.CrcLen;
            end

            crcLatency=2*crcLen+5+obj.K;

            if obj.DownlinkMode
                deItlvLatency=obj.K;

                if obj.K~=56||obj.E~=864
                    crcLatency=crcLatency+24;
                end
            else
                deItlvLatency=0;
            end

            pathSelLatency=crcLatency+pipelineDelay+deItlvLatency;
        end

        function setupImpl(obj,varargin)
            dataIn=varargin{1};

            obj.KPort=0;
            obj.EPort=0;

            obj.targetRnti=0;
            obj.ListLengthInt=real(str2double(obj.ListLength));
            obj.DownlinkMode=(obj.LinkDirection=="Downlink");
            obj.ConfigFromPort=(obj.ConfigurationSource=="Input port");
            obj.DupLim=obj.DupLimOpts(log2(obj.ListLengthInt));
            obj.infoDecCycles=obj.infoDecCyclesOpts(log2(obj.ListLengthInt));

            if~obj.DownlinkMode
                obj.nMax=10;
                obj.iIL=false;
                if obj.RNTIPort
                    obj.ErrReg=fi(0,0,11,0);
                else
                    obj.ErrReg=false;
                end
                obj.CrcLen=11;
                obj.SelCrcErr=fi(0,0,11,0);
            else
                obj.nMax=9;
                obj.iIL=true;
                obj.CrcLen=24;
                if obj.RNTIPort
                    obj.ErrReg=fi(0,0,24,0);
                else
                    obj.ErrReg=false;
                end
                obj.SelCrcErr=fi(0,0,24,0);
            end

            obj.Started=false;

            obj.DecoderState=0;

            if isa(dataIn,'double')||isa(dataIn,'single')
                intLlrTypeRef=dataIn;
                obj.Metrics=zeros(2*obj.ListLengthInt,1);
            else
                satFiMath=fimath('RoundingMethod','Floor','OverflowAction','Saturate');
                [WL,~,~]=dsphdlshared.hdlgetwordsizefromdata(dataIn);

                obj.reinterpType=numerictype(1,WL,WL-1);
                obj.Metrics=fi(zeros(2*obj.ListLengthInt,1),0,WL+6,WL-1,satFiMath);
                intLlrTypeRef=fi(0,1,WL+2,WL-1,satFiMath);
            end

            obj.Qpc=zeros(3,1);

            if~obj.ConfigFromPort
                obj.K=obj.MessageLength;
                obj.E=obj.Rate;
                obj.TreeDepth=nrhdl.internal.PolarHelper.getN(obj.MessageLength,obj.Rate,obj.nMax);
                obj.F=false(2.^obj.TreeDepth,1);
                obj.ItlvMap=zeros(obj.MessageLength,1);
                obj.ValidConfig=true;
                obj.Configured=true;
                configure(obj);
                obj.ProcLatency=0;
                obj.PathSelLatency=getPathSelLatency(obj);

                obj.SelPath=false(obj.K,1);

                obj.PathMem=false(obj.ListLengthInt,obj.K);
            else
                obj.K=realmax;
                obj.E=realmax;
                obj.n=5;
                obj.N=2.^5;
                obj.ValidConfig=false;
                obj.Configured=false;
                obj.ProcLatency=0;
                obj.PathSelLatency=0;
                obj.TreeDepth=obj.nMax;

                if~obj.DownlinkMode
                    obj.F=false(1024,1);
                    obj.SelPath=false(1024,1);
                    obj.PathMem=false(obj.ListLengthInt,1024);
                else
                    obj.F=false(512,1);
                    obj.SelPath=false(256,1);
                    obj.ItlvMap=zeros(256,1);
                    obj.PathMem=false(obj.ListLengthInt,256);
                end
            end

            obj.PrevK=0;

            if obj.ListLengthInt==4
                obj.SorterOps=cell(3,1);
                obj.SorterOps{1}=[1,2;
                3,4].';
                obj.SorterOps{2}=[1,3;
                2,4].';
                obj.SorterOps{3}=[1,1;
                2,3;
                4,4].';
            elseif obj.ListLengthInt==8
                obj.SorterOps=cell(6,1);

                obj.SorterOps{1}=[1,2;
                3,4;
                5,6;
                7,8].';
                obj.SorterOps{2}=[1,3;
                2,4;
                5,7;
                6,8].';
                obj.SorterOps{3}=[1,5;
                2,6;
                3,7;
                4,8].';
                obj.SorterOps{4}=[1,1;
                2,3;
                4,4;
                5,5;
                6,7;
                8,8].';
                obj.SorterOps{5}=[1,1;
                2,2;
                3,5;
                4,6;
                7,7;
                8,8].';
                obj.SorterOps{6}=[1,1;
                2,3;
                4,5
                6,7
                8,8].';
            end

            obj.PrevParityCheck=false;

            obj.ConfigLatency=0;

            obj.DupIndices=zeros(log2(obj.ListLengthInt),1);
            obj.activePaths=1;

            obj.ChannelMemory=cast(zeros(1,2.^obj.TreeDepth),'like',intLlrTypeRef);

            obj.AlphaMem=cell(obj.TreeDepth+1,1);
            for ii=1:obj.TreeDepth+1
                obj.AlphaMem{ii}=cast(zeros(obj.ListLengthInt,2^(ii-1)),'like',intLlrTypeRef);
            end

            obj.BetaMem=cell(obj.TreeDepth+1,1);
            for ii=1:obj.TreeDepth+1
                obj.BetaMem{ii}=false(obj.ListLengthInt,2^(ii-1));
            end

            obj.BetaProp=zeros(obj.ListLengthInt,2.^obj.TreeDepth);
            obj.DecLlrs=cast(zeros(obj.ListLengthInt,2.^obj.TreeDepth),'like',intLlrTypeRef);
            obj.DecLlrIdx=0;

            obj.ChannelMemoryIdx=0;

            obj.ChannelBuffer=cast(zeros(obj.CoreOrder,1),'like',intLlrTypeRef);
            obj.ChannelBufferIdx=0;
            obj.ChannelMemoryIdx=0;

            obj.ConfigLatencyCount=0;
            obj.ProcLatencyCount=0;
            obj.PathSelLatencyCount=0;
            obj.OutputCount=0;

            obj.channelLoaded=false;
            obj.CrcAndOutput=false;

            obj.DataOutReg=false;
            obj.StartReg=false;
            obj.EndReg=false;
            obj.ValidReg=false;

            obj.NextFrameReg=true;

            obj.DebugPipe=6;
            obj.DecLlrReg=cast(zeros(obj.ListLengthInt,obj.DebugPipe),'like',intLlrTypeRef);
            obj.DecLlrValidReg=false(obj.DebugPipe,1);


            obj.OutputSoftDec=0;
            obj.rdBlkAddr=0;
            obj.rdStage=0;
            obj.leafCount=0;
            obj.stageCounter=0;
            obj.pathIdx=0;
            obj.PathCnt=0;

            obj.StageIts=ceil((2.^(1:10))/obj.CoreOrder/2)-1;
        end

        function validateInputsImpl(obj,varargin)
            dataIn=varargin{1};
            ctrlIn=varargin{2};

            if isempty(coder.target)||~eml_ambiguous_types

                validateattributes(dataIn,{'embedded.fi','int8','int16','double','single'},{'scalar','real'},'PolarDecoder','data');

                if isa(dataIn,'embedded.fi')
                    [inWL,~,signed]=dsphdlshared.hdlgetwordsizefromdata(dataIn);

                    coder.internal.errorIf(~signed,'whdl:PolarCode:UnsignedDecDataType');
                    coder.internal.errorIf(inWL<4||inWL>16,'whdl:PolarCode:InvalidWLDecDataType');
                end

                if isstruct(ctrlIn)
                    test=fieldnames(ctrlIn);
                    truth={'start';'end';'valid'};
                    if isequal(test,truth)
                        validateattributes(ctrlIn.start,{'logical'},{'scalar'},'PolarDecoder','start');
                        validateattributes(ctrlIn.end,{'logical'},{'scalar'},'PolarDecoder','end');
                        validateattributes(ctrlIn.valid,{'logical'},{'scalar'},'PolarDecoder','valid');
                    else
                        coder.internal.error('whdl:PolarCode:InvalidCtrlBusType');
                    end
                else
                    coder.internal.error('whdl:PolarCode:InvalidCtrlBusType');
                end

                if obj.ConfigFromPort
                    KIn=varargin{3};
                    EIn=varargin{4};

                    validateattributes(EIn,{'numeric','embedded.fi'},{'scalar','real'},'PolarDecoder','E');
                    [WL,FL,signed]=dsphdlshared.hdlgetwordsizefromdata(EIn);
                    if(WL~=14||FL~=0||signed~=0)
                        if isa(EIn,'embedded.fi')
                            coder.internal.error('whdl:PolarCode:InvalidRateDataType',tostringInternalSlName(EIn.numerictype));
                        else
                            coder.internal.error('whdl:PolarCode:InvalidRateDataType',class(EIn));
                        end
                    end

                    validateattributes(KIn,{'numeric','embedded.fi'},{'scalar','real'},'PolarDecoder','K');
                    [WL,FL,signed]=dsphdlshared.hdlgetwordsizefromdata(KIn);
                    if(WL~=10||FL~=0||signed~=0)
                        if isa(KIn,'embedded.fi')
                            coder.internal.error('whdl:PolarCode:InvalidKDataType',tostringInternalSlName(KIn.numerictype));
                        else
                            coder.internal.error('whdl:PolarCode:InvalidKDataType',class(KIn));
                        end
                    end
                end

                if obj.TargetRNTIPort&&obj.DownlinkMode
                    rnti=varargin{end};
                    validateattributes(rnti,{'uint16'},{'scalar','real'},'Polar Decoder','RNTI');
                end

                obj.inDisp=~isempty(varargin{1});
            end
        end

        function validatePropertiesImpl(obj)
            obj.ListLengthInt=real(str2double(obj.ListLength));
            obj.DownlinkMode=(obj.LinkDirection=="Downlink");
            obj.ConfigFromPort=(obj.ConfigurationSource=="Input port");

            validateattributes(obj.ListLengthInt,{'numeric'},{'scalar','integer'},'PolarDecoder','ListLengthInt');
            if~ismember(obj.ListLengthInt,[2,4,8])
                coder.internal.error('whdl:PolarCode:InvalidListLength',string(obj.ListLengthInt));
            end

            if~obj.ConfigFromPort
                validateattributes(obj.MessageLength,{'numeric','embedded.fi'},{'scalar','integer'},'PolarDecoder','K');
                validateattributes(obj.Rate,{'numeric','embedded.fi'},{'scalar','integer'},'PolarDecoder','E');

                if obj.MessageLength>=18&&obj.MessageLength<=25
                    obj.ParityCheck=true;
                else
                    obj.ParityCheck=false;
                end

                if obj.LinkDirection=="Uplink"
                    if~(obj.MessageLength>=31&&obj.MessageLength<=1023||obj.MessageLength>=18&&obj.MessageLength<=25)
                        coder.internal.error('whdl:PolarCode:KRangeUplink',string(obj.MessageLength));
                    end
                else
                    if obj.MessageLength<36||obj.MessageLength>164
                        coder.internal.error('whdl:PolarCode:KRangeDownlink',string(obj.MessageLength));
                    end
                end

                if obj.Rate>8192
                    coder.internal.error('whdl:PolarCode:EGreaterThanMax',string(obj.Rate));
                end

                if obj.Rate<=obj.MessageLength
                    coder.internal.error('whdl:PolarCode:KGreaterThanE',string(obj.MessageLength),string(obj.Rate));
                end
            else
                obj.ParityCheck=false;
            end
        end

        function validatePortConfig(obj)
            obj.ValidConfig=true;

            if~obj.DownlinkMode
                if~(obj.KPort>=31&&obj.KPort<=1023||obj.KPort>=18&&obj.KPort<=25)
                    coder.internal.warning('whdl:PolarCode:KRangeUplink',string(obj.KPort));
                    obj.ValidConfig=false;
                end
            else
                if obj.KPort<36||obj.KPort>164
                    coder.internal.warning('whdl:PolarCode:KRangeDownlink',string(obj.KPort));
                    obj.ValidConfig=false;
                end
            end

            if obj.EPort<=obj.KPort
                coder.internal.warning('whdl:PolarCode:KGreaterThanE',string(obj.KPort),string(obj.EPort));
                obj.ValidConfig=false;
            end

            if obj.EPort>8192
                coder.internal.warning('whdl:PolarCode:EGreaterThanMax',string(obj.EPort));
                obj.ValidConfig=false;
            end
        end

        function resetImpl(obj)
            obj.Started(:)=0;

            obj.ErrReg(:)=0;
            obj.SelCrcErr(:)=0;

            obj.DecoderState(:)=0;

            obj.Metrics(:)=0;

            obj.SelPath(:)=false;

            obj.PathMem(:)=false;

            if obj.ConfigFromPort
                obj.K(:)=realmax;
                obj.E(:)=realmax;
                obj.n(:)=5;
                obj.N(:)=2.^5;
                obj.ProcLatency(:)=0;
                obj.PathSelLatency(:)=0;

                obj.F(:)=false;

                if obj.DownlinkMode
                    obj.ItlvMap(:)=0;
                end
            end
            obj.PrevK(:)=0;

            obj.ConfigLatency(:)=0;

            obj.DupIndices(:)=0;
            obj.activePaths(:)=1;

            obj.ChannelMemory(:)=0;

            obj.BetaProp(:)=0;
            obj.DecLlrs(:)=0;

            obj.ChannelMemoryIdx(:)=0;

            obj.ChannelBuffer(:)=0;
            obj.ChannelBufferIdx(:)=0;
            obj.ChannelMemoryIdx(:)=0;

            obj.ConfigLatencyCount(:)=0;
            obj.ProcLatencyCount(:)=0;
            obj.PathSelLatencyCount(:)=0;
            obj.OutputCount(:)=0;

            obj.channelLoaded(:)=false;
            obj.CrcAndOutput(:)=false;

            obj.DataOutReg(:)=false;
            obj.StartReg(:)=false;
            obj.EndReg(:)=false;
            obj.ValidReg(:)=false;
            obj.NextFrameReg(:)=true;


        end
    end

    methods(Access=protected)
        function num=getNumInputsImpl(obj)
            if obj.ConfigurationSource=="Property"
                num=2;
            else
                num=4;
            end
            if obj.TargetRNTIPort&&obj.LinkDirection=="Downlink"
                num=num+1;
            end
        end

        function varargout=getInputNamesImpl(obj)
            varargout=cell(1,getNumInputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            if obj.ConfigurationSource=="Input port"
                varargout{3}='K';
                varargout{4}='E';
            end
            if obj.TargetRNTIPort&&obj.LinkDirection=="Downlink"
                varargout{end}='RNTI';
            end
        end

        function num=getNumOutputsImpl(obj)
            num=4;
            if obj.DebugPortsEn
                num=6;
            end
        end

        function varargout=getOutputNamesImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='data';
            varargout{2}='ctrl';
            varargout{3}='err';
            varargout{4}='nextFrame';

            if obj.DebugPortsEn
                varargout{5}='decLlr';
                varargout{6}='decLlrValid';
            end
        end

        function varargout=getOutputDataTypeImpl(obj)
            varargout=cell(1,getNumOutputs(obj));
            varargout{1}='logical';
            varargout{2}=samplecontrolbustype;
            if obj.RNTIPort
                if obj.DownlinkMode
                    varargout{3}=numerictype(0,24,0);
                else
                    varargout{3}=numerictype(0,11,0);
                end
            else
                varargout{3}='logical';
            end
            varargout{4}='logical';

            if obj.DebugPortsEn
                inputType=propagatedInputDataType(obj,1);
                if~isempty(inputType)
                    if inputType=="double"||inputType=="single"
                        varargout{5}=inputType;
                    else
                        [WL,~,~]=dsphdlshared.hdlgetwordsizefromtype(inputType);
                        varargout{5}=numerictype(1,WL+2,WL-1);
                    end
                end
                varargout{6}='logical';
            end
        end

        function varargout=isOutputFixedSizeImpl(obj)
            numOutputs=getNumOutputs(obj);
            varargout=cell(1,numOutputs);
            for ii=1:numOutputs
                varargout{ii}=true;
            end
        end

        function varargout=getOutputSizeImpl(obj)
            numOutputs=getNumOutputs(obj);
            varargout=cell(1,numOutputs);
            for ii=1:numOutputs
                varargout{ii}=1;
            end
            if obj.DebugPortsEn
                varargout{end-1}=[obj.ListLengthInt,1];
            end
        end

        function varargout=isOutputComplexImpl(obj)
            numOutputs=getNumOutputs(obj);
            varargout=cell(1,numOutputs);
            for ii=1:numOutputs
                varargout{ii}=false;
            end
        end

        function s=saveObjectImpl(obj)

            s=saveObjectImpl@matlab.System(obj);

            if obj.isLocked
                s.ListLengthInt=obj.ListLengthInt;
                s.DownlinkMode=obj.DownlinkMode;
                s.ConfigFromPort=obj.ConfigFromPort;
                s.reinterpType=obj.reinterpType;
                s.nMax=obj.nMax;
                s.iIL=obj.iIL;
                s.CrcLen=obj.CrcLen;
                s.TreeDepth=obj.TreeDepth;
                s.K=obj.K;
                s.E=obj.E;
                s.N=obj.N;
                s.n=obj.n;
                s.F=obj.F;
                s.ItlvMap=obj.ItlvMap;
                s.ValidConfig=obj.ValidConfig;
                s.Configured=obj.Configured;
                s.DecoderState=obj.DecoderState;
                s.ConfigLatency=obj.ConfigLatency;
                s.ProcLatency=obj.ProcLatency;
                s.PathSelLatency=obj.PathSelLatency;
                s.DupIndices=obj.DupIndices;
                s.activePaths=obj.activePaths;
                s.Started=obj.Started;
                s.channelLoaded=obj.channelLoaded;
                s.CrcAndOutput=obj.CrcAndOutput;
                s.ChannelMemory=obj.ChannelMemory;
                s.ChannelMemoryIdx=obj.ChannelMemoryIdx;
                s.ChannelBuffer=obj.ChannelBuffer;
                s.ChannelBufferIdx=obj.ChannelBufferIdx;
                s.AlphaMem=obj.AlphaMem;
                s.BetaMem=obj.BetaMem;
                s.BetaProp=obj.BetaProp;
                s.PathMem=obj.PathMem;
                s.Metrics=obj.Metrics;
                s.SelPath=obj.SelPath;
                s.SelCrcErr=obj.SelCrcErr;
                s.ConfigLatencyCount=obj.ConfigLatencyCount;
                s.ProcLatencyCount=obj.ProcLatencyCount;
                s.PathSelLatencyCount=obj.PathSelLatencyCount;
                s.OutputCount=obj.OutputCount;
                s.PrevK=obj.PrevK;
                s.DataOutReg=obj.DataOutReg;
                s.StartReg=obj.StartReg;
                s.EndReg=obj.EndReg;
                s.ValidReg=obj.ValidReg;
                s.ErrReg=obj.ErrReg;
                s.NextFrameReg=obj.NextFrameReg;
                s.DecLlrReg=obj.DecLlrReg;
                s.DecLlrValidReg=obj.DecLlrValidReg;
                s.DecLlrs=obj.DecLlrs;
            end
        end

        function loadObjectImpl(obj,s,~)
            fn=fieldnames(s);
            for ii=1:numel(fn)
                obj.(fn{ii})=s.(fn{ii});
            end
        end

        function icon=getIconImpl(obj)
            obj.ListLengthInt=real(str2double(obj.ListLength));
            if obj.ConfigFromPort||obj.ListLengthInt~=2
                icon='NR Polar Decoder';
            else
                if isempty(obj.inDisp)
                    icon='NR Polar Decoder\nLatency = --';
                else
                    if obj.DownlinkMode
                        obj.nMax=9;
                        obj.CrcLen=24;
                    else
                        obj.nMax=10;
                        obj.CrcLen=11;
                    end
                    obj.K=obj.MessageLength;
                    obj.E=obj.Rate;
                    obj.infoDecCycles=obj.infoDecCyclesOpts(log2(obj.ListLengthInt));
                    configure(obj);
                    icon=['NR Polar Decoder\nLatency = ',num2str(getLatency(obj))];
                end
            end
        end

        function flag=isInactivePropertyImpl(obj,prop)
            flag=false;
            if(strcmp(prop,'MessageLength')||strcmp(prop,'Rate'))&&strcmp(obj.ConfigurationSource,'Input port')
                flag=true;
            end

            if strcmp(prop,'TargetRNTIPort')&&strcmp(obj.LinkDirection,'Uplink')
                flag=true;
            end
        end

        function flag=getExecutionSemanticsImpl(obj)%#ok

            flag={'Classic','Synchronous'};
        end
    end

    methods(Static,Access=protected)
        function header=getHeaderImpl
            header=matlab.system.display.Header(mfilename('class'),...
            'ShowSourceLink',false,...
            'Title','NR Polar Decoder',...
            'Text','Decode polar encoded samples following the 5G NR standard.');
        end

        function isVisible=showSimulateUsingImpl
            isVisible=false;
        end

        function groups=getPropertyGroupsImpl
            dDebugPortsEn=matlab.system.display.internal.Property(...
            'DebugPortsEn','IsGraphical',false);
            dOutputCRCBits=matlab.system.display.internal.Property(...
            'OutputCRCBits','IsGraphical',false);

            blockProps={...
            'LinkDirection',...
            'ListLength',...
            'ConfigurationSource',...
            'MessageLength',...
            'Rate',...
            'RNTIPort',...
            'TargetRNTIPort',...
            dDebugPortsEn,...
dOutputCRCBits...
            };

            groups=matlab.system.display.Section('PropertyList',blockProps);
        end
    end
end
