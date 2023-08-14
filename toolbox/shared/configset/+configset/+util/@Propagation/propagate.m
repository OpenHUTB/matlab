function propagate(h)




    try
        h.searchClear();
        h.changeStatusTo('Waiting');
        h.sl_propagate();
    catch e
        msg=configset.util.message(e);
        if h.GUI
            errordlg(msg);
        else
            error(msg);
        end
    end
