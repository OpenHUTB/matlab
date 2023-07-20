function restoreCallback(h)




    t=timer('TimerFcn',@(t,e)restoreThread(t,e,h),'StartDelay',0.1);
    start(t);

    function restoreThread(obj,~,h)

        switch h.Mode
        case 0
            h.restore();
        case 1
        case 2
        case 3
            h.stopProcess();
            h.restore();
        case 4
            h.conti();
        case 5
        end

        stop(obj);
        delete(obj);
