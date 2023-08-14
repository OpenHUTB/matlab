function stopProcess(h)

    try
        h.changeStatus('Waiting','Skipped');
        if h.IsPropagated&&h.Mode==3
            h.Time=datestr(clock);
        end
        h.Mode=0;
        h.Index=1;
        h.setDlg();
        h.save();
    catch e
        errordlg(e.message);
    end
