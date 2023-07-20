function close(obj,editor)




    if nargin<2
        src=simulinkcoder.internal.util.getSource;
        editor=src.editor;
    end


    vals=obj.MLFBEditorMap.values;
    for i=1:length(vals)
        mlfbEditors=vals{i};
        for j=1:length(mlfbEditors)
            mlfb=mlfbEditors{j};
            if mlfb.ed==editor
                mlfb.close;
            end
        end
    end

    obj.cleanupMLFBEditorMap;

