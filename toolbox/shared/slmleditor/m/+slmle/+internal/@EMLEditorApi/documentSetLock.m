function bool=documentSetLock(obj,id,lock)


    if obj.logger
        disp(mfilename);
    end

    bool=true;

    m=slmle.internal.slmlemgr.getInstance;
    m.cleanupMLFBEditorMap;

    objectId=slmle.internal.convertToObjectId(id);
    map=m.MLFBEditorMap;
    if map.isKey(objectId)
        list=map(objectId);

        for i=1:length(list)
            ed=list{i};
            if(ed.objectId~=objectId)
                continue;
            end
            isInstanceOfLibrary=isLibraryInstance(ed);
            ed.lock(isInstanceOfLibrary||lock);
            ed.context.applyLockedStateContext(lock);
        end
    end
end

function isInstanceOfLibrary=isLibraryInstance(editor)
    subSystem=get_param(editor.blkH,'object');
    isInstanceOfLibrary=subSystem.isLinked;
end
