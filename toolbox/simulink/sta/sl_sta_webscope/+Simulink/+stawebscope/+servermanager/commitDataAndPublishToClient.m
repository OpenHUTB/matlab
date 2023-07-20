function commitDataAndPublishToClient(clientMsg,editedData)






    item=clientMsg.Item;
    sigName=item.name;
    repoUtil=starepository.RepositoryUtility();
    [rootID,sigID]=Simulink.stawebscope.servermanager.util.getRootAndSigID(item);
    metaData_sig=repoUtil.getMetaDataStructure(sigID);

    dataType=metaData_sig.DataType;
    if strcmp(dataType,'fcn_call')
        interpMode='';
        isEnum=false;
        isFixDT=false;
        dataType='double';
    else
        interpMode=item.Interpolation;
        isEnum=false;
        if isfield(item,'isEnum')
            isEnum=item.isEnum;
        end
        isFixDT=contains(dataType,'fixdt');
    end

    forceAxesRedraw=true;

    slwebwidgets.tableeditor.updateSignalDataMW(clientMsg.ClientId,sigName,rootID,sigID,interpMode,dataType,editedData,isEnum,isFixDT,forceAxesRedraw,clientMsg.tableID);

end
