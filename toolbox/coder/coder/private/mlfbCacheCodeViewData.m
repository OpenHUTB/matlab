

function mlfbCacheCodeViewData(blockSid,data)
    manager=coder.internal.mlfb.gui.CodeViewManager.get(blockSid);
    assert(~isempty(manager),'CodeViewManager not available');

    manager.setCodeViewData(blockSid,data);
end