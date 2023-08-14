classdef SessionSaveLoad<handle







    methods(Static)
        ret=getController(varargin)
        newSDISession(varargin)
        loadSDISession(varargin)
        saveSDISession(varargin)
        mldatxLoadComplete(varargin)
        mldatxSaveComplete(varargin)
        mldatxSaveCancelled(varargin)
        mldatxLoadCancelled(varargin)
        loadSDIView(varargin)
        saveSDIView(varargin)
        importFromCSV(filename)
        saveAsImage(varargin)
        saveSDISessionBeforeClose(varargin)
        sessionInfo=getSDISessionInfo(varargin)
        displayMsgBox(appName,title,msg,buttons,defButton,escOption,cb,varargin)
        fCtrl=getClientFeatureCtrl(featureName)
        setClientFeatureCtrl(featureName,featureVal)
        currentPath=getPWDForCEF()
        setActionInProgress(appName,isInProgress)
        updateGUITitleAfterSessionLoad(appName)
        setDirtyFlag(varargin)
    end


    methods
        cacheSessionInfo(this,varargin)
        cancelSaveLoad(this)
    end


    methods(Hidden)

        function obj=SessionSaveLoad(eng,appName)
            obj.Engine=eng;
            obj.Dirty=eng.dirty;
            obj.AppName=appName;
            obj.Listeners=...
            event.listener(eng,'clearSDIEvent',@obj.cb_ClearSDI);
            obj.MsgBoxResponseCb=Simulink.sdi.Map('char',?handle);
            obj.MsgBoxRespSubID=message.subscribe(...
            Simulink.sdi.internal.controllers.SessionSaveLoad.MsgBoxResponseChannel,...
            @(arg)cb_SDIMsgBoxResponse(obj,arg));
            obj.ClientFeatureCtrl=struct(...
            'SDIViews',1);
            obj.ClientFeatureSubID=message.subscribe(...
            Simulink.sdi.internal.controllers.SessionSaveLoad.ClientFeatureCtrlChannel,@(arg)cb_SendClientFeature(obj,arg));
            obj.UpdateTitleSubID=message.subscribe(...
            Simulink.sdi.internal.controllers.SessionSaveLoad.UpdateTitleChannel,@(arg)cb_updateTitle(obj,arg));
        end


        function delete(this)
            for idx=1:length(this.Listeners)
                delete(this.Listeners(idx));
            end
            if connector.isRunning
                message.unsubscribe(this.MsgBoxRespSubID);
                message.unsubscribe(this.ClientFeatureSubID);
                message.unsubscribe(this.UpdateTitleSubID);
            end
        end

        function cb_updateTitle(this,evt)
            if strcmp(evt.appName,this.AppName)
                this.handleDirtyBitChange(evt);
            end
        end

        newSession(this,varargin)
        saveSessionBeforeClose(this,varargin)
        filename=saveSession(this,varargin)
        loadSession(this,varargin)
        [title,titleDirty]=getTitle(this)
        ret=getSessionInfo(this,appName)
        cb_ClearSDI(this,~,~)
        handleDirtyBitChange(this,evt)
        updateGUITitle(this)
        newSessionConfirmation(this,choice)
        saveBeforeCloseConfirmation(this,choice,gui)
        loadSessionAppendConfirm(this,filename,pathname,fullFileName,appendOrClear,varargin)
        importMATfileDuringLoad(this,fullFileName,isAppending,choice)
        fCtrl=getFeatureCtrl(this,featureName)
        setFeatureCtrl(this,featureName,featureVal)
        setDirty(this,varargin)

    end


    methods(Static,Hidden)

        beginOverlayLogging()
        endOverlayLogging()
        clearOverlayLogging()
        [appName,varargin]=parseAppName(varargin)
        [value,varargin]=parseProperty(property,varargin)
        results=getOverlayLoggingResults()
    end


    properties(Hidden)
        MsgBoxResponseCb;
    end


    properties(SetAccess=protected,GetAccess=public)
        AppName='sdi';
    end


    properties(Access=private)
        Engine;
        DefaultName='';
        FileName='';
        PathName='';
        OriginalFileName='';
        OriginalPathName='';
        OriginalDirtyFlag=false;
        Listeners;
        MsgBoxRespSubID;
        ClientFeatureSubID;
        ClientFeatureCtrl;
        ActionInProgress=false;
        Dirty;
        UpdateTitleSubID;
    end


    properties(Constant)
        MsgBoxResponseChannel='/sdi2/msgBoxResponse';
        ClientFeatureCtrlChannel='/sdi/clientFeatureControl';
        UpdateTitleChannel='/sdi/updateTitle';
    end
end


