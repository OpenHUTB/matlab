function handleStartAcqClickedCallback(this,~,~)






    drawnow;
    if~this.diskLoggingValidState


        return;
    end

    if this.areFramesAvailableForExport()
        od=iatbrowser.OptionDialog;
        od.showOptionDialog(...
        iatbrowser.getDesktopFrame(),...
        'START_ACQ_FRAMES_WILL_BE_LOST',...
        [],...
        @checkForLogFilePresentIfDiskLogging,...
        []);
    else
        checkForLogFilePresentIfDiskLogging();
    end

    function checkForLogFilePresentIfDiskLogging(varargin)
        if strcmpi(iatbrowser.Browser().currentVideoinputObject.LoggingMode,'memory')
            proceed();
            return;
        end
        diskLogger=iatbrowser.Browser().currentVideoinputObject.DiskLogger;
        if exist(fullfile(diskLogger.Path,diskLogger.Filename),'file')
            dialog=iatbrowser.LogFilePresentDialog;
            choice=dialog.doDialog();

            switch(choice)
            case dialog.Cancel
                doNotOverwriteLogFile();
            case dialog.Overwrite
                proceed();
            end
        else
            proceed();
        end
    end

    function doNotOverwriteLogFile(varargin)
        browser=iatbrowser.Browser;
        acqParam=browser.acqParamPanel;
        jAcqParam=java(acqParam.javaPeer);
        formatNodePanel=jAcqParam.getFormatNodePanel();

        formatNodePanel.selectLoggingTab();
        formatNodePanel.setInvalidFilenameSpecified(true);
        formatNodePanel.setFocusInFileNameField();

        status=iatbrowser.DiskParametersUpdatedEventData(false);
        iatbrowser.Browser().messageBus.generateEvent('DiskParametersUpdated',status);

        drawnow;
    end

    function proceed(varargin)
        desk=iatbrowser.getDesktop();
        desk.enableGlassPane(true);

        drawnow;
        try
            set(iatbrowser.Browser().currentVideoinputObject,'FramesAcquiredFcn',[]);
            set(iatbrowser.Browser().currentVideoinputObject,'StopFcn',@stopFunction);
            set(iatbrowser.Browser().currentVideoinputObject,'ErrorFcn',@errorDuringAcquisition);

            this.stopping=false;
            this.prevPanel.clearFrames();
            send(this,'StartAcquisition',[]);
            try
                this.startPreview(true);
            catch err
                this.prevPanel.fixWindowAfterFailureToPreviewOrStart();
                rethrow(err);
            end
            jPrevPanelButtonPanel=java(this.prevPanel.prevPanelButtonPanel);
            if strcmp(getfield(triggerconfig(iatbrowser.Browser().currentVideoinputObject),'TriggerType'),'manual')%#ok<GFLD>
                jPrevPanelButtonPanel.setButtonsForAcquire(true);
            else
                jPrevPanelButtonPanel.setButtonsForAcquire(false);
            end

            manTrigger=imaqgate('privateGetJavaResourceString',...
            'com.mathworks.toolbox.imaq.browser.resources.RES_TABPANE',...
            'TriggeringPanel.fManLabel');
            triggerType=iatbrowser.Browser().currentVideoinputObject.TriggerType;
            if strcmpi(triggerType,manTrigger)
                if get(iatbrowser.Browser().currentVideoinputObject,'FramesPerTrigger')~=Inf
                    set(iatbrowser.Browser().currentVideoinputObject,'FramesAcquiredFcn',@nonInfTriggerDoneFunction);
                end
            end

            desk.setGlassPaneForAcquisition();


            this.errorFcnHandled=false;
            this.errorFcnInProgress=false;

            warnState=warning('off','imaq:start:diskLoggingToMemory');
            oc=onCleanup(@()warning(warnState));
            start(iatbrowser.Browser().currentVideoinputObject);

            ed=iatbrowser.SessionLogEventData(iatbrowser.Browser().currentVideoinputObject,...
            'start(vid);\n\n');
            iatbrowser.Browser().messageBus.generateEvent('SessionLogEvent',ed);

        catch err
            md=iatbrowser.MessageDialog();
            md.showMessageDialogWithAdditionalMessage(...
            iatbrowser.getDesktopFrame(),...
            'START_ACQUISITION_FAILED',...
            err.getReport('basic','hyperlinks','off'),...
            [],...
            @stopFunction);
        end
    end

    function errorDuringAcquisition(obj,event)%#ok<INUSL>


        this.errorFcnHandled=true;
        this.errorFcnInProgress=true;
        md=iatbrowser.MessageDialog();
        if strcmp(event.Data.MessageID,'imaq:imaqmex:outofmemory')
            md.showMessageDialog(...
            iatbrowser.getDesktopFrame(),...
            'ACQUISITION_FAILED_IMAQMEM',...
            [],...
            @doneWithErrorDialog);
        else
            errMsgStrings=regexp(event.Data.Message,'<a[^>]+[>]','split');
            if length(errMsgStrings)==2
                errMsg=[errMsgStrings{1},strrep(errMsgStrings{2},'</a>','')];
            else
                errMsg=errMsgStrings{1};
            end
            md.showMessageDialogWithAdditionalMessage(...
            iatbrowser.getDesktopFrame(),...
            'ACQUISITION_FAILED',...
            errMsg,...
            [],...
            @doneWithErrorDialog);
        end
    end

    function doneWithErrorDialog(obj,event)%#ok<INUSD>
        this.errorFcnInProgress=false;
        desk=iatbrowser.getDesktop();
        desk.enableGlassPane(false);
    end

    function nonInfTriggerDoneFunction(obj,event)%#ok<INUSD,INUSD>
        if isrunning(iatbrowser.Browser().currentVideoinputObject)&&...
            (iatbrowser.Browser().currentVideoinputObject.TriggersExecuted<=iatbrowser.Browser().currentVideoinputObject.TriggerRepeat)
            javaMethodEDT('setButtonsForBetweenTrig',java(this.prevPanel.prevPanelButtonPanel));
        end
    end

    function stopFunction(obj,event)%#ok<INUSD,INUSD>
        desk=iatbrowser.getDesktop();
        desk.enableGlassPane(true);

        browser=iatbrowser.Browser();
        vidObj=browser.currentVideoinputObject;

        if strcmp(vidObj.LoggingMode,'memory')
            glassPaneSentinel=iatbrowser.GlassPaneSentinel;%#ok<NASGU>
        end


        this.stopPreview(false);

        if~this.stopping
            stopStatus=iatbrowser.getResourceString('RES_DESKTOP','PreviewPanel.AcqComplete');
        else
            stopStatus=iatbrowser.getResourceString('RES_DESKTOP','PreviewPanel.AcqCancel');
        end

        set(this.prevPanel.statLabel,'String',stopStatus);
        drawnow;




        this.errorFcnDoneTimer=timer('ObjectVisibility','off',...
        'Period',.1,'TimerFcn',@canWeFinishStopping,'UserData',vidObj,...
        'TasksToExecute',inf,'ExecutionMode','fixedSpacing');
        start(this.errorFcnDoneTimer);
    end

    function canWeFinishStopping(varargin)
        if~this.errorFcnInProgress

            stop(this.errorFcnDoneTimer);

            userData.vidObj=this.errorFcnDoneTimer.UserData;
            userData.loopIterations=0;
            userData.stuck=false;
            userData.origFrameCount=userData.vidObj.DiskLoggerFrameCount;
            userData.origMessage=get(this.prevPanel.statLabel,'String');

            this.stopFcnDoneTimer=timer('ObjectVisibility','off',...
            'Period',.1,'TimerFcn',@stopFunctionContinued,'UserData',userData,...
            'TasksToExecute',inf,'ExecutionMode','fixedSpacing');
            start(this.stopFcnDoneTimer);

            stop(this.errorFcnDoneTimer);
            delete(this.errorFcnDoneTimer);
        else



            desk=iatbrowser.getDesktop();
            desk.enableGlassPane(false);
        end
    end

    function stopFunctionContinued(timerObj,~)
        userData=timerObj.UserData;
        obj=userData.vidObj;
        doneLogging=true;

        if~strcmp(obj.LoggingMode,'memory')

            diskLogStringOrig=iatbrowser.getResourceString('RES_DESKTOP','PreviewPanel.WaitForDiskLogging');





            if((obj.FramesAcquired~=obj.DiskLoggerFrameCount)&&...
                ~userData.stuck)

                if obj.DiskLoggerFrameCount==userData.origFrameCount
                    userData.loopIterations=userData.loopIterations+1;
                else
                    userData.origFrameCount=obj.DiskLoggerFrameCount;
                    userData.loopIterations=0;
                end

                if userData.loopIterations>10
                    userData.stuck=true;
                end

                args=javaArray('java.lang.Integer',2);
                args(1)=java.lang.Integer(obj.DiskLoggerFrameCount);
                args(2)=java.lang.Integer(obj.FramesAcquired);

                diskLogString=char(java.text.MessageFormat.format(diskLogStringOrig,args));
                set(this.prevPanel.statLabel,'String',diskLogString);
                javaMethodEDT('disableButtons',java(this.prevPanel.prevPanelButtonPanel));

                timerObj.UserData=userData;
            end


            if(userData.stuck&&~this.errorFcnHandled)
                md=iatbrowser.MessageDialog();
                md.showMessageDialog(...
                iatbrowser.getDesktopFrame(),...
                'DISK_LOGGING_FAILED',...
                [],...
                []);
            end

            doneLogging=(obj.DiskLoggerFrameCount==obj.FramesAcquired)||...
            userData.stuck;

            if doneLogging
                set(this.prevPanel.statLabel,'String',userData.origMessage);
                iatbrowser.Browser().messageBus.generateEvent('DiskLoggingFinished');
            end
        end

        if doneLogging
            if obj.FramesAvailable>0
                framesAvailableForExport=this.prevPanel.showMontage(iatbrowser.Browser().currentVideoinputObject);
            else
                framesAvailableForExport=false;
            end

            javaMethodEDT('setButtonsForStopped',...
            java(this.prevPanel.prevPanelButtonPanel),...
            framesAvailableForExport,...
            size(this.prevPanel.data,3));

            stop(timerObj);
            delete(timerObj);
        end
        drawnow;
    end
end
