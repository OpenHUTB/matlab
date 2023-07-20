function varargout=MemoryInterconnectControllerCodegenCb(varargin)

%#codegen
    coder.allowpcode('plain');
    switch varargin{1}
    case 'ICBurstExecutionServiceTimeAction'
        [varargout{1:nargout}]=ICBurstExecutionServiceTimeAction(varargin{2:end});
    case 'BurstStartServiceTimeAction'
        [varargout{1:nargout}]=BurstStartServiceTimeAction(varargin{2:end});
    case 'BurstExecutionServiceTimeAction'
        [varargout{1:nargout}]=BurstExecutionServiceTimeAction(varargin{2:end});
    case 'BurstCompletionServiceTimeAction'
        [varargout{1:nargout}]=BurstCompletionServiceTimeAction(varargin{2:end});
    case 'DDEventLogger2'
        [varargout{1:nargout}]=DDEventLogger2(varargin{2:end});
    case 'ICDpathDDEventLogger'
        [varargout{1:nargout}]=ICDpathDDEventLogger(varargin{2:end});
    case 'GenDummyBurstRequest'
        [varargout{1:nargout}]=GenDummyBurstRequest(varargin{2:end});
    otherwise
        error(message('soc:msgs:InternalUnknownCodegenFunction',...
        varargin{1},'MemoryInterconnectControllerCodegenCb'));
    end
end


function dt=ICBurstExecutionServiceTimeAction(p)
    dt=p.BurstSize/(p.ICClockFrequency*1e6*(p.ICDataWidth/8));
end


...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
...
function dt=BurstStartServiceTimeAction(p)
    ctrlrClkPer=1/(p.ControllerClockFrequency*1e6);

    switch p.ReqKind
    case MasterKindEnum.Reader
        startLatencyDDRClks=p.ReadFirstTransferLatency;
    case MasterKindEnum.Writer
        startLatencyDDRClks=p.WriteFirstTransferLatency;
    otherwise
        startLatencyDDRClks=p.WriteFirstTransferLatency;
    end

    startDelayTime=(startLatencyDDRClks*ctrlrClkPer);

    dt=startDelayTime;
end

function[dt,deratingClockCount]=BurstExecutionServiceTimeAction(p,deratingClockCount)





    DERATING_CLOCK_INTERVAL=100;

    ctrlrByteWidth=(p.ControllerDataWidth/8);
    ctrlrClkPer=1/(p.ControllerClockFrequency*1e6);
    xferTimeBurst=p.BurstSize/(ctrlrByteWidth/ctrlrClkPer);

    deratingClockCount=deratingClockCount+(xferTimeBurst/ctrlrClkPer);
    if(deratingClockCount>DERATING_CLOCK_INTERVAL)
        deratingTime=(deratingClockCount/DERATING_CLOCK_INTERVAL)*(p.BandwidthDerating*ctrlrClkPer);
        deratingClockCount=0;
    else
        deratingTime=0;
    end

    dt=xferTimeBurst+deratingTime;
end

function dt=BurstCompletionServiceTimeAction(p)
    ctrlrClkPer=1/(p.ControllerClockFrequency*1e6);

    switch p.ReqKind
    case MasterKindEnum.Reader
        endLatencyDDRClks=p.ReadLastTransferLatency;
    case MasterKindEnum.Writer
        endLatencyDDRClks=p.WriteLastTransferLatency;
    otherwise
        endLatencyDDRClks=p.WriteLastTransferLatency;
    end

    dt=endLatencyDDRClks*ctrlrClkPer;
end

function[xen,s]=GenDummyBurstRequest(burstSize,interAccessTimes)

    a=interAccessTimes(2);
    b=interAccessTimes(3);
    xen=(b-a)*rand(1,1)+a;


    s=burstSize;

end

function[diagData,currBurstSize,rBytesTransferred,rBurstTransfersCompleted]=DDEventLogger2(portID,...
    event,info,timestamp,diagData,currBurstSize,rBytesTransferred,rBurstTransfersCompleted,overall)




    switch event

    case DDEvent2.BurstRequest
        diagData(portID).BURST_EXECUTION_EVENT=event;
        diagData(portID).masterID=info(1);
        diagData(portID).reqID=info(2);
        diagData(portID).size=info(3);
        diagData(portID).address=info(4);


    case DDEvent2.BurstAccepted
        diagData(portID).BURST_EXECUTION_EVENT=event;
        diagData(portID).masterID=info(1);
        diagData(portID).reqID=info(2);
        diagData(portID).size=info(3);
        diagData(portID).address=info(4);

    case DDEvent2.BurstExecuting



        diagData(portID).BURST_EXECUTION_EVENT=event;
        diagData(portID).masterID=info(1);
        diagData(portID).reqID=info(2);
        diagData(portID).size=info(3);
        diagData(portID).address=info(4);




        diagData(overall).BURST_EXECUTION_EVENT=event;
        diagData(overall).masterID=info(1);
        diagData(overall).reqID=info(2);
        diagData(overall).size=info(3);
        diagData(overall).address=info(4);

        currBurstSize=info(3);

    case DDEvent2.BurstDone
        rBytesTransferred(portID)=rBytesTransferred(portID)+currBurstSize;
        rBurstTransfersCompleted(portID)=rBurstTransfersCompleted(portID)+1;
        diagData(portID).BURST_EXECUTION_EVENT=event;
        diagData(portID).masterID=info(1);
        diagData(portID).reqID=info(2);
        diagData(portID).size=info(3);
        diagData(portID).address=info(4);
        diagData(portID).bytesTransferred=rBytesTransferred(portID);
        diagData(portID).burstTransfersCompleted=rBurstTransfersCompleted(portID);

        rBytesTransferred(overall)=rBytesTransferred(overall)+currBurstSize;
        rBurstTransfersCompleted(overall)=rBurstTransfersCompleted(overall)+1;
        diagData(overall).BURST_EXECUTION_EVENT=event;
        diagData(overall).masterID=info(1);
        diagData(overall).reqID=info(2);
        diagData(overall).size=info(3);
        diagData(overall).address=info(4);
        diagData(overall).bytesTransferred=rBytesTransferred(overall);
        diagData(overall).burstTransfersCompleted=rBurstTransfersCompleted(overall);

        currBurstSize=0;

    case DDEvent2.BurstComplete
        diagData(portID).BURST_EXECUTION_EVENT=event;
        diagData(portID).masterID=-1;
        diagData(portID).reqID=-1;
        diagData(portID).size=-1;
        diagData(portID).address=-1;

        diagData(overall).BURST_EXECUTION_EVENT=event;
        diagData(overall).masterID=-1;
        diagData(overall).reqID=-1;
        diagData(overall).size=-1;
        diagData(overall).address=-1;

    otherwise

    end
end
