function showError(h,tag)

    try
        mdl=tag(3:end);
        m=h.Map(mdl);
        m.showError();
    catch e %#ok
    end
