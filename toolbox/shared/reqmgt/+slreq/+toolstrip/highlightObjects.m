

function highlightObjects(cbinfo)

    modelH=slreq.toolstrip.getModelHandle(cbinfo);


    SLStudio.Utils.RemoveHighlighting(modelH);

    if cbinfo.EventData

        set_param(modelH,'ReqHilite','on');
    else
        set_param(modelH,'ReqHilite','off');
    end

end
