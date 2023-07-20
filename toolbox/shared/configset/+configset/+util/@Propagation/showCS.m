function showCS(h)

    try
        h.CS.view;
    catch e
        errordlg(e.message);
    end
