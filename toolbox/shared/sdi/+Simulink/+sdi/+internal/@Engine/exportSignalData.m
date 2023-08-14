function[sigData,structuredDataForExport,props]=exportSignalData(this,signalID)









    sigData=Simulink.SimulationData.Signal();
    bCreateTimeseries=nargout<3;
    bSetMetaData=true;


    rootSigID=this.sigRepository.getHierarchicalSignalRootID(signalID);
    props=this.sigRepository.getSignalExportProps(signalID);
    props.BlockPath=Simulink.sdi.internal.BlockPathUtils.createSignalPath(props.BlockPath');
    if bCreateTimeseries
        sigData.Values=this.exportSignalToTimeSeries(signalID,true,'SigProps',props);
    else
        dataVals=this.getSignalDataValues(signalID,true,false);



        props.Data=reshape(dataVals.Data,1,length(dataVals.Data));
        props.Time=reshape(dataVals.Time,1,length(dataVals.Time));
        props.UserData=[];
    end
    structuredDataForExport=[];


    if bSetMetaData
        sigData.Name=props.Name;
        sigData.PortType='outport';
        if props.PortIndex>1
            sigData.PortIndex=props.PortIndex;
        end
        sigData.BlockPath=props.BlockPath;
    end
end
