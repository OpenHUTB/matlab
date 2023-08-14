function status=uiNotificationMgr(varargin)

    if nargin>0&&~islogical(varargin{1})
        error(message('Slvnv:rmipref:InvalidInput',class(varargin{1}),'ARG1'));
    end

    status=false;

    if slreq.app.MainManager.hasDAS()
        reqRoot=slreq.app.MainManager.getInstance.reqRoot;
        if~isempty(reqRoot)
            status=reqRoot.reqDataChangeListener.Enabled;
            if nargin>0
                reqRoot.reqDataChangeListener.Enabled=varargin{1};
            end
        end
    end
end

