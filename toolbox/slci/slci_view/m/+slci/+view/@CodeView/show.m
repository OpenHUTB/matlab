


function show(obj)

    studio=obj.getStudio();
    ctx=studio.App.getAppContextManager.getCustomContext('slciApp');
    isTop=ctx.getTopModel();
    if isTop
        buildType='top';
    else
        buildType='ref';
    end

    if isempty(obj.cv)
        obj.cv=simulinkcoder.internal.CodeView_C(studio);
    end

    obj.cv.open(buildType,true);