function stopAction=startUserAction()
    if slreq.app.MainManager.exists()
        this=slreq.app.MainManager.getInstance();
        this.setUserActionInProgress(true);
        stopAction=onCleanup(@()this.setUserActionInProgress(false));
    else
        stopAction=[];
    end
end
