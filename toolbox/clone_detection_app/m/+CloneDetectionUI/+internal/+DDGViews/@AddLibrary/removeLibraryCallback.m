function removeLibraryCallback(this)






    rowIdx=this.fDialogHandle.getSelectedTableRow('AddLibrariesTable')+1;
    this.cloneUIObj.libraryList(rowIdx)=[];
    this.cloneUIObj.toolstripCtx.enableReplaceWithSSRef=isempty(this.cloneUIObj.libraryList);
    this.fDialogHandle.refresh;
end

