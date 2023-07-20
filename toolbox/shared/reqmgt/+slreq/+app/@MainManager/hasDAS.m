function tf=hasDAS()









    if slreq.app.MainManager.exists()
        tf=~isempty(slreq.app.MainManager.getInstance.reqRoot);
    else
        tf=false;
    end
end
