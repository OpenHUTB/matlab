function[srcKey,selectedRange,selectedText]=getSelection()




    srcKey='';
    selectedRange=[];
    selectedText='';

    editor=matlab.desktop.editor.getActive();
    if isempty(editor)
        return;
    end
    srcKey=editor.Filename;
    jsRangeData=editor.Selection;
    selectedRange=convertLinePosToAbsRange(editor,jsRangeData);
    selectedText=editor.SelectedText;
end

function absRange=convertLinePosToAbsRange(editor,rangeData)


    firstCharPos=matlab.desktop.editor.positionInLineToIndex(editor,rangeData(1),rangeData(2));
    lastCharPos=matlab.desktop.editor.positionInLineToIndex(editor,rangeData(3),rangeData(4));
    absRange=[firstCharPos,lastCharPos];
end
