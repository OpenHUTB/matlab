function reset(this)






    this.userActionFinishCallBacks.remove(keys(this.userActionFinishCallBacks));

    this.isAnalysisDeferred=reqmgt('rmiFeature','DeferDataRefresh');
    this.hideDeferredAnalysisNotifications();


    if~isempty(this.requirementsEditor)
        delete(this.requirementsEditor);
        this.requirementsEditor=[];
    end

    if~isempty(this.rollupStatusManager)
        this.rollupStatusManager.delete();
        this.rollupStatusManager=[];
    end




    if~isempty(this.externalEditorManager)
        this.externalEditorManager.delete();
        this.externalEditorManager=[];
    end

    if slreq.data.ReqData.exists()
        rdata=slreq.data.ReqData.getInstance();
        rdata.reset();
    else



    end

    if~isempty(this.reqObjsListeningFiles)
        this.reqObjsListeningFiles=containers.Map('KeyType','char','ValueType','Any');
    end

    if~isempty(this.callbackHandler)
        delete(this.callbackHandler);
        this.callbackHandler=[];
    end
    if~isempty(this.linkChangeHandler)
        delete(this.linkChangeHandler);
        this.linkChangeHandler=[];
    end
    if~isempty(this.linkResultProvider)

        slreq.verification.LinkResultProviderRegistry.reset();
    end
    if~isempty(this.dasEventListner)
        delete(this.dasEventListner);
        this.dasEventListner=[];
    end

    if~isempty(this.badgeManager)
        delete(this.badgeManager);
        this.badgeManager=[];
    end

    if~isempty(this.spreadsheetManager)
        delete(this.spreadsheetManager);
        this.spreadsheetManager=[];
    end

    if~isempty(this.spreadSheetDataManager)
        delete(this.spreadSheetDataManager);
        this.spreadSheetDataManager=[];
    end

    if~isempty(this.perspectiveManager)
        delete(this.perspectiveManager);
        this.perspectiveManager=[];
    end
    if~isempty(this.projectManager)
        this.projectManager.delete;
        this.projectManager=[];
    end
    if~isempty(this.markupManager)
        this.markupManager.delete;
        this.markupManager=[];
    end
    if~isempty(this.codeTraceabilityManager)
        this.codeTraceabilityManager.delete;
        this.codeTraceabilityManager=[];
    end

    if~isempty(this.changeTracker)
        this.changeTracker.delete;
        this.changeTracker=[];
    end

    if~isempty(this.viewSettingsManager)
        if~isempty(this.viewManager)
            this.viewManager.deActivate();
        end
        this.viewSettingsManager.delete;
        this.viewSettingsManager=[];
        this.viewManager=[];
    end

    this.UseExternalEditor=true;
    this.lastOperatedView=[];
    this.linkTargetReqObject=[];
    this.currentObject=[];


    slreq.utils.customAttributeNamesHash('reset');
end


