function refresh(obj)


    obj.setupModelListeners();

    if~obj.active
        return;
    end

    cp=simulinkcoder.internal.CodePerspective.getInstance;
    cp.refresh(obj.studio);

