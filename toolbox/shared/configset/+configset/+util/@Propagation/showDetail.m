function showDetail(h,tag)

    try
        mdl=tag(3:end);
        m=h.Map(mdl);
        m.showDiff();
    catch e %#ok
    end

