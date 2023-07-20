function editingModes=editingModeCallback(event,handle)




    if strcmp(get_param(handle,'MaskType'),'P-H Diagram (2P)')
        editingModes=struct('maskName',{},'editingMode',{});
    else
        editingModes=simscape.compiler.sli.internal.callback(event,handle);
    end

end