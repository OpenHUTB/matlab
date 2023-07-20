function isSelected=isTextSelected(cbinfo)



    isSelected=false;

    mgr=slmle.internal.slmlemgr.getInstance;
    objectId=slmle.internal.getObjectId(cbinfo);
    blkH=slmle.internal.getBlockHandleFromObjectId(objectId);
    editor=mgr.getMLFBEditor(objectId,blkH,cbinfo.studio);

    if~isempty(editor)
        isSelected=editor.hasSelection;
    end

