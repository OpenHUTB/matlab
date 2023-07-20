function connectedRows=createConnectedSignalMap(this)




    lgSignals=stm.internal.getLoggedSignals(this.signalInfo.signalSetId,true,true);

    if~isempty(lgSignals)
        [connectedRows,keys]=arrayfun(@(x)getBindableRowFromSignal(x),lgSignals,'UniformOutput',false);

        this.signalInfo.signalIDMap=containers.Map(keys,{lgSignals.id});
    else
        connectedRows=[];
        this.signalInfo.signalIDMap=containers.Map();
    end
end

function[row,rowId]=getBindableRowFromSignal(lgSignal)

    binModeMetaDataStruct=struct(...
    'name',lgSignal.Name,...
    'blockPathStr',lgSignal.BlockPath...
    );



    subPathArr=strsplit(lgSignal.HierarchicalPath,'|');
    binModeMetaDataStruct.hierarchicalPathArr=[lgSignal.HierarchicalPath,subPathArr];


    if lgSignal.ElementType==1
        sigMetaData=BindMode.SLDSMMetaData(binModeMetaDataStruct);
        rowId=sigMetaData.id;
        row=BindMode.BindableRow(true,BindMode.BindableTypeEnum.DSM,sigMetaData.name,sigMetaData);
    elseif lgSignal.ElementType==2
        binModeMetaDataStruct.workspaceTypeStr=lgSignal.SDIBlockPath;
        sigMetaData=BindMode.VariableMetaData(binModeMetaDataStruct);
        rowId=sigMetaData.id;
        row=BindMode.BindableRow(true,BindMode.BindableTypeEnum.VARIABLE,sigMetaData.name,sigMetaData);
    elseif lgSignal.ElementType==3
        binModeMetaDataStruct.outputPortNumber=lgSignal.PortIndex;
        sigMetaData=BindMode.SLBusElementMetaData(binModeMetaDataStruct);
        rowId=sigMetaData.id;
        row=BindMode.BindableRow(true,BindMode.BindableTypeEnum.BUSLEAFSIGNAL,sigMetaData.name,sigMetaData);
    else

        type=BindMode.BindableTypeEnum.SLSIGNAL;
        binModeMetaDataStruct.outputPortNumber=lgSignal.PortIndex;
        sigMetaData=BindMode.SLSignalMetaData(binModeMetaDataStruct);
        rowId=sigMetaData.id;
        if lgSignal.ElementType==4
            type=BindMode.BindableTypeEnum.BUSOBJECT;
        end
        row=BindMode.BindableRow(true,type,sigMetaData.name,sigMetaData);
    end
end