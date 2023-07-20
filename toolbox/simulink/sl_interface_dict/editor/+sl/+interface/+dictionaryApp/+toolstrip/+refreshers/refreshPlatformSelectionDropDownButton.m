function refreshPlatformSelectionDropDownButton(cbinfo,action)





    contextObj=cbinfo.Context.Object;
    selectedPlatformId=contextObj.SelectedPlatformId;


    selectedPlatformId=regexprep(selectedPlatformId,' ','\n');


    action.text=slservices.StringOrID(selectedPlatformId);

end


