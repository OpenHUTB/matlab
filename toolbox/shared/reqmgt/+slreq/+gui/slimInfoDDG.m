function linkInfoPanel=slimInfoDDG(selectedItem)




    if isa(selectedItem,'Stateflow.Object')
        modelName=selectedItem.Machine.Name;
    else
        modelName=get_param(bdroot(selectedItem),'Name');
    end




    linkInfoPanel=slreq.gui.LinkDetails.getDialogSchema(selectedItem,modelName);
end
