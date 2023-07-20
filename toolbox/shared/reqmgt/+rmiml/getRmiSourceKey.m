function key=getRmiSourceKey(editor)




    if nargin==0
        editor=com.mathworks.mlservices.MLEditorServices.getEditorApplication.getActiveEditor();
    end

    editorKey=char(editor.getUniqueKey());

    slxPos=strfind(editorKey,'.slx');
    mdlPos=strfind(editorKey,'.mdl');
    allPos=sort([slxPos,mdlPos]);
    if isempty(allPos)

        key=editorKey;
    else
        possibleSid=editorKey(allPos(end)+4:end);
        if rmisl.isSidString(possibleSid)
            key=possibleSid;
        else
            key=editorKey;
        end
    end

end