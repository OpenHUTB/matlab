function refreshOpenOutgoingLinksDialog(cbinfo,action)







    contextObj=cbinfo.Context.Object;
    guiObj=contextObj.GuiObj;
    selectedNodes=guiObj.getSelectedNodes();
    if(numel(selectedNodes)==1)
        dictAPI=guiObj.getInterfaceDictObj();
        action.enabled=contains(selectedNodes{1}.Name,...
        [dictAPI.getDataTypeNames,dictAPI.getInterfaceNames]);
    else
        action.enabled=false;
    end

end


