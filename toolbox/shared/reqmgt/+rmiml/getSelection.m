function[srcKey,selectedRange,selectedText]=getSelection()




    if rmiml.enable()
        [srcKey,selectedRange,selectedText]=mleditor.getSelection();
        if isempty(srcKey)




            document=matlab.desktop.editor.getActive();
            if~isempty(document)
                srcKey=recoverEditorIdIfJavaMLFB(document);
            end
        end
    else
        [srcKey,selectedRange,selectedText]=getSelectionInJavaEditor(nargout);
    end
end

function srcKey=recoverEditorIdIfJavaMLFB(document)



    if feature('openMLFBInSimulink')
        error('matlab.desktop.editor.getActive() returned no ID for MLFB Editor');
    end
    if~isprop(document.Editor,'JavaEditor')
        error('matlab.desktop.editor.getActive() returned no ID for non-Java Editor');
    end
    srcKey=document.Editor.JavaEditor.getUniqueKey();
    if isempty(srcKey)
        error('document.Editor.JavaEditor.getUniqueKey() returned no ID');
    end
    if ispc
        pattern='\\([^\\]+)\.slx(\S+\:\d[\:\d]*)$';
    else
        pattern='/([^/]+)\.slx(\S+\:\d[\:\d]*)$';
    end
    matchSID=regexp(char(srcKey),pattern,'tokens');
    if isempty(matchSID)
        error('failed to match MLFB SID in %s',char(srcKey));
    elseif~contains(matchSID{1}{2},matchSID{1}{1})
        error('failed to match MLFB SID in %s',char(srcKey));
    end
    srcKey=matchSID{1}{2};
end

function[srcKey,selectedRange,selectedText]=getSelectionInJavaEditor(argCount)

    srcKey='';
    selectedRange=[];
    selectedText='';

    editor=com.mathworks.mlservices.MLEditorServices.getEditorApplication.getActiveEditor();
    if isempty(editor)
        return;
    end

    srcKey=rmiml.getRmiSourceKey(editor);
    if argCount==1
        return;
    end

    selectedText=char(editor.getSelection());

    currentCharIndex=editor.getCaretPosition()+1;

    if isempty(selectedText)

        selectedRange=[currentCharIndex,currentCharIndex];
    else

        fullText=char(editor.getText());
        if isForwardSelection(fullText,selectedText,currentCharIndex)
            startOfSelection=currentCharIndex-length(selectedText);
            selectedRange=[startOfSelection,currentCharIndex];
        else
            endOfSelection=currentCharIndex+length(selectedText);
            selectedRange=[currentCharIndex,endOfSelection];
        end
    end
end

function yesno=isForwardSelection(fullText,selectedText,currentCharIndex)
    matchBefore=strfind(fullText(1:currentCharIndex-1),selectedText);
    matchAfter=strfind(fullText(currentCharIndex:end),selectedText);
    if~isempty(matchBefore)&&matchBefore(end)==currentCharIndex-length(selectedText)
        yesno=true;
    elseif~isempty(matchAfter)&&matchAfter(1)==1
        yesno=false;
    else
        error('Failed to match selectedText of "%s" at position %d',selectedText,currentCharIndex);
    end
end



