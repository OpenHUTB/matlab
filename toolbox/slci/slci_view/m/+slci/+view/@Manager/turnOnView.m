


function turnOnView(obj,editor)


    obj.init();

    src=slci.view.internal.getSource(editor);


    if~obj.hasData(src.modelH)
        viewdata=slci.view.Data(src.modelH);
        obj.addData(src.modelH,viewdata);
    end

    vw=obj.getView(src.studio);
    studioT=src.studio.getStudioTag;
    if isempty(vw)

        vw=slci.view.Studio(src.studio);
        obj.fViews(studioT)=vw;
    end
