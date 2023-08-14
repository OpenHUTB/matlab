function tf=initialized()


    if slreq.app.MainManager.exists()
        tf=~isempty(slreq.app.MainManager.getInstance.rollupStatusManager);
    else
        tf=false;
    end
end