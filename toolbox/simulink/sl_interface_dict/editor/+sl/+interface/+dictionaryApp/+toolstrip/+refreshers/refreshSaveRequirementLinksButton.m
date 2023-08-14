function refreshSaveRequirementLinksButton(cbinfo,action)




    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    dictAPI=guiObj.getInterfaceDictObj();
    if~isempty(dictAPI)&&isvalid(dictAPI)
        dictFilePath=dictAPI.filepath();
        pathToSLMX=slreq.getLinkFilePath(dictFilePath);
        [~,slmxFileName,ext]=fileparts(pathToSLMX);
        slmxFile=[slmxFileName,ext];
        action.description=DAStudio.message("interface_dictionary:toolstrip:SaveRequirementLinksDescription",slmxFile);
        if slreq.hasChanges(dictFilePath)
            action.enabled=true;
        else
            action.enabled=false;
        end
    end
end


