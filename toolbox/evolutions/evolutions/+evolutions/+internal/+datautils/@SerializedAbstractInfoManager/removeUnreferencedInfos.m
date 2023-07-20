function removeUnreferencedInfos(obj)




    objsToRemove=obj.createEmptyTypeVector;



    obj.removeUnloadedObjectsFromDisk;



    for idx=1:numel(obj.AllInfos)
        curInfo=obj.AllInfos(idx);
        if curInfo.NumRefs==0
            objsToRemove(end+1)=curInfo;%#ok<AGROW> 
        end
    end

    for idx=1:numel(objsToRemove)
        curInfo=objsToRemove(idx);
        obj.remove(curInfo);
        evolutions.internal.classhandler.ClassHandler.DeleteObject(curInfo);
    end
end


