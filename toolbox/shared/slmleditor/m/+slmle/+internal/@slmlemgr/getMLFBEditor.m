function editor=getMLFBEditor(obj,objectId,blkH,studio)




    editor=[];


    if nargin<3||isempty(blkH)
        blkH=slmle.internal.getBlockHandleFromObjectId(objectId);
    end


    if nargin<4
        studio=slmle.internal.getStudioHandleFromBlockHandle(blkH);
    end
    if isempty(studio)
        return;
    end


    if obj.MLFBEditorMap.isKey(objectId)
        list=obj.MLFBEditorMap(objectId);
        for i=1:length(list)
            ed=list{i};
            if ed.blkH==blkH&&ed.studio==studio
                editor=ed;
                return;
            end
        end
    end



