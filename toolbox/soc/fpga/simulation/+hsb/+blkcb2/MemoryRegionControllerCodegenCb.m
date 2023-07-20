function varargout=MemoryRegionControllerCodegenCb(varargin)

%#codegen
    coder.allowpcode('plain');

    switch varargin{1}
    case 'calcBufBaseAddresses'
        [varargout{1:nargout}]=calcBufBaseAddresses(varargin{2:end});
    case 'checkAddressRange'
        [varargout{1:nargout}]=checkAddressRange(varargin{2:end});
    case 'DDEventLoggerLevel1'
        [varargout{1:nargout}]=DDEventLoggerLevel1(varargin{2:end});
    case 'DDEventLoggerLevel2'
        [varargout{1:nargout}]=DDEventLoggerLevel2(varargin{2:end});
    case 'DDEventLoggerLevel3'
        [varargout{1:nargout}]=DDEventLoggerLevel3(varargin{2:end});
    otherwise
        error(message('soc:msgs:InternalUnknownCodegenFunction',...
        varargin{1},'MemoryRegionControllerCodegenCb'));
    end
end

function baseAddr=calcBufBaseAddresses(regionBase,numBuf,alignedBufSize)

    baseAddr=zeros(1,numBuf);












    currOffset=0;
    for idx=1:numBuf
        baseAddr(idx)=currOffset;
        currOffset=currOffset+alignedBufSize;
    end

    baseAddr=baseAddr';

end

function checkAddressRange(checkEnabled,startA,endA,size)
    if checkEnabled
        addrBoundary=4096;
        tooLarge=size>addrBoundary;
        startRem=rem(startA,addrBoundary);
        endRem=rem(endA,addrBoundary);
        crossesBoundary=startRem>endRem;

        assert(~tooLarge&&~crossesBoundary,...
        ['Burst transaction crosses an AXI address boundary.  This is illegal for AXI transactions.\n',...
        'start addr      : 0x%08x\n',...
        'end addr        : 0x%08x\n',...
        'boundary every  : 0x%08x\n'],startA,endA,addrBoundary);
    end
end


function diag=DDEventLoggerLevel1(mID,event,info)
    persistent diagData

    persistent rBufTransfersCompleted
    persistent rFIFODroppedCount rBurstTransfersCompleted
    if isempty(diagData)
        d=struct(...
        'bufAddress',-1,...
        'bufAvail',-1,...
        'bufTransfersCompleted',0,...
        'icFIFOEntries',0,...
        'icFIFODroppedCount',0,...
        'burstAddress',-1,...
        'burstTransfersCompleted',0...
        );
        MASTER_DIM=[2,1];
        diagData=repmat(d,MASTER_DIM);
        rBufTransfersCompleted=zeros(MASTER_DIM);
        rFIFODroppedCount=zeros(MASTER_DIM);
        rBurstTransfersCompleted=zeros(MASTER_DIM);
    end

    switch event
    case DDEvent2.BufRequest
        diagData(mID).bufAvail=info(2);
    case DDEvent2.BufGrant
        diagData(mID).bufAddress=info(2);
        diagData(mID).bufAvail=info(3);
    case DDEvent2.BufDone
        diagData(mID).bufAvail=info(2);
    case DDEvent2.BufAck
        rBufTransfersCompleted(mID)=rBufTransfersCompleted(mID)+1;
        diagData(mID).bufAddress=info(2);
        diagData(mID).bufAvail=info(3);
        diagData(mID).bufTransfersCompleted=rBufTransfersCompleted(mID);

    case DDEvent2.FIFOEntries
        rFIFODroppedCount(mID)=rFIFODroppedCount(mID)+info(2);
        diagData(mID).icFIFOEntries=info(1);
        diagData(mID).icFIFODroppedCount=rFIFODroppedCount(mID);

    case DDEvent2.BurstRequest
        diagData(mID).burstAddress=info(2);
    case DDEvent2.BurstDone
        rBurstTransfersCompleted(mID)=rBurstTransfersCompleted(mID)+1;
        diagData(mID).burstTransfersCompleted=rBurstTransfersCompleted(mID);
    otherwise

    end
    diag=diagData;
