function showModel(h,tag)


    try
        mdl=tag(3:end);
        open_system(mdl);
    catch e
        msg=configset.util.message(e);
        if h.GUI
            errordlg(msg);
        else
            disp(msg);
        end
    end
