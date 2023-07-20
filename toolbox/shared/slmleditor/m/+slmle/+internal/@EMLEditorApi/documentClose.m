function documentClose(obj,id)




    if obj.logger
        disp(mfilename);
    end

    m=slmle.internal.slmlemgr.getInstance();
    eds=m.getMLFBEditorsFromAllStudios(id);
    for i=1:length(eds)
        eds{i}.close;
    end