end
function diag=DDEventLoggerLevel2(mID,event,info)
    persistent diagData

    persistent rBufTransfersCompleted
    persistent rInflowQueueCount rInflowDroppedCount
    persistent rFIFODroppedCount rICTransfersCompleted rBurstTransfersCompleted
    persistent rBufAvail
    if isempty(diagData)
        d=struct(...
        'NEW_TRANSACTION_EVENT',DDEvent2.BufIdle,...
        'accessID',-1,...
        'accessSize',0,...
        'REGION_BUFFER_EVENT',DDEvent2.BufIdle,...
        'bufReqID',-1,...
        'bufGntCurrentBuf',0,...
        'bufRelCurrentBuf',0,...
        'bufAddress',-1,...
        'bufAvail',0,...
        'bufTransfersCompleted',0,...
        'INFLOW_QUEUE_EVENT',DDEvent2.InflowIdle,...
        'inflowQueueCount',0,...
        'inflowDroppedCount',0,...
        'IC_DATAPATH_EVENT',DDEvent2.ICDatapathIdle,...
        'icFIFOEntries',0,...
        'icFIFODroppedCount',0,...
        'icReqID',-1,...
        'icAddress',-1,...
        'icTransfersCompleted',0,...
        'BURST_EXECUTION_EVENT',DDEvent2.BurstIdle,...
        'burstReqID',-1,...
        'burstAddress',-1,...
        'burstTransfersCompleted',0,...
        'SW_INTERFACE_EVENT',DDEvent2.FrameIdle,...
        'newFrameReady',0,...
        'contFrameReady',0,...
        'validFrame',0,...
        'buffersAvailable',0,...
        'continueTransfers',0...
        );
        MASTER_DIM=[2,1];
        diagData=repmat(d,MASTER_DIM);
        rBufTransfersCompleted=zeros(MASTER_DIM);
        rInflowQueueCount=zeros(MASTER_DIM);
        rInflowDroppedCount=zeros(MASTER_DIM);
        rFIFODroppedCount=zeros(MASTER_DIM);
        rICTransfersCompleted=zeros(MASTER_DIM);
        rBurstTransfersCompleted=zeros(MASTER_DIM);
        rBufAvail=0;
    end

    switch event
    case DDEvent2.NewTransaction
        diagData(mID).NEW_TRANSACTION_EVENT=event;
        diagData(mID).accessID=info(1);
        diagData(mID).accessSize=info(2);

    case DDEvent2.BufIdle
        diagData(mID).REGION_BUFFER_EVENT=event;
    case DDEvent2.BufRequest
        diagData(mID).REGION_BUFFER_EVENT=event;
        diagData(mID).bufReqID=info(1);
    case DDEvent2.BufGrant
        diagData(mID).REGION_BUFFER_EVENT=event;
        diagData(mID).bufGntCurrentBuf=info(1);
        diagData(mID).bufAddress=info(2);
    case DDEvent2.BufExecuting
        diagData(mID).REGION_BUFFER_EVENT=event;
    case DDEvent2.BufDone
        diagData(mID).REGION_BUFFER_EVENT=event;
        diagData(mID).bufReqID=info(1);
    case DDEvent2.BufAck
        rBufTransfersCompleted(mID)=rBufTransfersCompleted(mID)+1;
        diagData(mID).REGION_BUFFER_EVENT=event;
        diagData(mID).bufRelCurrentBuf=info(1);
        diagData(mID).bufAddress=info(2);




        if mID==1
            rBufAvail=rBufAvail+1;
        else
            rBufAvail=rBufAvail-1;
        end
        diagData(1).bufAvail=rBufAvail;
        diagData(2).bufAvail=rBufAvail;
        diagData(mID).bufTransfersCompleted=rBufTransfersCompleted(mID);

    case DDEvent2.InflowQueueChange
        rInflowQueueCount(mID)=rInflowQueueCount(mID)+info(1);
        diagData(mID).INFLOW_QUEUE_EVENT=event;
        diagData(mID).inflowQueueCount=rInflowQueueCount(mID);
    case DDEvent2.InflowQueueOverflow
        rInflowDroppedCount(mID)=rInflowDroppedCount(mID)+info(1);
        diagData(mID).INFLOW_QUEUE_EVENT=event;
        diagData(mID).inflowDroppedCount=rInflowDroppedCount(mID);

    case DDEvent2.FIFOEntries
        rFIFODroppedCount(mID)=rFIFODroppedCount(mID)+info(2);
        diagData(mID).IC_DATAPATH_EVENT=event;
        diagData(mID).icFIFOEntries=info(1);
        diagData(mID).icFIFODroppedCount=rFIFODroppedCount(mID);

    case DDEvent2.ICExecuting
        diagData(mID).IC_DATAPATH_EVENT=event;
        diagData(mID).icReqID=info(1);
        diagData(mID).icAddress=info(2);
    case DDEvent2.ICDone
        rICTransfersCompleted(mID)=rICTransfersCompleted(mID)+1;
        diagData(mID).IC_DATAPATH_EVENT=event;
        diagData(mID).icTransfersCompleted=rICTransfersCompleted(mID);

    case DDEvent2.BurstRequest
        diagData(mID).BURST_EXECUTION_EVENT=event;
        diagData(mID).burstReqID=info(1);
        diagData(mID).burstAddress=info(2);
    case DDEvent2.BurstDone
        rBurstTransfersCompleted(mID)=rBurstTransfersCompleted(mID)+1;
        diagData(mID).BURST_EXECUTION_EVENT=event;
        diagData(mID).burstTransfersCompleted=rBurstTransfersCompleted(mID);

    case DDEvent2.FrameReady
        diagData(mID).SW_INTERFACE_EVENT=event;
        diagData(mID).buffersAvailable=info(1);
    case DDEvent2.FrameDone
        diagData(mID).SW_INTERFACE_EVENT=event;
        diagData(mID).buffersAvailable=info(1);

    otherwise

    end
    diag=diagData;
