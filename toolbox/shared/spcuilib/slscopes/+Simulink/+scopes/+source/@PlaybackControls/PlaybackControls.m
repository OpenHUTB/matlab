classdef PlaybackControls<matlabshared.scopes.source.PlaybackControls





    properties(SetAccess=protected)


StatusBar
FrameStatus
Toolbar
    end

    properties(Access=protected)
IsCompactToolbar
PlaybackMenuListener
        IsFirstPlaybackMenuOpening=true;
        IsFirstMenuRendering=true;
        SplitAction;
        WindowMotionListener;
    end

    properties(Access=private)
        OneShotTimer=[];
    end

    methods
        function this=PlaybackControls(hScope,hSource)

            this@matlabshared.scopes.source.PlaybackControls(hScope,hSource);

            hUI=this.UIMgr;
            if isempty(hUI)
                this.StatusBar=hScope.Handles.statusBar;
                this.FrameStatus=hScope.Handles.frameStatus;
            else
                this.StatusBar=this.UIMgr.findchild('StatusBar');
                this.FrameStatus=this.StatusBar.findchild('StdOpts','Frame');

                createGUI(this);
            end
            if hScope.Specification.RenderSimulationControls




                this.WindowMotionListener=addlistener(hScope.Parent,'WindowMouseMotion',@this.windowMotionCallback);
            end
        end

        function configureControls(this)




            hSrc=this.Source;
            isSourceValid=isa(hSrc,'MCOS')&&isvalid(hSrc)||ishandle(hSrc);
            play=this.Buttons.play;



            if isa(play,'uimgr.uiitem')
                vis=true;
            else
                vis=strcmp(get(get(play,'Parent'),'Visible'),'on');
            end
            modelObject=hSrc.getParentModel;
            if vis&&isSourceValid&&~isempty(modelObject)
                modelH=modelObject.Handle;
                simMode=get_param(modelH,'SimulationMode');
                simState=get_param(modelH,'SimulationStatus');
                pacingEnabled=strcmp(get_param(modelH,'EnablePacing'),'on');

                if strcmpi(simState,'terminating')
                    return
                end
                switch lower(simMode)
                case{'normal','accelerator'}
                    steppingEnabled=true;



                    startEnabled=true;
                    stopEnabled=true;

                    showPause=true;
                otherwise
                    steppingEnabled=false;
                    pacingEnabled=false;
                    startEnabled=SLM3I.SLCommonDomain.isSimulationStartPauseContinueEnabled(modelH);
                    stopEnabled=SLM3I.SLCommonDomain.isSimulationStopEnabled(modelH);
                    if strcmpi(simState,'running')
                        showPause=true;
                    else
                        showPause=false;
                    end
                end
                isRunning=hSrc.isRunning;
                isStopped=hSrc.isStopped;





                if slfeature('slPbcModelRefEditorReuse')&&~isempty(hSrc.BlockHandle)&&ishandle(hSrc.BlockHandle)&&isprop(hSrc.BlockHandle,'StudioTopLevel')
                    if isequal(simMode,'accelerator')...
                        ||isequal(simMode,'rapid-accelerator')...
                        ||isequal(simMode,'external')
                        srcObjParent=get_param(hSrc.BlockHandle.Parent,'Handle');

                        if(bdroot(srcObjParent)~=modelH)







                            steppingEnabled=false;
                            stopEnabled=false;
                            startEnabled=false;
                        end
                    end
                end

                configureNextStep(this,steppingEnabled,modelObject,isRunning);

                configurePreviousStep(this,steppingEnabled,modelObject,isRunning);





                configureStop(this,stopEnabled,isStopped);

                configureStart(this,startEnabled,showPause,isRunning,isStopped,pacingEnabled);

                configureFloatingControls(this);
                configureSelector(this);
            end
        end

        function configureFloatingControls(this,force)

            if~this.Installed
                return;
            end
            source=this.Source;
            if shouldShowControls(source,'Floating')
                if this.IsCompactToolbar&&(nargin<2||~force)
                    if strcmp(this.SplitAction,'Floating')
                        updateSelectionSplit(this);
                    end
                else

                    switch this.Source.ConnectionMode
                    case 'floating'
                        st_button='off';
                        st_menu='on';
                    case 'persistent'
                        st_button='on';
                        st_menu='off';
                    otherwise
                        error(message('Spcuilib:scopes:ErrorUnrecognizedConnectionMode'));
                    end

                    hUIMgr=this.UIMgr;
                    if isempty(hUIMgr)
                        if~isempty(this.Buttons.floating)
                            ud=this.Buttons.floating.UserData;
                            if strcmp(this.Source.ConnectionMode,'floating')
                                data=ud(2);
                            else
                                data=ud(1);
                            end
                            set(this.Buttons.floating,'State',st_button,...
                            'CData',data.icon,...
                            'TooltipString',data.tooltip);
                        end
                        set(this.Menus.floating,'Checked',st_menu);
                    else


                        hFloatButton=hUIMgr.findwidget('Toolbars','Playback','SimButtons','PlaybackModes','Floating');
                        set(hFloatButton,'State',st_button);
                        hFloatMenu=hUIMgr.findwidget('Menus','Playback','SimMenus','PlaybackModes','Floating');
                        set(hFloatMenu,'Checked',st_menu);
                    end
                end
            end
        end

        function configureSelector(this,force)

            source=this.Source;


            if shouldShowControls(source,'Selector')

                if this.IsCompactToolbar&&...
                    (nargin<2||~force)&&...
                    shouldShowControls(source,'Floating')
                    if strcmp(this.SplitAction,'Selector')
                        updateSelectionSplit(this);
                    end
                else
                    signalSelector=Simulink.scopes.source.SignalSelectorController.getInstance;
                    isSelectorOpen=uiservices.logicalToOnOff(signalSelector.isAttached(source.BlockHandle.Handle));

                    this.Buttons.selector.State=isSelectorOpen;


                    if ishandle(this.Menus.selector)
                        this.Menus.selector.Checked=isSelectorOpen;
                    end
                end
                Simulink.scopes.source.SignalSelectorController.enable(...
                source.BlockHandle,source.isRunning||source.isPaused);
            end
        end

        function configureNextStep(this,steppingEnabled,modelObject,isRunning)


            hNextStepButton=this.Buttons.nextStep;
            if isempty(hNextStepButton)
                return
            end

            if~isempty(this.UIMgr)
                hNextStepButton=hNextStepButton.WidgetHandle;
            end
            buttonEnable=get(hNextStepButton,'Enable');


            if~steppingEnabled
                buttonVisible='off';
            else
                buttonVisible='on';


                if(isRunning)&&~(this.Source.StepFwd)
                    buttonEnable='off';
                else
                    if this.Source.isPaused
                        modelH=modelObject.Handle;
                        stepper=Simulink.SimulationStepper(modelH);
                        if(stepper.finishedFinalStep())
                            buttonEnable='off';
                        else
                            buttonEnable='on';
                        end
                    else
                        buttonEnable='on';
                    end
                end
            end

            set(hNextStepButton,'Enable',buttonEnable);
            set(hNextStepButton,'Visible',buttonVisible);
        end

        function configurePreviousStep(this,steppingEnabled,modelObject,isRunning)


            hPrevStepBtn=this.Buttons.previousStep;
            if isempty(hPrevStepBtn)
                return
            end

            if~isempty(this.UIMgr)
                hPrevStepBtn=hPrevStepBtn.WidgetHandle;
            end
            buttonEnable=get(hPrevStepBtn,'Enable');
            modelH=modelObject.Handle;


            if~steppingEnabled
                buttonVisible='off';
                tooltips=getPreviousStepTooltips('disabled');
            else
                buttonVisible='on';


                if(isRunning)&&~(this.Source.StepFwd)
                    buttonEnable='off';
                    tooltips=getPreviousStepTooltips('disabled');
                else
                    buttonEnable='on';
                    tooltips=getPreviousStepTooltips('enabled');
                end
            end


            enabled=get_param(modelH,'EnableRollback');
            compliance=get_param(modelH,'SimulationRollbackCompliance');
            if(isequal(enabled,'off')||isequal(compliance,'uninitialized')||isequal(compliance,'noncompliant-fatal'))
                button_select=1;
                button_cb=@this.openSteppingOptions;
            else
                stepper=Simulink.SimulationStepper(modelObject.Name);
                numsteps=get_param(modelH,'NumberOfSteps');
                validity=stepper.validNumberOfStepsToRollback(numsteps);
                switch(validity)
                case-1
                    button_select=1;
                    button_cb=@this.openSteppingOptions;
                case 0
                    button_select=2;
                    button_cb=@this.slStepBack;
                    buttonEnable='off';
                    tooltips=getPreviousStepTooltips('disabled');
                case 1
                    button_select=2;
                    button_cb=@this.slStepBack;
                    tooltips=getPreviousStepTooltips('enabled');
                end
            end

            if isempty(this.UIMgr)
                ud=get(hPrevStepBtn,'UserData');

                set(hPrevStepBtn,ud(button_select));
                set(hPrevStepBtn,'TooltipString',tooltips{button_select})
            else
                set(hPrevStepBtn,'Selection',button_select,...
                'Tooltips',tooltips{button_select})
            end

            set(hPrevStepBtn,...
            'ClickedCallback',button_cb,...
            'Enable',buttonEnable,...
            'Visible',buttonVisible);
        end

        function configureStart(this,startEnabled,showPause,isRunning,isStopped,pacingEnabled)


            hPlayButton=this.Buttons.play;
            hPlayMenu=this.Menus.play;

            if~isempty(this.UIMgr)
                if~isempty(hPlayMenu)
                    hPlayMenu=hPlayMenu.WidgetHandle;
                end
                if~isempty(hPlayButton)
                    hPlayButton=hPlayButton.WidgetHandle;
                end
            end

            if(isempty(hPlayMenu)||~ishghandle(hPlayMenu))&&...
                (isempty(hPlayButton)||~ishghandle(hPlayButton))
                return;
            end


            if~startEnabled
                state='off';
            else
                state='on';
            end

            set(hPlayButton,'Enable',state);
            set(hPlayMenu,'Enable',state);

            if isRunning
                if showPause
                    mlabel=getString(message('Simulink:studio:StartPauseContinuePause'));
                    accel='';

                    button_select=2;
                else
                    accel='T';

                    if~pacingEnabled
                        button_select=1;
                        mlabel=getString(message('Simulink:studio:StartPauseContinueStart'));
                    else
                        button_select=4;
                        mlabel=getString(message('Simulink:studio:StartPauseContinueStartPacingEnabled'));
                    end
                end
            elseif isStopped
                accel='T';

                if~pacingEnabled
                    mlabel=getString(message('Simulink:studio:StartPauseContinueStart'));
                    button_select=1;
                else
                    mlabel=getString(message('Simulink:studio:StartPauseContinueStartPacingEnabled'));
                    button_select=4;
                end
            else
                accel='';
                if~pacingEnabled
                    mlabel=getString(message('Simulink:studio:StartPauseContinueContinue'));

                    button_select=3;
                else
                    mlabel=getString(message('Simulink:studio:StartPauseContinueContinuePacingEnabled'));

                    button_select=5;
                end
            end

            if isempty(this.UIMgr)
                ud=get(hPlayButton,'UserData');
                set(hPlayButton,ud(button_select));
            else
                set(hPlayButton,'Selection',button_select);
            end
            set(hPlayMenu,'Label',mlabel,'Accelerator',accel,...
            'Callback',@this.slPlayPause);
        end

        function configureSteppingOptions(this,steppingEnabled)



            hSteppingOptionsMenu=this.Menus.steppingOptions;
            if isempty(hSteppingOptionsMenu)
                return;
            end
            hSteppingOptionsMenu=hSteppingOptionsMenu.WidgetHandle;


            if~steppingEnabled
                menuEnable='off';
            else


                if(this.Source.isRunning)
                    menuEnable='off';
                else
                    menuEnable='on';
                end
            end


            set(hSteppingOptionsMenu,'Enable',menuEnable);
        end

        function configureStop(this,stopEnabled,isStopped)


            hStopMenu=this.Menus.stop;
            hStopButton=this.Buttons.stop;
            if~isempty(this.UIMgr)
                if~isempty(hStopMenu)
                    hStopMenu=hStopMenu.WidgetHandle;
                end
                if~isempty(hStopButton)
                    hStopButton=hStopButton.WidgetHandle;
                end
            end




            if isStopped||~stopEnabled
                state='off';
                accel='';
            else
                state='on';
                accel='T';
            end


            if~isempty(hStopMenu)
                set(hStopMenu,'Accelerator',accel,'Enable',state,...
                'Callback',@this.slStop);
            end


            if~isempty(hStopButton)
                set(hStopButton,'Enable',state);
            end
        end

        function updateSimControls(this)



            updateStatusBar(this);
            updateSnapshotPlaybackMode(this);
            updateAttributeReadouts(this);
        end

        function updateStatusBar(this)


            if this.Source.SnapShotMode
                str=getString(message('Spcuilib:scopes:TextFrozen'));
            elseif this.Source.isDisconnected
                str=getString(message('Spcuilib:scopes:TextDisconnected'));
            elseif this.Source.isStopped
                str=getString(message('Spcuilib:scopes:TextReady'));
            elseif this.Source.isPaused
                str=getString(message('Spcuilib:scopes:TextPaused'));
            else
                str=getString(message('Spcuilib:scopes:TextRunning'));
            end


            hStatus=this.StatusBar;
            if~isempty(this.UIMgr)
                hStatus=hStatus.WidgetHandle;
            end
            hStatus.Text=str;
        end

        function renderToolbars(this)


            hSource=this.Source;
            hScope=hSource.Application;
            if~hScope.Specification.RenderSimulationControls
                if shouldShowControls(hSource,'Selector')
                    hSource.Floating=true;
                end
                return;
            end
            h=hScope.Handles;
            allIcons=getIcons(this);
            hToolbar=h.([lower(this.ToolbarLocation),'Toolbar']);

            showNextStep=shouldShowControls(this.Source,'NextStep');
            showPreviousStep=shouldShowControls(this.Source,'PreviousStep');


            if isempty(hToolbar.Children)
                sep='off';
            else
                sep='on';
            end
            if showPreviousStep
                tooltips=getPreviousStepTooltips('enabled');
                ud=struct;
                ud(1).CData=allIcons.config_previous_step;
                ud(1).TooltipString=tooltips{1};
                ud(2).CData=allIcons.previous_step;
                ud(2).TooltipString=tooltips{2};
                this.Buttons.previousStep=uipushtool(hToolbar,...
                'Separator',sep,...
                'Tag','uimgr.spcpushtool_StepBack',...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'ClickedCallback',@this.openSteppingOptions,...
                'UserData',ud);
                sep='off';
            end

            ud(1).CData=allIcons.run;
            ud(1).TooltipString=getString(message('Spcuilib:scopes:ToolTipStartSimulation'));
            ud(2).CData=allIcons.pause;
            ud(2).TooltipString=getString(message('Spcuilib:scopes:ToolTipPauseSimulation'));
            ud(3).CData=allIcons.run;
            ud(3).TooltipString=getString(message('Spcuilib:scopes:ToolTipContinueSimulation'));
            ud(4).CData=allIcons.play_pacing_active;



            ud(4).TooltipString=getString(message('Spcuilib:scopes:ToolTipStartSimulation'));
            ud(5).CData=allIcons.play_pacing_active;
            ud(5).TooltipString=getString(message('Spcuilib:scopes:ToolTipContinueSimulation'));


            this.Buttons.play=uipushtool(hToolbar,...
            'Tag','uimgr.spcpushtool_Play',...
            'Interruptible','off',...
            'Separator',sep,...
            'BusyAction','cancel',...
            'CData',ud(1).CData,...
            'TooltipString',ud(1).TooltipString,...
            'ClickedCallback',@this.slPlayPause,...
            'UserData',ud);

            if(showNextStep||showPreviousStep)
                this.Buttons.nextStep=uipushtool(hToolbar,...
                'Tag','uimgr.spcpushtool_StepFwd',...
                'CData',allIcons.next_step,...
                'Interruptible','off',...
                'BusyAction','cancel',...
                'TooltipString',getString(message('Spcuilib:scopes:ToolTipNextStep')),...
                'ClickedCallback',@this.slStepFwd);
            end

            this.Buttons.stop=uipushtool(hToolbar,...
            'Tag','uimgr.spcpushtool_Stop',...
            'CData',allIcons.stop,...
            'Interruptible','off',...
            'BusyAction','cancel',...
            'TooltipString',getString(message('Spcuilib:scopes:ToolTipStopSimulation')),...
            'ClickedCallback',@this.slStop);

            isCompact=isToolbarCompact(hScope.Specification,'playbackmodes');
            hasFloating=shouldShowControls(hSource,'Floating');
            hasSelector=shouldShowControls(hSource,'Selector');
            hasSnapshot=shouldShowControls(hSource,'Snapshot');
            hasHilite=shouldShowControls(hSource,'Hilite');

            this.IsCompactToolbar=isCompact;

            bParent=hToolbar;
            sep='on';
            if isCompact
                if hasFloating
                    if hasSelector
                        orig_state=warning('off','MATLAB:uitogglesplittool:DeprecatedFunction');
                        this.Buttons.selectionSplit=uitogglesplittool(bParent,...
                        'Callback',@this.openSelectionSplit,...
                        'Separator',sep,...
                        'Tag','SelectionSplit');
                        warning(orig_state);
                        this.SplitAction='Floating';
                    else
                        this.Buttons.floating=renderFloatingButton(this,bParent,sep);
                    end
                    sep='off';
                elseif hasSelector
                    this.Buttons.selector=renderSelectorButton(this,bParent,sep);
                    sep='off';
                end

                if hasHilite
                    if hasSnapshot
                        orig_state=warning('off','MATLAB:uisplittool:DeprecatedFunction');
                        this.Buttons.modesSplit=uisplittool(bParent,...
                        'Callback',@this.openModesSplit,...
                        'Tag','ModesSplit',...
                        'Separator',sep,...
                        'CData',allIcons.signal_highlight,...
                        'TooltipString',getHighlightString(this.Source,'tooltip'),...
                        'ClickedCallback',@this.flash);
                        warning(orig_state);
                    else
                        this.Buttons.hilite=renderHiliteButton(this,bParent,sep);
                    end
                elseif hasSnapshot
                    this.Buttons.snapshot=renderSnapshotButton(this,bParent,sep);
                end
            else
                if hasFloating
                    this.Buttons.floating=renderFloatingButton(this,bParent,sep);
                    sep='off';
                end
                if hasSelector

                    this.Buttons.selector=renderSelectorButton(this,bParent,sep);
                    sep='off';
                end

                if hasHilite
                    this.Buttons.hilite=renderHiliteButton(this,bParent,sep);
                    sep='off';
                end
                if hasSnapshot
                    this.Buttons.snapshot=renderSnapshotButton(this,bParent,sep);
                end
            end
        end
    end

    methods(Access=protected)

        function f=getButtonFields(~)
            f={'play','stop','nextStep','selectionSplit','previousStep',...
            'floating','selector','modesSplit','hilite','snapshot'};
        end

        function f=getMenuFields(~)
            f={'play','floating','selector','stop','nextStep','hilite','synchronousLock'};
        end

        renderUIMgrWidgets(this)

        [hMenus,hButtons]=createSimControls(this)

        [mParent,bParent]=createPlaybackModes(this)

        hKeyPlayback=createKeyBindings(this)

        enableFloatingControls(this,enabState)

        enableSimControls(this,enabState)

        enableSnapshotPlaybackMode(this,ena)

        function b=renderFloatingButton(this,bParent,sep)
            ud=struct;
            allIcons=getIcons(this);
            ud(1).icon=allIcons.signal_locked;
            ud(1).tooltip=getString(message('Spcuilib:scopes:ToolTipPersistentSimulinkConnection'));
            ud(2).icon=allIcons.signal_unlocked;
            ud(2).tooltip=getString(message('Spcuilib:scopes:ToolTipFloatingSimulinkConnection'));
            b=uitoggletool(bParent,...
            'Tag','uimgr.spctoggletool_Floating',...
            'Separator',sep,...
            'UserData',ud,...
            'CData',ud(1).icon,...
            'Tooltip',ud(1).tooltip,...
            'State','on',...
            'ClickedCallback',@this.setConnectionMode);
        end

        function b=renderSelectorButton(this,bParent,sep)
            b=uitoggletool(bParent,...
            'Tag','uimgr.spctoggletool_Selector',...
            'CData',getIcons(this,'scpsigsel'),...
            'State','off',...
            'Separator',sep,...
            'TooltipString',getString(message('Spcuilib:scopes:ToolTipSignalSelector')),...
            'ClickedCallback',@this.toggleSignalSelector);
        end

        function b=renderHiliteButton(this,bParent,sep)
            b=uipushtool(bParent,...
            'Tag','uimgr.spcpushtool_Hilite',...
            'Separator',sep,...
            'CData',getIcons(this,'signal_highlight'),...
            'TooltipString',getHighlightString(this.Source,'tooltip'),...
            'ClickedCallback',@this.flash);
        end

        function b=renderSnapshotButton(this,bParent,sep)
            b=uitoggletool(bParent,...
            'Tag','uimgr.spctoggletool_Snapshot',...
            'CData',getIcons(this,'snapshot'),...
            'State','off',...
            'Separator',sep,...
            'TooltipString',getString(message('Spcuilib:scopes:ToolTipSnapshotFreeze')),...
            'ClickedCallback',@this.setSnapShotMode);
        end

        function updateAttributeReadouts(this)



            hFrame=this.FrameStatus;
            if~isempty(this.UIMgr)
                hFrame=hFrame.WidgetHandle;
            end
            hFrame.Tooltip=getTimeStatusTooltip(this.Source);
            hFrame.Callback('');

        end

        function updateSnapshotPlaybackMode(this)



            hButton=this.Buttons.snapshot;

            if isempty(hButton)
                return
            end

            if this.Source.SnapShotMode
                s='on';
            else
                s='off';
            end
            if~isempty(this.UIMgr)
                hButton=hButton.WidgetHandle;
            end
            set(hButton,'State',s,...
            'Enable',uiservices.logicalToOnOff(isSnapshotEnabled(this.Source)));

        end

        function icons=getIcons(this,tag)

            persistent savedIcons;

            if isempty(savedIcons)
                savedIcons=getappdata(this.Source.Application.Parent,'Icons');
            end

            icons=savedIcons;

            if nargin>1
                icons=icons.(tag);
            end
        end
    end
end


