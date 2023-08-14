


function turnOffView(obj,editor)

    src=slci.view.internal.getSource(editor);
    studio=src.studio;

    if obj.hasManualReview(studio)
        mr=obj.getManualReview(studio);
        mr.turnOff();
    end

    if obj.hasCodeView(studio)
        cv=obj.getCodeView(studio);
        cv.turnOff();
    end