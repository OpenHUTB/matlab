


function toggleAnnotation(obj)
    mr_manager=slci.manualreview.Manager.getInstance;

    flag=false;
    if mr_manager.hasManualReview(obj.getStudio)
        mr=mr_manager.getManualReview(obj.getStudio);
        flag=mr.getStatus;
    end

    if~isempty(obj.cv_c)
        obj.setAnnotationFlag(obj.cv_c,flag);
    end
    if~isempty(obj.cv_hdl)
        obj.setAnnotationFlag(obj.cv_hdl,flag);
    end
end
