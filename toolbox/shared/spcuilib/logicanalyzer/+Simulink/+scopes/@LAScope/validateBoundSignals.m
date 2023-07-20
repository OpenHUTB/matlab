function[validSignals,invalidSignals]=validateBoundSignals(this)





    validSignals=[];
    invalidSignals=[];




    if this.NeedToConnectSignals
        [validSignals,~]=Simulink.scopes.LAScope.getInstrumentedSignals(this.ModelName);
        this.NeedToConnectSignals=false;
        return;
    else
        boundSignals=this.getBoundSignals();
        if isempty(boundSignals)
            return;
        end
    end


    numSignals=length(boundSignals);
    validSignals=cell(1,numSignals);
    vIndx=1;
    invalidSignals=cell(1,numSignals);
    invIndx=1;


    for idx=1:numSignals
        boundSignal=boundSignals(idx);
        portH=boundSignal.PortHandle;






        isPortHandleValid=ishandle(portH)&&slInternal('isValidSimulinkHandleForCLAPI',portH)...
        &&~isequal(get_param(get_param(portH,'Parent'),'Handle'),-1);
        if boundSignal.isSF
            isStatePort=true;
        else
            isStatePort=checkIfStateLogging(this.ModelName,portH);
        end
        if isPortHandleValid&&~isStatePort




            boundSignal.OutputPortIndex=get_param(portH,'PortNumber');
            blkPath=get_param(portH,'Parent');
            boundSignal.BlockPath_=blkPath;
            boundSignal.BlockPath{1}=blkPath;
            validSignals{vIndx}=boundSignal;
            vIndx=vIndx+1;
        elseif boundSignal.isSF





            boundSignal.BlockPath_=boundSignal.BlockPath{1};
            validSignals{vIndx}=boundSignal;
            vIndx=vIndx+1;
        else


            invalidSignals{invIndx}=boundSignal;
            invIndx=invIndx+1;
        end
    end
    validSignals=[validSignals{:}];
    invalidSignals=[invalidSignals{:}];
end
function isStatePort=checkIfStateLogging(ModelName,portH)
    if~strcmp(get_param(ModelName,'LoggingUnavailableSignals'),'none')
        isStatePort=false;
    elseif isempty(get_param(portH,'CompiledBusType'))||strcmp(get_param(portH,'CompiledBusType'),'NOT_BUS')
        isStatePort=strcmp(get_param(portH,'PortType'),'state');
    else
        busStruct=get_param(portH,'CompiledBusStruct')';

        for indx=1:length(busStruct.signals)
            leaf=busStruct.signals(indx);
            isLeafABus=~isempty(leaf.signals);
            leafObj=get_param(leaf.src,'Object');
            if~isLeafABus&&(length(leafObj.PortHandles.Outport)<leaf.srcPort+1)


                isStatePort=true;
                break;
            end
            if~isLeafABus||(isLeafABus&&~isempty(leaf.busObjectName))
                isStatePort=false;
                continue;
            else

                isStatePort=checkIfStateLogging(ModelName,leafObj.PortHandles.Outport(leaf.srcPort+1));
            end
        end
    end
end


