function[matlabSession,r]=getSessionAccessor(varargin)


    p=inputParser;
    addParameter(p,'sessionName','default');
    addParameter(p,'sessionHomeDir',...
    fullfile(prefdir,'connector_session'));
    addParameter(p,'userDir',connector.internal.userdir);
    addParameter(p,'addonsDir',connector.internal.addonsdir);
    addParameter(p,'includeWorkspaceAndFigures',true);
    addParameter(p,'includePath',...
    isunix&&matlab.internal.environment.context.isMATLABOnline);
    addParameter(p,'resetWorkspaceAndFiguresBeforeLoad',true);
    addParameter(p,'useAsyncSave',...
    isunix&&matlab.internal.environment.context.isMATLABOnline);

    parse(p,varargin{:});
    r=p.Results;


    sessionDir=fullfile(r.sessionHomeDir,'.session',r.sessionName);
    matlabSession=mls.internal.MatlabSession(...
    sessionDir,...
    r.userDir,...
    r.addonsDir...
    );
    matlabSession.resetWorkspaceAndFiguresBeforeLoad=...
    r.resetWorkspaceAndFiguresBeforeLoad;
    matlabSession.useAsyncSave=r.useAsyncSave;


    if r.includeWorkspaceAndFigures
        matlabSession.workspaceAndFigures.enable();
    else
        matlabSession.workspaceAndFigures.disable();
    end

    if r.includePath
        matlabSession.path.enable();
    else
        matlabSession.path.disable();
    end
end