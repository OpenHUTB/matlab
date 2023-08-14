classdef MemoryControllerDES<matlab.DiscreteEventSystem




%#codegen
%#ok<*EMCA>

    properties(Nontunable)

        MemorySelection='PS memory'

        ICArbitrationPolicy='Round robin';

        MasterID=1;

        ControllerFrequency=100;

        ControllerDataWidth=64;

        BandwidthDerating=2.3;

        ReadFirstTransferLatency=5;

        WriteFirstTransferLatency=5;

        ReadLastTransferLatency=5;

        WriteLastTransferLatency=5;

        DiagnosticLevel='No debug';
    end

    properties(Constant,Hidden)
        NumMastersMax=12;

        RequestIn=1;
        RequestArbitration=2;
        RequestAccepted=3;
        RequestExecuting=4;
        RequestComplete=5;

        RearbIn=6;
        RearbOut=7;

        DDLogOut=8;

        MemorySelectionSet=matlab.system.StringSet({'PS memory','PL memory'})
        MemorySelectionMax=numel(soc.internal.MemoryControllerDES.MemorySelectionSet.getAllowedValues);
        ICArbitrationPolicySet=matlab.system.StringSet({'Round robin','Fixed port priority'});
        DiagnosticLevelSet=matlab.system.StringSet({'No debug','Basic diagnostic signals'})
    end

    properties(Access=private)
        InstanceID;
        MemorySelectionNum;
        CurrentDDLog;
    end

    methods
        function obj=MemoryControllerDES(varargin)
            coder.allowpcode('plain');
            obj@matlab.DiscreteEventSystem(varargin);
        end


        function[entity,events]=requestEntry(obj,storage,entity,~)

            events=obj.initEventArray;

            if storage==obj.RequestIn

                obj.setgetRequestTable(obj.InstanceID,1,'inc');
                events=obj.eventForward('storage',obj.RequestArbitration,0);

                entity.data.port=double(obj.MasterID);
                entity.data.state=DDEvent2.BurstRequest;

                if~strcmp(obj.DiagnosticLevel,'No debug')
                    obj.CurrentDDLog.BURST_EXECUTION_EVENT=DDEvent2.BurstRequest;
                    obj.CurrentDDLog.masterID=double(obj.MasterID);
                    obj.CurrentDDLog.reqID=entity.data.reqID;
                    obj.CurrentDDLog.size=entity.data.size;
                    obj.CurrentDDLog.address=entity.data.addr;
                    events=[obj.eventGenerate(obj.DDLogOut,'',0,1),events];
                end

            elseif storage==obj.RequestArbitration
                IsMemBusy=obj.setgetIsMemBusy();
                RequestTable=obj.setgetRequestTable();
                if(~IsMemBusy)&&(RequestTable(obj.InstanceID)>0)
                    RequestTableIdx=find(RequestTable);
                    isCtrlNext=false;
                    if(numel(RequestTableIdx)==1)

                        isCtrlNext=true;
                    else
                        ArbiterPosition=obj.setgetArbiterPosition();
                        ArbiterPosition=mod(ArbiterPosition,obj.NumMastersMax)+1;
                        while RequestTable(ArbiterPosition)==0
                            ArbiterPosition=mod(ArbiterPosition,obj.NumMastersMax)+1;
                        end
                        if ArbiterPosition==obj.InstanceID
                            isCtrlNext=true;
                        end
                    end
                    if isCtrlNext
                        obj.setgetIsMemBusy(true);
                        obj.setgetArbiterPosition(obj.InstanceID);
                        events=obj.eventForward('storage',obj.RequestAccepted,0);

                    end
                end
            elseif storage==obj.RequestAccepted

                switch entity.data.reqKind
                case MasterKindEnum.Reader
                    startLatencyDDRClks=obj.ReadFirstTransferLatency;
                case MasterKindEnum.Writer
                    startLatencyDDRClks=obj.WriteFirstTransferLatency;
                otherwise
                    startLatencyDDRClks=obj.WriteFirstTransferLatency;
                end

                ctrlrClkPer=1/(obj.ControllerFrequency*1e6);
                startDelayTime=startLatencyDDRClks*ctrlrClkPer;

                events=obj.eventForward('storage',obj.RequestExecuting,startDelayTime);

                if~strcmp(obj.DiagnosticLevel,'No debug')
                    obj.CurrentDDLog.BURST_EXECUTION_EVENT=DDEvent2.BurstAccepted;
                    obj.CurrentDDLog.masterID=double(obj.MasterID);
                    obj.CurrentDDLog.reqID=entity.data.reqID;
                    obj.CurrentDDLog.size=entity.data.size;
                    obj.CurrentDDLog.address=entity.data.addr;
                    events=[obj.eventGenerate(obj.DDLogOut,'',0,1),events];
                end

            elseif storage==obj.RequestExecuting


                DERATING_CLOCK_INTERVAL=100;

                ctrlrByteWidth=(obj.ControllerDataWidth/8);
                ctrlrClkPer=1/(obj.ControllerFrequency*1e6);
                BurstSize=entity.data.size;
                deratingClockCount=obj.setgetDeratingClockCount();

                xferTimeBurst=BurstSize/(ctrlrByteWidth/ctrlrClkPer);
                deratingClockCount=deratingClockCount+(xferTimeBurst/ctrlrClkPer);

                if(deratingClockCount>DERATING_CLOCK_INTERVAL)
                    deratingTime=(deratingClockCount/DERATING_CLOCK_INTERVAL)*(obj.BandwidthDerating*ctrlrClkPer);
                    deratingClockCount=0;
                else
                    deratingTime=0;
                end

                obj.setgetDeratingClockCount(deratingClockCount);
                xferDelayTime=xferTimeBurst+deratingTime;

                events=obj.eventForward('storage',obj.RequestComplete,xferDelayTime);

                if~strcmp(obj.DiagnosticLevel,'No debug')
                    obj.CurrentDDLog.BURST_EXECUTION_EVENT=DDEvent2.BurstExecuting;
                    obj.CurrentDDLog.masterID=double(obj.MasterID);
                    obj.CurrentDDLog.reqID=entity.data.reqID;
                    obj.CurrentDDLog.size=entity.data.size;
                    obj.CurrentDDLog.address=entity.data.addr;
                    events=[obj.eventGenerate(obj.DDLogOut,'',0,1),events];
                end

            elseif storage==obj.RequestComplete

                switch entity.data.reqKind
                case MasterKindEnum.Reader
                    endLatencyDDRClks=obj.ReadLastTransferLatency;
                case MasterKindEnum.Writer
                    endLatencyDDRClks=obj.WriteLastTransferLatency;
                otherwise
                    endLatencyDDRClks=obj.WriteLastTransferLatency;
                end

                ctrlrClkPer=1/(obj.ControllerFrequency*1e6);
                endDelayTime=endLatencyDDRClks*ctrlrClkPer;

                events=obj.eventForward('output',1,endDelayTime);


                obj.setgetIsMemBusy(false);
                RequestTable=obj.setgetRequestTable(obj.InstanceID,1,'dec');

                RequestTableIdx=find(RequestTable);
                if(~isempty(RequestTableIdx))
                    if(numel(RequestTableIdx)==1)
                        obj.setgetArbiterPosition(RequestTableIdx(1));
                    else
                        ArbiterPosition=obj.setgetArbiterPosition();
                        ArbiterPosition=mod(ArbiterPosition,obj.NumMastersMax)+1;
                        while RequestTable(ArbiterPosition)==0
                            ArbiterPosition=mod(ArbiterPosition,obj.NumMastersMax)+1;
                        end
                        obj.setgetArbiterPosition(ArbiterPosition);
                    end
                    events=[events,obj.eventGenerate(obj.RearbOut,'',0,1)];
                end
            end
        end

        function[events]=requestExit(obj,storage,entity,destination)
            events=obj.initEventArray;
            if storage==obj.RequestExecuting

                if~strcmp(obj.DiagnosticLevel,'No debug')
                    BytesTransferredVec=obj.setgetBytesTransferred();
                    BurstTransfersCompletedVec=obj.setgetBurstTransfersCompleted();

                    BytesTransferred=BytesTransferredVec(obj.InstanceID);
                    BurstTransfersCompleted=BurstTransfersCompletedVec(obj.InstanceID);

                    BytesTransferred=BytesTransferred+entity.data.size;
                    BurstTransfersCompleted=BurstTransfersCompleted+1;

                    obj.setgetBytesTransferred(obj.InstanceID,BytesTransferred);
                    obj.setgetBurstTransfersCompleted(obj.InstanceID,BurstTransfersCompleted);

                    obj.CurrentDDLog.BURST_EXECUTION_EVENT=DDEvent2.BurstDone;
                    obj.CurrentDDLog.masterID=double(obj.MasterID);
                    obj.CurrentDDLog.reqID=entity.data.reqID;
                    obj.CurrentDDLog.size=entity.data.size;
                    obj.CurrentDDLog.address=entity.data.addr;
                    obj.CurrentDDLog.bytesTransferred=BytesTransferred;
                    obj.CurrentDDLog.burstTransfersCompleted=BurstTransfersCompleted;
                    events=[obj.eventGenerate(obj.DDLogOut,'',0,1),events];
                end

            elseif storage==obj.RequestComplete
                if~strcmp(obj.DiagnosticLevel,'No debug')
                    obj.CurrentDDLog.BURST_EXECUTION_EVENT=DDEvent2.BurstComplete;
                    obj.CurrentDDLog.masterID=double(obj.MasterID);
                    obj.CurrentDDLog.reqID=-1;
                    obj.CurrentDDLog.size=-1;
                    obj.CurrentDDLog.address=-1;
                    events=[obj.eventGenerate(obj.DDLogOut,'',0,1),events];
                end
            end
        end

        function[entity,events,next]=requestIterate(obj,storage,entity,tag,status)
            obj.setgetIsMemBusy(true);
            obj.setgetArbiterPosition(obj.InstanceID);
            events=obj.eventForward('storage',obj.RequestAccepted,0);
            next=false;
        end

        function[entity,events]=rearbEntry(obj,storage,entity,~)
            events=obj.eventDestroy();
            if storage==obj.RearbIn
                if entity.data==obj.InstanceID
                    RequestTable=obj.setgetRequestTable();
                    if(RequestTable(obj.InstanceID)>0)
                        events=[events,obj.eventIterate(obj.RequestArbitration,'')];
                    end
                end
            end
        end

        function events=setupEvents(obj)
            obj.CurrentDDLog.BURST_EXECUTION_EVENT=DDEvent2.BurstIdle;
            obj.CurrentDDLog.masterID=-1;
            obj.CurrentDDLog.reqID=-1;
            obj.CurrentDDLog.size=-1;
            obj.CurrentDDLog.address=-1;
            events=obj.eventGenerate(obj.DDLogOut,'',0,1);
        end

        function[entity,events]=rearbGenerate(obj,storage,entity,tag)
            entity.data=obj.setgetArbiterPosition();
            events=obj.eventForward('output',2,0);
        end

        function[entity,events]=ddlogGenerate(obj,storage,entity,tag)
            entity.data=obj.CurrentDDLog;
            events=obj.eventForward('output',3,0);
        end

    end

    methods(Access=protected)
        function setupImpl(obj)
            obj.InstanceID=obj.setgetCtrlID();
        end

        function resetImpl(obj)
            obj.setgetCtrlID(0);
            obj.setgetIsMemBusy(false);
            obj.setgetArbiterPosition(1);
            obj.setgetRequestTable(zeros(1,obj.NumMastersMax));
            obj.setgetDeratingClockCount(0);
            obj.setgetBytesTransferred(zeros(1,obj.NumMastersMax));
            obj.setgetBurstTransfersCompleted(zeros(1,obj.NumMastersMax));
            obj.CurrentDDLog=struct('BURST_EXECUTION_EVENT',DDEvent2.BurstIdle,...
            'masterID',-1,...
            'reqID',-1,...
            'size',-1,...
            'address',-1,...
            'burstTransfersCompleted',0,...
            'bytesTransferred',0);
        end

        function releaseImpl(obj)
            obj.setgetCtrlID(0);
        end

        function num=getNumInputsImpl(obj)
            num=2;
        end

        function num=getNumOutputsImpl(~)
            num=3;
        end

        function[out1,out2,out3]=getOutputSizeImpl(obj)
            out1=propagatedInputSize(obj,1);
            out2=1;
            out3=1;
        end

        function[out1,out2,out3]=getOutputDataTypeImpl(obj)
            out1=propagatedInputDataType(obj,1);
            out2="uint32";
            out3="Bus:MemCtrlDD2BusObj";
        end

        function[out1,out2,out3]=isOutputComplexImpl(obj)
            out1=propagatedInputComplexity(obj,1);
            out2=false;
            out3=false;
        end

        function entityTypes=getEntityTypesImpl(obj)
            entityTypes=[obj.entityType('request'),obj.entityType('rearb'),obj.entityType('ddlog')];
        end

        function[inputTypes,outputTypes]=getEntityPortsImpl(obj)
            inputTypes={'request','rearb'};
            outputTypes={'request','rearb','ddlog'};
        end

        function[storage,I,O]=getEntityStorageImpl(obj)


            storage(obj.RequestIn)=obj.queueFIFO('request',1);
            storage(obj.RequestArbitration)=obj.queueFIFO('request',1);
            storage(obj.RequestAccepted)=obj.queueFIFO('request',1);
            storage(obj.RequestExecuting)=obj.queueFIFO('request',1);
            storage(obj.RequestComplete)=obj.queueFIFO('request',1);


            storage(obj.RearbIn)=obj.queueFIFO('rearb',1);
            storage(obj.RearbOut)=obj.queueFIFO('rearb',1);


            storage(obj.DDLogOut)=obj.queueFIFO('ddlog',1);


            I=[obj.RequestIn,obj.RearbIn];

            O=[obj.RequestComplete,obj.RearbOut,obj.DDLogOut];
        end










        function s=saveObjectImpl(obj)
            s=saveObjectImpl@matlab.System(obj);
            s.IsMemBusy=obj.setgetIsMemBusy();
            s.Requests=obj.setgetRequestTable();
            s.Pos=obj.setgetArbiterPosition();
        end

        function loadObjectImpl(obj,s,isInUse)
            obj.setgetIsMemBusy(s.IsMemBusy)
            obj.setgetRequestTable(s.Requests);
            obj.setgetArbiterPosition(s.Pos);
            loadObjectImpl@matlab.System(obj,s,isInUse);
        end

        function val=setgetCtrlID(obj,varargin)
            coder.extrinsic('soc.internal.MemoryControllerDES.setgetCtrlID0');
            val=uint32(0);
            val=soc.internal.MemoryControllerDES.setgetCtrlID0(obj.MemorySelection,varargin{:});
        end

        function val=setgetIsMemBusy(obj,varargin)
            coder.extrinsic('soc.internal.MemoryControllerDES.setgetIsMemBusy0');
            val=false;
            val=soc.internal.MemoryControllerDES.setgetIsMemBusy0(obj.MemorySelection,varargin{:});
        end

        function val=setgetArbiterPosition(obj,varargin)
            coder.extrinsic('soc.internal.MemoryControllerDES.setgetArbiterPosition0');
            val=uint32(1);
            val=soc.internal.MemoryControllerDES.setgetArbiterPosition0(obj.MemorySelection,varargin{:});
        end

        function val=setgetRequestTable(obj,varargin)
            coder.extrinsic('soc.internal.MemoryControllerDES.setgetRequestTable0');
            val=uint32(zeros(1,soc.internal.MemoryControllerDES.NumMastersMax));
            val=soc.internal.MemoryControllerDES.setgetRequestTable0(obj.MemorySelection,varargin{:});
        end

        function val=setgetDeratingClockCount(obj,varargin)
            coder.extrinsic('soc.internal.MemoryControllerDES.setgetDeratingClockCount0');
            val=double(0);
            val=soc.internal.MemoryControllerDES.setgetDeratingClockCount0(obj.MemorySelection,varargin{:});
        end

        function val=setgetBytesTransferred(obj,varargin)
            coder.extrinsic('soc.internal.MemoryControllerDES.setgetBytesTransferred0');
            val=double(zeros(1,soc.internal.MemoryControllerDES.NumMastersMax));
            val=soc.internal.MemoryControllerDES.setgetBytesTransferred0(obj.MemorySelection,varargin{:});
        end

        function val=setgetBurstTransfersCompleted(obj,varargin)
            coder.extrinsic('soc.internal.MemoryControllerDES.setgetBurstTransfersCompleted0');
            val=double(zeros(1,soc.internal.MemoryControllerDES.NumMastersMax));
            val=soc.internal.MemoryControllerDES.setgetBurstTransfersCompleted0(obj.MemorySelection,varargin{:});
        end

    end

    methods(Static,Hidden)

        function val=setgetCtrlID0(selStr,varargin)
            persistent count;
            selNum=soc.internal.MemoryControllerDES.MemorySelectionSet.getIndex(selStr);
            if isempty(count)
                count=zeros(soc.internal.MemoryControllerDES.MemorySelectionMax,1,'uint32');
            end
            if nargin>1
                count(selNum)=uint32(varargin{1});
            else
                count(selNum)=count(selNum)+uint32(1);
            end
            val=count(selNum);
        end

        function val=setgetIsMemBusy0(selStr,varargin)
            persistent IsMemBusy;
            selNum=soc.internal.MemoryControllerDES.MemorySelectionSet.getIndex(selStr);
            if isempty(IsMemBusy)
                IsMemBusy=zeros(soc.internal.MemoryControllerDES.MemorySelectionMax,1,'logical');
            end
            if nargin>1
                IsMemBusy(selNum)=logical(varargin{1});
            end

            val=IsMemBusy(selNum);
        end

        function val=setgetArbiterPosition0(selStr,varargin)
            persistent ArbiterPosition;
            selNum=soc.internal.MemoryControllerDES.MemorySelectionSet.getIndex(selStr);
            if isempty(ArbiterPosition)
                ArbiterPosition=ones(soc.internal.MemoryControllerDES.MemorySelectionMax,1,'uint32');
            end
            if nargin>1
                ArbiterPosition(selNum)=uint32(varargin{1});
            end

            val=ArbiterPosition(selNum);
        end

        function val=setgetRequestTable0(selStr,varargin)
            persistent RequestTable;
            selNum=soc.internal.MemoryControllerDES.MemorySelectionSet.getIndex(selStr);
            if isempty(RequestTable)
                RequestTable=zeros(soc.internal.MemoryControllerDES.MemorySelectionMax,soc.internal.MemoryControllerDES.NumMastersMax,'uint32');
            end
            if nargin==2
                RequestTable(selNum,:)=uint32(varargin{1});
            elseif nargin==3
                RequestTable(selNum,varargin{1})=uint32(varargin{2});
            elseif nargin>3
                switch varargin{3}
                case 'inc'
                    RequestTable(selNum,varargin{1})=RequestTable(selNum,varargin{1})+uint32(varargin{2});
                case 'dec'
                    RequestTable(selNum,varargin{1})=RequestTable(selNum,varargin{1})-uint32(varargin{2});
                end
            end

            val=RequestTable(selNum,:);
        end

        function val=setgetDeratingClockCount0(selStr,varargin)
            persistent DeratingClockCount;
            selNum=soc.internal.MemoryControllerDES.MemorySelectionSet.getIndex(selStr);
            if isempty(DeratingClockCount)
                DeratingClockCount=zeros(soc.internal.MemoryControllerDES.MemorySelectionMax,1,'double');
            end
            if nargin>1
                DeratingClockCount(selNum)=double(varargin{1});
            end

            val=DeratingClockCount(selNum);
        end

        function val=setgetBytesTransferred0(selStr,varargin)
            persistent BytesTransferred;
            selNum=soc.internal.MemoryControllerDES.MemorySelectionSet.getIndex(selStr);
            if isempty(BytesTransferred)
                BytesTransferred=zeros(soc.internal.MemoryControllerDES.MemorySelectionMax,soc.internal.MemoryControllerDES.NumMastersMax,'double');
            end
            if nargin==2
                BytesTransferred(selNum,:)=double(varargin{1});
            elseif nargin>2
                BytesTransferred(selNum,varargin{1})=double(varargin{2});
            end

            val=BytesTransferred(selNum,:);
        end

        function val=setgetBurstTransfersCompleted0(selStr,varargin)
            persistent BurstTransfersCompleted;
            selNum=soc.internal.MemoryControllerDES.MemorySelectionSet.getIndex(selStr);
            if isempty(BurstTransfersCompleted)
                BurstTransfersCompleted=zeros(soc.internal.MemoryControllerDES.MemorySelectionMax,soc.internal.MemoryControllerDES.NumMastersMax,'double');
            end
            if nargin==2
                BurstTransfersCompleted(selNum,:)=double(varargin{1});
            elseif nargin>2
                BurstTransfersCompleted(selNum,varargin{1})=double(varargin{2});
            end

            val=BurstTransfersCompleted(selNum,:);
        end

    end

end




