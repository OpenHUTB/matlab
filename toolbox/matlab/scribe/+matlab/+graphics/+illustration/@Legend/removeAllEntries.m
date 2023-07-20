function removeAllEntries(hObj)

    delete(hObj.EntryContainer.Children);
    hObj.MarkDirty('all');