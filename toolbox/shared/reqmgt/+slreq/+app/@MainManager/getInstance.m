function singleton=getInstance(doInit)








    mlock;
    persistent reqUiManager;
    if isempty(reqUiManager)||~isvalid(reqUiManager)
        if nargin==0||doInit
            reqUiManager=slreq.app.MainManager;
        end
    end
    singleton=reqUiManager;
end
