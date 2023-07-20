function clearHighlight(obj,objectId)



    if obj.logger
        disp(mfilename);
    end

    m=slmle.internal.slmlemgr.getInstance;
    ed=m.getMLFBEditor(objectId);
    if~isempty(ed)
        ed.clearHighlight();
    end