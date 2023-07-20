function bool=documentSetTitle(obj,id,title)





    if obj.logger
        disp(mfilename);
    end

    m=slmle.internal.slmlemgr.getInstance;
    eds=m.getMLFBEditorsFromAllStudios(id);
    for i=1:length(eds)
        ed=eds{i};
        ed.updateID();
    end

    bool=true;


