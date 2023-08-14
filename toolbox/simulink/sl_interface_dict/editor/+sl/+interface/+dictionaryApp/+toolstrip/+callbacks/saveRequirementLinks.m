function saveRequirementLinks(cbinfo)




    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    dictAPI=guiObj.getInterfaceDictObj;
    if~isempty(dictAPI)&&isvalid(dictAPI)
        dictFilePath=dictAPI.filepath();
        slreq.saveLinks(dictFilePath);
    end
end
