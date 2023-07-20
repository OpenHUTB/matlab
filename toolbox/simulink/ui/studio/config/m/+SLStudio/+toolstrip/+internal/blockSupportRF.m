



function blockSupportRF(userdata,cbinfo,action)


    action.enabled=strcmp(cbinfo.editorModel.Name,'simulink');


    action.selected=strcmpi(slprivate('hilite_option'),userdata);
end
