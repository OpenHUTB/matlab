


function turnOffView(obj,editor)

    src=slci.view.internal.getSource(editor);

    vw=obj.getView(src.studio);

    if~isempty(vw)
        vw.turnOff();
    end