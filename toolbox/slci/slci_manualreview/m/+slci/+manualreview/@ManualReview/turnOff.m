


function turnOff(obj)

    obj.hide();

    mr_manager=slci.manualreview.Manager.getInstance;
    cv=mr_manager.getCodeView(obj.fStudio);
    cv.toggleAnnotation();