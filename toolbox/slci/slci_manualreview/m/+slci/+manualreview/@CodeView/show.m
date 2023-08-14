


function show(obj,option)

    studio=obj.getStudio();
    ctx=slci.toolstrip.util.getSlciAppContext(studio);
    isTop=ctx.getTopModel();
    if isTop
        buildType='top';
    else
        buildType='ref';
    end

    if strcmpi(option,'c')
        if isempty(obj.cv_c)

            obj.cv_c=simulinkcoder.internal.CodeView_C(obj.fStudio);
        end
        obj.cv_c.open(buildType,true);
        obj.setAnnotationFlag(obj.cv_c,true);
    elseif strcmpi(option,'hdl')
        if isempty(obj.cv_hdl)

            obj.cv_hdl=simulinkcoder.internal.CodeView_HDL(obj.fStudio);
        end
        obj.cv_hdl.open();
        obj.setAnnotationFlag(obj.cv_hdl,true);
    end

end