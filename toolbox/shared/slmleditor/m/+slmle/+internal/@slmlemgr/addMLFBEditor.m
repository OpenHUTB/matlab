function editor=addMLFBEditor(obj,objectId,blkH,studio)






    editor=[];


    if nargin<4
        studio=slmle.internal.getStudioHandleFromObjectId(objectId);
    end
    if isempty(studio)
        return;
    end


    if nargin<3
        blkH=slmle.internal.getBlockHandleFromObjectId(objectId);
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
        editor=slmle.internal.MLFBEditor(objectId,blkH,studio);
        list{end+1}=editor;
    else
        editor=slmle.internal.MLFBEditor(objectId,blkH,studio);
        list={editor};
    end
    obj.MLFBEditorMap(objectId)=list;


