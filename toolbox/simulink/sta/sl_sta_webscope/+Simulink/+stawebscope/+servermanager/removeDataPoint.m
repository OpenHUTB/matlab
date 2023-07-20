function editedData=removeDataPoint(dataPointToRemove,inputData,item)





    editedData=cell(length(inputData)-length(dataPointToRemove),1);
    dataForTableId=length(editedData);
    IndexOfPointToDelete=length(dataPointToRemove);

    [rootID,sigID]=Simulink.stawebscope.servermanager.util.getRootAndSigID(item);
    repoUtil=starepository.RepositoryUtility();
    metaData_sig=repoUtil.getMetaDataStructure(sigID);
    metaData_parent=repoUtil.getMetaDataStructure(rootID);

    if metaData_sig.TreeOrder~=metaData_parent.TreeOrder
        columnLocation=metaData_sig.TreeOrder-metaData_parent.TreeOrder+1;
    else
        columnLocation=2;
    end

    for id=length(inputData):-1:1
        sigTime=inputData{id}{1};

        if ischar(sigTime)
            sigTime=str2double(sigTime);
        end

        if IndexOfPointToDelete>0&&...
            dataPointToRemove(IndexOfPointToDelete).x==sigTime
            indexY=1;
            if length(dataPointToRemove(IndexOfPointToDelete).y)>1&&...
                ~ischar(dataPointToRemove(IndexOfPointToDelete).y)
                indexY=columnLocation-1;
            end
            dataToRemoveY=dataPointToRemove(IndexOfPointToDelete).y(indexY);
            if iscell(dataToRemoveY)
                dataToRemoveY=dataToRemoveY{1};
            end
            dataToRemoveY=Simulink.stawebscope.servermanager.util.processData(dataToRemoveY,item);
            sigData=inputData{id}{columnLocation};
            sigData=Simulink.stawebscope.servermanager.util.processData(sigData,item);
            if Simulink.stawebscope.servermanager.util.compareData(dataToRemoveY,sigData)

                IndexOfPointToDelete=IndexOfPointToDelete-1;
            else
                editedData{dataForTableId}=inputData{id};
                dataForTableId=dataForTableId-1;
            end
        else
            editedData{dataForTableId}=inputData{id};
            dataForTableId=dataForTableId-1;
        end
    end

end
