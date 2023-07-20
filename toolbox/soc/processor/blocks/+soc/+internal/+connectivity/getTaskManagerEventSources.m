function theMap=getTaskManagerEventSources(modelName)




    import soc.internal.connectivity.*

    theMap=[];
    tskMgrBlk=getTaskManagerBlock(modelName);
    tmEventPorts=getSystemInputPorts(tskMgrBlk);
    if isempty(tmEventPorts),return;end
    tskMgrName=get_param(tskMgrBlk,'Name');
    tskMgrFullName=[modelName,'/',tskMgrName];
    theMap=containers.Map('KeyType','char','ValueType','any');
    tskMgrConnections=get_param(tskMgrFullName,'PortConnectivity');
    for idx=1:numel(tskMgrConnections)
        thisPort=tskMgrConnections(idx);
        thisPortSrcBlk=thisPort.SrcBlock;
        if~isequal(get_param(thisPortSrcBlk,'MaskType'),'IO Data Source')
            continue
        end
        if~isempty(thisPortSrcBlk)
            taskMgrEventInportBlk=tmEventPorts{str2double(thisPort.Type)};
            partToStrip=[modelName,'/',tskMgrName,'/'];
            tskMgrEventPortLbl=strrep(taskMgrEventInportBlk,partToStrip,'');
            tskName=strrep(tskMgrEventPortLbl,'Event','');
            myStruct.SrcBlkName=get_param(thisPortSrcBlk,'Name');
            myStruct.SrcBlkHandle=get_param(thisPortSrcBlk,'Handle');
            myStruct.IsFromDialog=isequal(get_param(thisPortSrcBlk,'InputSource'),'From dialog');
            myStruct.IsFromInputPort=isequal(get_param(thisPortSrcBlk,'InputSource'),'From input port');
            myStruct.IsFromFile=isequal(get_param(thisPortSrcBlk,'InputSource'),'From file');
            myStruct.IsFromTimeseriesObject=isequal(get_param(thisPortSrcBlk,'InputSource'),'From timeseries object');
            myStruct.SampleTime=str2double(get_param(thisPortSrcBlk,'SampleTime'));
            myStruct.DatasetName=(get_param(thisPortSrcBlk,'DatasetName'));
            myStruct.SourceName=(get_param(thisPortSrcBlk,'SourceName'));
            myStruct.ObjectName=(get_param(thisPortSrcBlk,'ObjectName'));
            theMap(tskName)=myStruct;
        end
    end
end
