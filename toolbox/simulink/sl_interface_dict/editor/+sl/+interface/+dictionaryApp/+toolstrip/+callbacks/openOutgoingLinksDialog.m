function openOutgoingLinksDialog(cbinfo)





    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    selectedNodes=guiObj.getSelectedNodes();

    assert(numel(selectedNodes)==1,'only one item can be selected for requirements');
    entryName=selectedNodes{1}.Name;
    dictAPI=guiObj.getInterfaceDictObj;
    assert(contains(entryName,...
    [dictAPI.getDataTypeNames,dictAPI.getInterfaceNames]),...
    '%s is not an interface or datatype node',entryName);
    dictFilePath=dictAPI.filepath();

    entryID=getEntryID(dictAPI.SLDDConn,entryName);
    reqs=slreq.getReqs(dictFilePath,entryID,'linktype_rmi_data');

    linkSourceID=[dictFilePath,'|Global.',entryName];
    ReqMgr.rmidlg_mgr('data',linkSourceID,reqs,-1,-1,-1);
end

function entryID=getEntryID(ddConn,entryName)
    ddId=ddConn.getEntryID(['Global.',entryName]);
    info=ddConn.getEntryInfo(ddId);
    entryID=['UUID_',info.UUID.char];
end
