function init(this)








    if isa(this.linkTargetReqObject,'double')
        this.linkTargetReqObject=slreq.das.Requirement.empty;
    end
    if isa(this.currentObject,'double')
        this.currentObject=slreq.das.ReqLinkBase.empty;
    end

    if isempty(this.reqObjsListeningFiles)
        this.reqObjsListeningFiles=containers.Map('KeyType','char','ValueType','Any');
    end



    if isempty(this.viewSettingsManager)
        this.viewSettingsManager=slreq.app.ViewSettingsManager();
    end
    if isempty(this.viewManager)
        this.viewManager=this.viewSettingsManager.viewManager;

        this.viewManager.getCurrentSettings.activate();
    end

    if isempty(this.badgeManager)
        this.badgeManager=slreq.app.BadgeManager();
    end
    if isempty(this.markupManager)
        this.markupManager=slreq.app.MarkupManager(this);
    end
    if isempty(this.projectManager)
        this.projectManager=slreq.app.ProjectManager();
    end
    if isempty(this.linkResultProvider)
        this.linkResultProvider=slreq.verification.LinkResultProviderRegistry.getInstance;
    end
    if isempty(this.callbackHandler)
        this.callbackHandler=slreq.app.CallbackHandler(this);
    end
    if isempty(this.codeTraceabilityManager)
        this.codeTraceabilityManager=slreq.app.CodeTraceabilityManager(this);
    end
    if isempty(this.spreadsheetManager)
        this.spreadsheetManager=slreq.app.SpreadSheetManager(this);
    end

    if isempty(this.spreadSheetDataManager)
        this.spreadSheetDataManager=slreq.app.SpreadSheetDataManager(this);
    end

    if isempty(this.changeTracker)
        this.changeTracker=slreq.app.ChangeTracker();
    end

    if isempty(this.externalEditorManager)
        this.externalEditorManager=slreq.app.ExternalEditorManager();
    end

    if isempty(this.rollupStatusManager)
        this.rollupStatusManager=slreq.app.RollupStatusManager();
    end


    rmi('init');

end
