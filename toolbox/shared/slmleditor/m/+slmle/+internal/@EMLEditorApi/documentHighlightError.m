function bool=documentHighlightError(obj,objectId,posStart,posEnd)


    if sf('get',objectId,'.isa')==14

        filePath=sf('get',objectId,'script.filePath');
        ed=matlab.desktop.editor.openDocument(filePath);
        [sLin,sCol]=matlab.desktop.editor.indexToPositionInLine(ed,posStart+1);
        [eLin,eCol]=matlab.desktop.editor.indexToPositionInLine(ed,posEnd);
        ed.Selection=[sLin,sCol,eLin,eCol+1];
        return
    end

    m=slmle.internal.slmlemgr.getInstance;
    eds=m.getMLFBEditorsFromAllStudios(objectId);
    n=length(eds);
    if n==0
        bool=false;
    else
        for i=1:n
            ed=eds{i};
            ed.selectText(posStart,posEnd);
        end
        bool=true;
    end



