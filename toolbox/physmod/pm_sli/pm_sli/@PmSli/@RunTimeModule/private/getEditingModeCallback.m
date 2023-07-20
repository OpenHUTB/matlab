function editingModeCallback=getEditingModeCallback(hBlock,code)









    libEntry=pmsl_getblocklibraryentry(hBlock);
    editingModeCallback='';
    if isempty(libEntry)
        return;
    end

    if isempty(libEntry.Product)
        return;
    end

    fcn=libEntry.EditingModeFcn;
    pm_assert(~isempty(fcn),['Empty editing mode function for library entry: ',libEntry.Product]);
    fcnHandle=str2func(fcn);
    editingModeCallback=fcnHandle(hBlock,code);

end


