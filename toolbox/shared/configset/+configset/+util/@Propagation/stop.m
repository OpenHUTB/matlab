function stop(h)

    if h.Mode==1||h.Mode==2;
        h.Mode=5;
        return;
    end

    if h.Mode==3||h.Mode==4;
        h.Mode=0;
        h.stopProcess();
        return;
    end