end

function diag=DDEventLoggerLevel3(mID,event,info)

    diag=DDEventLoggerLevel2(mID,event,info);
end

function ddOut=DDEventLogger(NUM_PORTS,tr,p)

    persistent dda avg_req2exec avg_exec

    if isempty(dda)



        defval=struct(...
        'trBufferEvent',DDEvent.none,...
        'trBufferRequestID',0,...
        'trBufferAddress',-1,...
        'trBufferID',-1,...
        'trBuffersAvailable',0,...
        'trBufferAvgRequestToExecutionTime',0,...
        'trBufferAvgExecutionTime',0,...
        'trTotalBuffersExecuted',0...
        );

        dda=repmat(defval,[NUM_PORTS,1]);

        defstate=struct(...
        'startTimestamp',0,...
        'currCount',0,...
        'currAvg',0,...
        'currBytes',0...
        );
        avg_req2exec=repmat(defstate,[NUM_PORTS,1]);
        avg_exec=repmat(defstate,[NUM_PORTS,1]);
    end

    dda(tr.reqKind).trBufferEvent=p.event;
    dda(tr.reqKind).trBuffersAvailable=p.bufAvail;

    switch p.event
    case DDEvent.request
        dda(tr.reqKind).trBufferRequestID=tr.reqID;
        avg_req2exec(tr.reqKind).startTimestamp=p.timestamp;
    case DDEvent.executing
        dda(tr.reqKind).trBufferAddress=tr.buffAddr;
        dda(tr.reqKind).trBufferID=tr.buffID;
        avg_req2exec(tr.reqKind)=l_calcNewAverage(avg_req2exec(tr.reqKind),p.timestamp);
        avg_exec(tr.reqKind).startTimestamp=p.timestamp;
    case DDEvent.done
        avg_exec(tr.reqKind)=l_calcNewAverage(avg_exec(tr.reqKind),p.timestamp);
        avg_exec(tr.reqKind).currBytes=0;
    otherwise
    end

    dda(tr.reqKind).trBufferAvgRequestToExecutionTime=avg_req2exec(tr.reqKind).currAvg;
    dda(tr.reqKind).trBufferAvgExecutionTime=avg_exec(tr.reqKind).currAvg;
    dda(tr.reqKind).trTotalBuffersExecuted=avg_exec(tr.reqKind).currCount;

    ddOut=dda;

end


function stat=l_calcNewAverage(stat,timestamp)
    newVal=timestamp-stat.startTimestamp;
    newNum=stat.currCount+1;
    newAvg=((stat.currAvg*stat.currCount)+newVal)/(newNum);

    stat.currAvg=newAvg;
    stat.currCount=newNum;
end

