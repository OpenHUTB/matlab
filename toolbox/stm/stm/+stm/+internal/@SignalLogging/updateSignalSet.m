function success=updateSignalSet(this,~,bindableType,bindableName,bindableMetaData,isChecked)












    if isChecked

        sdiBlockPath=stm.internal.SignalLogging.constructBlockPathToDisplay(...
        bindableMetaData.hierarchicalPathArr(2:end));


        fullPath=bindableMetaData.hierarchicalPathArr{1};
        tmp=strfind(fullPath,'/');
        topModel=fullPath(1:tmp(1)-1);

        outPortNumber=0;
        if isfield(bindableMetaData,'outputPortNumber')
            outPortNumber=bindableMetaData.outputPortNumber;
        end


        typeIdArr=["SLSIGNAL","DSM","VARIABLE","BUSLEAFSIGNAL","BUSOBJECT"];
        elemType=find(strcmp(typeIdArr,bindableType))-1;

        if strcmp(bindableType,'VARIABLE')
            elemType=2;


            sdiBlockPath=string(bindableMetaData.workspaceTypeStr);
            bindableName=bindableMetaData.name;

            if~stm.internal.VariableReader.DataDictionary.isSldd(bindableMetaData.workspaceTypeStr)
                sdiBlockPath=sdiBlockPath.append(' workspace');
            end
        end

        if strcmp(bindableType,'BUSOBJECT')

            indx=strfind(bindableName,'(');
            bindableName=bindableName(1:(indx(end)-2));
        end

        signalId=stm.internal.addLoggedSignal(this.signalInfo.signalSetId,...
        bindableName,bindableMetaData.blockPathStr,sdiBlockPath,...
        outPortNumber,fullPath,topModel,elemType);



        if signalId>0
            this.signalInfo.signalIDMap(bindableMetaData.id)=signalId;
        end
    else

        if this.signalInfo.signalIDMap.isKey(bindableMetaData.id)
            stm.internal.removeOutputObject(this.signalInfo.signalIDMap(bindableMetaData.id),'outputsignal');
        end
    end

    if strcmp(bindableType,'BUSOBJECT')
        stm.internal.SignalLogging.updateAllLeafSignals(bindableMetaData,isChecked);
    end
    success=true;
end
