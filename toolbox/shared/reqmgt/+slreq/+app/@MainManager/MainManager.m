classdef MainManager<handle





    properties
        perspectiveManager;
badgeManager
        markupManager;
        projectManager;
        changeTracker;
        requirementsEditor;
        callbackHandler;
        spreadsheetManager;
        spreadSheetDataManager;
        viewManager;
        codeTraceabilityManager;
        linkChangeHandler;
        linkResultProvider;
        dasEventListner;

        linkTargetReqObject=[];


        externalEditorManager;


        rollupStatusManager;


        isAnalysisDeferred=reqmgt('rmiFeature','DeferDataRefresh');
    end

    properties(Dependent)
        reqRoot;
        linkRoot;
    end
    methods
        function r=get.reqRoot(this)
            r=this.getReqRoot();
        end
        function r=get.linkRoot(this)
            r=this.getLinkRoot();
        end
    end

    properties(Access=private)




        lastOperatedView;






        currentObject=[];

        reqObjsListeningFiles=containers.Map('KeyType','char','ValueType','Any');
        viewSettingsManager;







        userActionInProgress=0;



        userActionFinishCallBacks=containers.Map('KeyType','char','ValueType','Any');

        DEFER_DATA_REFRESH_NOTIFICATION_ID='Slreq:Studio:DeferDataRefresh';
    end

    properties(Constant)


        DefaultRequirementColumns={'Index','ID','Summary'};


        DefaultLinkColumns={'Label','Source','Type','Destination'};

        DefaultDisplayChangeInformation=false;
    end

    properties(Hidden)
        UseExternalEditor=true;
    end

    methods(Access=private)

        function this=MainManager()
        end
    end

    events

        SleepUI;
        WakeUI;
    end

    methods
        initPerspective(this)

        tf=isPerspectiveEnabled(this,modelH)

        togglePerspective(this,cStudio,~)

        init(this)

        delete(this)

        openRequirementsEditor(this)

        spObj=getSpreadSheetObject(this,target)

        spObj=getCurrentSpreadSheetObject(this,target)

        reset(this)

        disengageAndReset(this)

        update(this,localDataRefreshed,dasObj)
        refreshUI(this,varargin)
        refreshUIOnArtifactLoad(this,artifact)

        perspectiveChangeHandler(this,~,eventData)

        onReqSpreadSheetToggled(this,~,eventData)

        enableCodeTraceability(this)

        disableCodeTraceability(this)

        r=getReqRoot(this)

        r=getLinkRoot(this)

        obj=getCurrentView(this,varargin)

        showImplementationStatus(this,cView)

        hideImplementationStatus(this,cView)

        showVerificationStatus(this,cView)

        hideVerificationStatus(this,cView)

        showChangeInformation(this,cView)

        hideChangeInformation(this,cView)

        setChangeInformationEnabled(this,toEnable,cViews)

        dasObj=getDasObjFromDataObj(this,dataObj)

        setSelectedObject(this,obj)

        setLastOperatedView(this,view)

        updateRequirementForHarness(ownerHandle,HarnessHandle,disableBadge)

        clearSelectedObjectsUponDeletion(this,clearObj,forceClear);

        out=getLastOperatedView(this);

        clearLastOperatedView(this,spObj);

        out=hasSpreadSheetData(this);

        out=doesAnyUIExist(this);

        vsmgr=getViewSettingsManager(this)

        allViewers=getAllViewers(this);
        tf=isChangeInformationEnabled(this,viewers);
        showDeferredAnalysisNotification(this,target);
        hideDeferredAnalysisNotifications(this,viewers);
        tf=isImplementationStatusEnabled(this,viewers);
        tf=isVerificationStatusEnabled(this,viewers);

        updateRollupStatusLocally(this,dataObj);
        updated=updateRollupStatusAndChangeInformationIfNeeded(this,viewers);

        putToSleep(this);
        wakeUp(this);
        tf=isUserActionInProgress(this);
        setUserActionInProgress(this,boolValue);
        setUserActionFinishCallback(this,locationName,callback);
    end

    methods(Static=true)

        singleton=getInstance(init)

        result=exists()

        tf=initialized()


        obj=getCurrentObject()


        objs=getCurrentViewSelections()

        modelCloseCallback(modelH)

        tf=hasEditor()

        unblock=blockEditors()

        tf=isEditorVisible()

        tf=hasDAS()

        stopAction=startUserAction()
    end

end
