classdef UpdateApp<handle




    properties
App
    end


    methods
        function this=UpdateApp(hApp)
            this.App=hApp;
        end
    end



    methods(Access=public,Hidden=true)


        function ForSelectedTarget(this,selectedTargetName)




            if isempty(selectedTargetName)



                this.disableLoadStartStopWidgets();


                this.App.TargetManager.RecordingControlButton.Enabled=false;
            else





                this.enableLoadStartStopWidgets();
                this.App.TargetManager.TargetLabel.Text=selectedTargetName;


                this.App.TargetsTree.selectTargetNameInTree(selectedTargetName);


                this.TargetConfigurationForDefaultTarget(selectedTargetName);
                this.TargetConfigurationForTargetSettings(selectedTargetName);

                this.ForMoveTargetControls(selectedTargetName);


                this.App.TargetManager.RecordingControlButton.Enabled=true;
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
                if~tg.get('Recording')
                    this.App.TargetManager.RecordingControlButton.Icon=this.App.Icons.startRecordingIcon;
                    this.App.TargetManager.RecordingControlButton.Text=getString(message('slrealtime:explorer:startRecording'));
                    this.App.TargetManager.RecordingControlButton.Description=getString(message('slrealtime:explorer:startRecordingDescription'));
                else
                    this.App.TargetManager.RecordingControlButton.Icon=this.App.Icons.stopRecordingIcon;
                    this.App.TargetManager.RecordingControlButton.Text=getString(message('slrealtime:explorer:stopRecording'));
                    this.App.TargetManager.RecordingControlButton.Description=getString(message('slrealtime:explorer:stopRecordingDescription'));
                end

                this.App.StatusBar.recordingStatusChanged();

                if slrealtime.internal.guis.Explorer.StaticUtils.isSLRTTargetConnected(selectedTargetName)
                    this.ForTargetConnected(selectedTargetName);
                else
                    this.ForTargetDisconnected(selectedTargetName);
                end
            end

        end


        function ForTargetConnected(this,targetName)









            target=this.App.TargetManager.getTargetFromMap(targetName);
            if target.warnings.isempty
                target.node.Icon=this.App.Icons.connectedIcon;

            else
                target.node.Icon=this.App.Icons.warningIcon;

            end





            if strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)
                this.App.TargetManager.ConnectDisconnectButton.Text=getString(message(this.App.Messages.connectedMsgId));
                this.App.TargetManager.ConnectDisconnectButton.Icon=this.App.Icons.connectedIcon;
                this.App.TargetManager.LoadApplicationButton.Enabled=true;
                this.ForTargetApplicationStatus(targetName);

                this.App.TargetManager.ConnectDisconnectButton.Description=getString(message(this.App.Tooltips.disconnectedTooltip));



                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                [isLoaded,appName]=tg.isLoaded();
                if isLoaded
                    mldatx=tg.getAppFile(appName);
                    if~isempty(mldatx)






                        try
                            tf=isequal(tg.getECUPage,tg.getXCPPage);
                        catch













                            tf=true;
                        end



                        if~isempty(target.tuning)
                            updatesTF=target.tuning.updatesOnHold;
                        else
                            updatesTF=false;
                        end
                        if~this.App.ParametersTab.EnableParamTableButton.Visible
                            if~tf&&~updatesTF

                                this.App.ParametersTab.EnableParamTableButton.Visible='on';

                                this.App.ParametersTab.ParametersTable.Enable='off';
                                this.App.ParametersTab.ParametersTable.Tooltip=...
                                getString(message('slrealtime:explorer:paramTableDisabledDueToPageSwitching'));

                                this.App.ParametersTab.RefreshParamValuesButton.Enable='off';
                                this.App.ParametersTab.RefreshParamValuesButton.Tooltip='';
                            end
                        else
                            if tf||updatesTF

                                this.App.ParametersTab.EnableParamTableButton.Visible='off';

                                this.App.ParametersTab.ParametersTable.Enable='on';
                                this.App.ParametersTab.ParametersTable.Tooltip='';

                                this.App.ParametersTab.RefreshParamValuesButton.Enable='on';
                                this.App.ParametersTab.RefreshParamValuesButton.Tooltip=...
                                getString(message('slrealtime:explorer:refreshParamValuesButtonTooltip'));
                            end
                        end


                        this.ForTargetApplicationLoaded(targetName,appName,'AppFile',mldatx);
                    end
                end




                this.disableWidgets(this.App.TargetConfiguration.IPaddressEditField);
                this.disableWidgets(this.App.TargetsTree.RemoveButton);


                this.App.TargetConfiguration.updateDiskUsageProgressBar(tg);


                this.App.TargetManager.updateTreeNodeForApplication(targetName);


                this.App.TargetConfiguration.updateApplicationUITable();


                this.App.SystemLogTab.tgConnected(targetName);
            end
        end


        function ForTargetDisconnected(this,targetName)








            target=this.App.TargetManager.getTargetFromMap(targetName);
            if target.warnings.isempty
                target.node.Icon=this.App.Icons.disconnectedIcon;

            else
                target.node.Icon=this.App.Icons.warningIcon;

            end




            if strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)
                this.App.TargetManager.ConnectDisconnectButton.Text=getString(message(this.App.Messages.disconnectedMsgId));
                this.App.TargetManager.ConnectDisconnectButton.Icon=this.App.Icons.disconnectedIcon;
                this.App.TargetManager.LoadApplicationButton.Enabled=false;
                this.ForTargetApplicationStatus(targetName);

                this.App.TargetManager.ConnectDisconnectButton.Description=getString(message(this.App.Tooltips.connectedTooltip));




                this.enableWidgets(this.App.TargetConfiguration.IPaddressEditField);
                this.enableWidgets(this.App.TargetsTree.RemoveButton);



                this.App.TargetConfiguration.updateDiskUsageProgressBar([]);


                this.App.TargetManager.updateTreeNodeForApplication(targetName);


                this.App.TargetConfiguration.updateApplicationUITable();


                this.App.SystemLogTab.tgDisconnected();
            end
        end


        function ForTargetApplicationLoaded(this,targetName,applicationName,varargin)




            p=inputParser;
            isScalarNumeric=@(x)isnumeric(x)&&(isscalar(x)||isempty(x));
            addParameter(p,'StopTime',[],isScalarNumeric);
            addParameter(p,'AppFile',[],@ischar);
            parse(p,varargin{:});
            stopTime=p.Results.StopTime;
            mldatx=p.Results.AppFile;



            if strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)




                this.App.TargetManager.LoadApplicationButton.Enabled=true;

                target=this.App.TargetManager.getTargetFromMap(targetName);
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);



                if isempty(target.Application)
                    Application=struct(...
                    'SLRTthis',[],...
                    'codeDescFolder',[],...
                    'codeDescriptor',[],...
                    'startListener',[],...
                    'stopListener',[],...
                    'ApplicationTreeNode',[],...
                    'stopTimeListener',[],...
                    'paramChangedListener',[],...
                    'paramSetChangedListener',[],...
                    'calPageChangedListener',[],...
                    'mldatx',[],...
                    'paramValues',containers.Map('KeyType','char','ValueType','any')...
                    );





                    Application.startListener=addlistener(tg,'Started',@(src,evnt)this.App.EventCallBack.targetApplicationStarted(src,evnt));
                    Application.stopListener=addlistener(tg,'Stopped',@(src,evnt)this.App.EventCallBack.targetApplicationStopped(src,evnt));
                    Application.stopTimeListener=addlistener(tg,'StopTimeChanged',@(src,evnt)this.App.EventCallBack.targetStopTime(src,evnt));
                    Application.paramChangedListener=addlistener(tg,'ParamChanged',@(src,evnt)this.App.EventCallBack.targetParamChanged(src,evnt));
                    Application.paramSetChangedListener=addlistener(tg,'ParamSetChanged',@(src,evnt)this.App.EventCallBack.targetParamSetChanged(src,evnt));
                    Application.calPageChangedListener=addlistener(tg,'CalPageChanged',@(src,evnt)this.App.EventCallBack.targetCalPageChanged(src,evnt));



                    if isempty(mldatx)
                        mldatx=tg.getAppFile(applicationName);
                    end
                    Application.mldatx=mldatx;
                    Application.SLRTthis=slrealtime.Application(mldatx);
                    Application.SLRTthis.extract('/host/dmr/');
                    wd=Application.SLRTthis.getWorkingDir;
                    RTWDirStruct=load(fullfile(wd,'host','dmr','RTWDirStruct.mat'));
                    Application.codeDescFolder=fullfile(wd,'host','dmr',RTWDirStruct.dirStruct.RelativeBuildDir);

                    huifig=this.App.UpdateApp.getShowingUIFigure();
                    previousProgressDlg=this.App.TargetManager.progressDlg;
                    if~isempty(huifig)
                        try
                            this.App.TargetManager.progressDlg=uiprogressdlg(huifig,...
                            'Indeterminate','on',...
                            'Message',message('slrealtime:explorer:buildingAppTree').getString,...
                            'Title',message('slrealtime:explorer:buildAppTreeTitle').getString);
                        catch e






                            if~strcmp(e.identifier,'MATLAB:uitools:uidialogs:InvisibleFigure')
                                rethrow(e);
                            end
                        end
                    end

                    try
                        [node,Application.codeDescriptor]=slrealtime.internal.guis.Explorer.createExplorerAppTree(Application.codeDescFolder);
                    catch ME


                        node=[];



                        huifig=this.getShowingUIFigure();
                        if this.App.App.Visible&&isempty(huifig)
                            huifig=this.App.SignalsPanel.UIFigure;
                        end
                        if~isempty(huifig)
                            uialert(huifig,ME.message,message('slrealtime:explorer:error').getString());
                        end
                    end
                    if~isequal(previousProgressDlg,this.App.TargetManager.progressDlg)

                        delete(this.App.TargetManager.progressDlg);
                        this.App.TargetManager.progressDlg=previousProgressDlg;
                    end

                    Application.ApplicationTreeNode=node;

                    target.Application=Application;
                    this.App.TargetManager.targetMap(targetName)=target;
                end



                this.App.SignalsTab.createAndCacheInstrumentsIfNeeded();



                if~isempty(target.Application.ApplicationTreeNode)







                    if~isempty(this.App.ApplicationTree.Tree.Children)
                        this.App.ApplicationTree.Tree.Children.Parent=[];
                    end
                    target.Application.ApplicationTreeNode.Parent=this.App.ApplicationTree.Tree;
                end
                this.App.ApplicationTree.Tree.Enable='on';
                this.App.ApplicationTree.Tree.SelectedNodes=target.Application.ApplicationTreeNode;

                this.ForTargetApplicationFilterButton();
                this.ForTargetApplicationSignalsFilterContents();
                this.ForTargetApplicationParametersFilterContents();
                this.ForTargetApplicationSignals(targetName);
                this.ForTargetApplicationParameters(targetName,'clearParamCache',true);
                this.ForTargetApplicationSignalsGroup(targetName);

                this.ForTargetApplicationStatus(targetName,'StopTime',stopTime);
            end
        end


        function ForTargetApplicationStatus(this,targetName,varargin)





            p=inputParser;
            isScalarNumeric=@(x)isnumeric(x)&&(isscalar(x)||isempty(x));
            addParameter(p,'StopTime',[],isScalarNumeric);
            parse(p,varargin{:});
            stopTime=p.Results.StopTime;



            if strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)
                if slrealtime.internal.guis.Explorer.StaticUtils.isSLRTTargetConnected(targetName)


                    tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);

                    [isLoaded,appName]=tg.isLoaded();

                    if~isLoaded

                        this.App.TargetManager.StartStopButton.Icon=this.App.Icons.runIcon;
                        this.App.TargetManager.StartStopButton.Text=getString(message(this.App.Messages.startMsgId));
                        this.App.TargetManager.StartStopButton.Description=getString(message('slrealtime:explorer:startButtonTooltip'));
                        this.App.TargetManager.StartStopButton.Enabled=false;

                        this.App.TargetManager.StopTimeField.Enabled=false;
                        this.App.TargetManager.StopTimeField.Value='';

                        this.App.TargetManager.HoldUpdatesButton.Enabled=false;
                        this.App.TargetManager.UpdateParamsButton.Enabled=false;
                        this.App.TargetManager.HoldUpdatesButton.Value=false;

                        this.disableGUIForTargetApplication();










                        if~isempty(tg.ModelStatus)&&~isempty(tg.ModelStatus.State)
                            this.App.StatusBar.StatusLabel.Text=[char(tg.ModelStatus.State)...
                            ,': ',char(tg.ModelStatus.Application)];
                            execTime=tg.ModelStatus.ExecTime;
                            if(execTime~=0)
                                this.App.StatusBar.ExecTimeLabel.Text=['T=',num2str(execTime)];
                            else
                                this.App.StatusBar.ExecTimeLabel.Text='';
                            end
                        else
                            this.App.StatusBar.StatusLabel.Text='';
                            this.App.StatusBar.ExecTimeLabel.Text='';
                        end

                        target=this.App.TargetManager.getTargetFromMap(targetName);
                        if~isempty(target.tuning)
                            target.tuning.updatesOnHold=false;
                            target.tuning.paramTableChanged=false;
                            this.App.TargetManager.targetMap(targetName)=target;
                        end

                    else
                        if isempty(stopTime)
                            stopTime=tg.ModelStatus.StopTime;
                        end
                        this.App.TargetManager.StopTimeField.Value=num2str(stopTime);

                        if tg.isRunning
                            this.App.TargetManager.StartStopButton.Icon=this.App.Icons.stopIcon;
                            this.App.TargetManager.StartStopButton.Text=getString(message(this.App.Messages.stopMsgId));
                            this.App.TargetManager.StartStopButton.Description=getString(message('slrealtime:explorer:stopButtonTooltip'));
                            this.App.TargetManager.StartButtonReloadOnStopOption.Enabled=false;
                            this.App.TargetManager.StartButtonAutoImportFileLogOption.Enabled=false;
                            this.App.TargetManager.StopTimeField.Enabled=false;



                            try
                                tf=isequal(tg.getECUPage,tg.getXCPPage);
                            catch













                                tf=true;
                            end
                            if tf




                                this.App.TargetManager.HoldUpdatesButton.Enabled=true;
                                this.App.TargetManager.HoldUpdatesButton.Value=false;
                                this.App.TargetManager.UpdateParamsButton.Enabled=false;
                            else



                                target=this.App.TargetManager.getTargetFromMap(targetName);
                                if~isempty(target.tuning)
                                    updatesTF=target.tuning.updatesOnHold;
                                else
                                    updatesTF=false;
                                end

                                if updatesTF



                                    this.App.TargetManager.HoldUpdatesButton.Enabled=true;
                                    this.App.TargetManager.HoldUpdatesButton.Value=true;
                                    this.App.TargetManager.UpdateParamsButton.Enabled=true;


                                    if~isempty(target.Application)
                                        target.Application.calPageChangedListener.Enabled=false;
                                        this.App.TargetManager.targetMap(targetName)=target;
                                    end
                                else



                                    this.App.TargetManager.HoldUpdatesButton.Enabled=false;
                                    this.App.TargetManager.HoldUpdatesButton.Value=false;
                                    this.App.TargetManager.UpdateParamsButton.Enabled=false;
                                end
                            end
                        else
                            this.App.TargetManager.StartStopButton.Icon=this.App.Icons.runIcon;
                            this.App.TargetManager.StartStopButton.Text=getString(message(this.App.Messages.startMsgId));
                            this.App.TargetManager.StartStopButton.Description=getString(message('slrealtime:explorer:startButtonTooltip'));
                            this.App.TargetManager.StartButtonReloadOnStopOption.Enabled=true;
                            this.App.TargetManager.StartButtonAutoImportFileLogOption.Enabled=true;
                            this.App.TargetManager.StopTimeField.Enabled=true;
                            this.App.TargetManager.HoldUpdatesButton.Enabled=false;
                            this.App.TargetManager.UpdateParamsButton.Enabled=false;
                            this.App.TargetManager.HoldUpdatesButton.Value=false;

                            target=this.App.TargetManager.getTargetFromMap(targetName);
                            if~isempty(target.tuning)
                                target.tuning.updatesOnHold=false;
                                target.tuning.paramTableChanged=false;
                                this.App.TargetManager.targetMap(targetName)=target;
                            end

                        end
                        this.App.TargetManager.StartStopButton.Enabled=true;







                        this.App.StatusBar.StatusLabel.Text=[char(tg.ModelStatus.State)...
                        ,': ',appName];
                        execTime=tg.ModelStatus.ExecTime;
                        if(execTime~=0)
                            this.App.StatusBar.ExecTimeLabel.Text=['T=',num2str(execTime)];
                        else
                            this.App.StatusBar.ExecTimeLabel.Text='';
                        end
                    end
                else


                    this.App.TargetManager.StartStopButton.Icon=this.App.Icons.runIcon;
                    this.App.TargetManager.StartStopButton.Text=getString(message(this.App.Messages.startMsgId));
                    this.App.TargetManager.StartStopButton.Description=getString(message('slrealtime:explorer:startButtonTooltip'));
                    this.App.TargetManager.StartStopButton.Enabled=false;


                    this.App.TargetManager.RecordingControlButton.Enabled=true;

                    this.App.TargetManager.StopTimeField.Enabled=false;
                    this.App.TargetManager.StopTimeField.Value='';

                    this.App.TargetManager.HoldUpdatesButton.Enabled=false;
                    this.App.TargetManager.UpdateParamsButton.Enabled=false;
                    this.App.TargetManager.HoldUpdatesButton.Value=false;

                    this.disableGUIForTargetApplication();

                    this.App.StatusBar.disable();
                end
            end
        end

        function ForTargetApplicationFilterButton(this)







            targetName=this.App.TargetManager.getSelectedTargetName();

            target=this.App.TargetManager.getTargetFromMap(targetName);

            selectedApplicationNode=this.App.ApplicationTree.Tree.SelectedNodes;
            if~isempty(selectedApplicationNode)



                this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Enable='on';
                this.App.SignalsPanel.FilterContentsOfLabel.Enable='on';
                this.App.SignalsPanel.FilterSystemLabel.Enable='on';

                this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Enable='on';
                this.App.ParametersPanel.FilterContentsOfLabel.Enable='on';
                this.App.ParametersPanel.FilterSystemLabel.Enable='on';

                text=this.App.TargetManager.getPathForApplicationNode(selectedApplicationNode);

                if target.filters.currentSystemAndBelow
                    this.App.SignalsPanel.FilterSystemLabel.Text=[text,' (',getString(message('slrealtime:explorer:andbelow')),')'];
                    this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Value=true;
                    this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Icon=this.App.Icons.curSysAndBelowIcon;
                    this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Tooltip=getString(message(this.App.Tooltips.contentsOnlyTooltip));

                    this.App.ParametersPanel.FilterSystemLabel.Text=[text,' (',getString(message('slrealtime:explorer:andbelow')),')'];
                    this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Value=true;
                    this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Icon=this.App.Icons.curSysAndBelowIcon;
                    this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Tooltip=getString(message(this.App.Tooltips.contentsOnlyTooltip));
                else
                    this.App.SignalsPanel.FilterSystemLabel.Text=[text,' (',getString(message('slrealtime:explorer:only')),')'];
                    this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Value=false;
                    this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Icon=this.App.Icons.currentSystemIcon;
                    this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Tooltip=getString(message(this.App.Tooltips.contentsBelowTooltip));

                    this.App.ParametersPanel.FilterSystemLabel.Text=[text,' (',getString(message('slrealtime:explorer:only')),')'];
                    this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Value=false;
                    this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Icon=this.App.Icons.currentSystemIcon;
                    this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Tooltip=getString(message(this.App.Tooltips.contentsBelowTooltip));
                end

                this.App.SignalsTab.updateAcquireListManagement('on');

            else



                this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Enable='off';
                this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Value=false;
                this.App.SignalsPanel.FilterCurrentSystemAndBelowButton.Icon=this.App.Icons.currentSystemIcon;
                this.App.SignalsPanel.FilterContentsOfLabel.Enable='off';
                this.App.SignalsPanel.FilterSystemLabel.Enable='off';
                this.App.SignalsPanel.FilterSystemLabel.Text='';

                this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Enable='off';
                this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Value=false;
                this.App.ParametersPanel.FilterCurrentSystemAndBelowButton.Icon=this.App.Icons.currentSystemIcon;
                this.App.ParametersPanel.FilterContentsOfLabel.Enable='off';
                this.App.ParametersPanel.FilterSystemLabel.Enable='off';
                this.App.ParametersPanel.FilterSystemLabel.Text='';

                this.App.SignalsTab.updateAcquireListManagement('off');
            end

        end

        function ForTargetApplicationSignalsFilterContents(this)







            targetName=this.App.TargetManager.getSelectedTargetName();

            target=this.App.TargetManager.getTargetFromMap(targetName);

            selectedApplicationNode=this.App.ApplicationTree.Tree.SelectedNodes;
            if~isempty(selectedApplicationNode)





                if~isempty(target.filters.signalsFilterContents)
                    this.App.SignalsPanel.FilterContentsEditField.Value=target.filters.signalsFilterContents;
                else
                    this.App.SignalsPanel.FilterContentsEditField.Value='';
                end
                this.App.SignalsPanel.FilterContentsEditField.Enable='on';

                this.App.SignalsPanel.FilterContentsEditField.Tooltip=getString(message(this.App.Tooltips.filterTooltip));

                this.App.SignalsTab.updateAcquireListManagement('on');

            else



                this.App.SignalsPanel.FilterContentsEditField.Enable='off';
                this.App.SignalsPanel.FilterContentsEditField.Value='';

                this.App.SignalsTab.updateAcquireListManagement('off');
            end

        end

        function ForTargetApplicationParametersFilterContents(this)







            targetName=this.App.TargetManager.getSelectedTargetName();

            target=this.App.TargetManager.getTargetFromMap(targetName);

            selectedApplicationNode=this.App.ApplicationTree.Tree.SelectedNodes;
            if~isempty(selectedApplicationNode)





                if~isempty(target.filters.parametersFilterContents)
                    this.App.ParametersPanel.FilterContentsEditField.Value=target.filters.parametersFilterContents;
                else
                    this.App.ParametersPanel.FilterContentsEditField.Value='';
                end
                this.App.ParametersPanel.FilterContentsEditField.Enable='on';

                this.App.ParametersPanel.FilterContentsEditField.Tooltip=getString(message(this.App.Tooltips.filterTooltip));

            else



                this.App.ParametersPanel.FilterContentsEditField.Enable='off';
                this.App.ParametersPanel.FilterContentsEditField.Value='';
            end

        end

        function ForTargetApplicationSignals(this,targetName)






            if strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)

                target=this.App.TargetManager.getTargetFromMap(targetName);

                selectedApplicationNode=this.App.ApplicationTree.Tree.SelectedNodes;
                if isempty(selectedApplicationNode)
                    this.App.SignalsTab.SignalsTable.UserData=[];
                    this.App.SignalsTab.SignalsTable.Data=[];
                    this.App.SignalsTab.SignalsTable.Enable='off';
                    this.App.SignalsTab.HighlightSignalInModelButton.Enable='off';
                    this.App.SignalsTab.HighlightSignalInModelButton.Tooltip='';
                    this.App.SignalsTab.AddToSignalGroupButton.Enable='off';
                else



                    if isempty(target.Application.codeDescriptor)





                        return;
                    end

                    availSigs=slrealtime.Application.extractSignals(target.Application.codeDescriptor,...
                    selectedApplicationNode.NodeData.path,target.filters.currentSystemAndBelow);
                    availSigs=availSigs';
                    blkpaths=cell(size(availSigs));
                    for idx=1:length(availSigs)
                        blkpaths{idx}=slrealtime.internal.guis.Explorer.StaticUtils.convertBlockPathsToDisplayStringForSignal(availSigs(idx).BlockPath,availSigs(idx).PortIndex,'');
                    end


                    [blkpaths,idx]=sort(blkpaths);
                    availSigs=availSigs(idx);
                    signames={availSigs.SignalLabel}';



                    if~isempty(blkpaths)
                        if~isempty(target.filters.signalsFilterContents)
                            sigNameIdxs=find(cellfun(@(x)contains(x,target.filters.signalsFilterContents,'IgnoreCase',true),signames));
                            blkPathIdxs=find(cellfun(@(x)contains(x,target.filters.signalsFilterContents,'IgnoreCase',true),blkpaths));
                            idxs=union(sigNameIdxs,blkPathIdxs);
                            blkpaths=blkpaths(idxs);
                            signames=signames(idxs);
                            availSigs=availSigs(idxs);
                        end
                    end



                    if isempty(availSigs)
                        this.App.SignalsTab.SignalsTable.UserData=[];
                        this.App.SignalsTab.SignalsTable.Data=[];
                    else
                        this.App.SignalsTab.SignalsTable.UserData=availSigs;
                        this.App.SignalsTab.SignalsTable.Data=[blkpaths,signames];
                    end
                    this.App.SignalsTab.SignalsTable.Enable='on';



                    this.App.SignalsTab.App.SignalsTab.AddToSignalGroupButton.Enable='off';
                    this.App.SignalsTab.HighlightSignalInModelButton.Enable='off';
                    this.App.SignalsTab.HighlightSignalInModelButton.Tooltip='';
                    if isempty(this.App.SignalsTab.InstrumentationTable.Selection)
                        this.App.SignalsTab.RemoveFromSignalGroupButton.Enable='off';
                    end
                end
            end
        end

        function[valStrs,types,dims,vals]=getSLRTTargetParameterValues(this,targetName,parameters,blkpaths,varargin)
















            p=inputParser;
            addParameter(p,'showProgressDlg',true,@(x)islogical(x)&&isscalar(x));
            addParameter(p,'refreshValues',false,@(x)islogical(x)&&isscalar(x));
            parse(p,varargin{:});
            showProgressDlg=p.Results.showProgressDlg;
            refreshValues=p.Results.refreshValues;

            valStrs=cell(size(parameters));
            types=cell(size(parameters));
            dims=cell(size(parameters));
            vals=cell(size(parameters));

            if this.App.ParametersTab.EnableParamTableButton.Visible





                return;
            end

            previousProgressDlg=this.App.TargetManager.progressDlg;
            if showProgressDlg
                huifig=this.App.UpdateApp.getShowingUIFigure();
                err=false;
                if~isempty(huifig)
                    try
                        this.App.TargetManager.progressDlg=uiprogressdlg(huifig,...
                        'Message',message('slrealtime:explorer:gettingParamValues').getString,...
                        'Title',message('slrealtime:explorer:getParamValuesTitle').getString,...
                        'Cancelable',true,...
                        'CancelText',message('slrealtime:explorer:cancel').getString);

                        this.App.TargetManager.progressDlg.Value=0;
                    catch e






                        err=true;
                        if~strcmp(e.identifier,'MATLAB:uitools:uidialogs:InvisibleFigure')
                            rethrow(e);
                        end
                    end
                end
            end

            numParams=length(parameters);
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
            target=this.App.TargetManager.getTargetFromMap(targetName);

            try
                for nParam=1:numParams
                    if showProgressDlg
                        if(~isempty(huifig))&&(~err)
                            if this.App.TargetManager.progressDlg.CancelRequested
                                valStrs{nParam}='<user cancelled>';
                                this.App.TargetManager.progressDlg.Value=nParam/numParams;
                                continue;
                            end
                        end
                    end

                    try
                        aKey=slrealtime.internal.guis.Explorer.StaticUtils.convertToParamValuesCacheKey(...
                        blkpaths{nParam},parameters(nParam).BlockParameterName);
                        if refreshValues||~target.Application.paramValues.isKey(aKey)
                            val=tg.getparam(parameters(nParam).BlockPath,parameters(nParam).BlockParameterName);
                            target.Application.paramValues(aKey)=val;
                        else
                            val=target.Application.paramValues(aKey);
                        end
                        vals{nParam}=val;

                        if isa(val,'embedded.fi')
                            types{nParam}=val.numerictype.tostringInternalFixdt;
                        else
                            types{nParam}=class(val);
                        end

                        dim=size(val);
                        if(length(dim)>2)&&(length(dim)<5)

                            tmp='<';
                            for k=1:length(dim)-1
                                tmp=strcat(tmp,num2str(dim(k)),'x');
                            end
                            valStrs{nParam}=[tmp,num2str(dim(end)),' ',types{nParam},'>'];
                        elseif(length(dim)>=5)

                            valStrs{nParam}=['<',num2str(length(dim)),'-D ',types{nParam},'>'];
                        elseif isstruct(val)

                            valStrs{nParam}=['<',num2str(dim(1)),'x',num2str(dim(2)),' struct>'];
                        else

                            valStrs{nParam}=mat2str(val);
                        end
                    catch
                        valStrs{nParam}='<error getting value>';
                        continue;
                    end

                    dims{nParam}=mat2str(size(val));

                    if showProgressDlg
                        if(~isempty(huifig))&&(~err)
                            this.App.TargetManager.progressDlg.Value=nParam/numParams;
                        end
                    end
                end
            catch



            end

            if~isequal(previousProgressDlg,this.App.TargetManager.progressDlg)

                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=previousProgressDlg;
            end
        end

        function ForTargetApplicationParameters(this,targetName,varargin)



            p=inputParser;
            addParameter(p,'clearParamCache',false,@(x)islogical(x)&&isscalar(x));
            parse(p,varargin{:});
            clearParamCache=p.Results.clearParamCache;



            if strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)

                target=this.App.TargetManager.getTargetFromMap(targetName);
                if isempty(target.Application)
                    return;
                end

                selectedApplicationNode=this.App.ApplicationTree.Tree.SelectedNodes;
                if isempty(selectedApplicationNode)
                    this.App.ParametersTab.ParametersTable.UserData=[];
                    this.App.ParametersTab.ParametersTable.Data=[];
                    this.App.ParametersTab.ParametersTable.Enable='off';
                    this.App.ParametersTab.ParametersTable.Tooltip='';
                    this.App.ParametersTab.HighlightParameterInModelButton.Enable='off';
                    this.App.ParametersTab.HighlightParameterInModelButton.Tooltip='';
                    this.App.ParametersTab.RefreshParamValuesButton.Enable='off';
                    this.App.ParametersTab.RefreshParamValuesButton.Tooltip='';

                    this.App.TargetManager.HoldUpdatesButton.Value=false;
                    this.App.TargetManager.HoldUpdatesButton.Enabled=false;
                    this.App.TargetManager.UpdateParamsButton.Enabled=false;
                else




                    if isempty(target.Application.codeDescriptor)





                        return;
                    end

                    params=slrealtime.Application.extractParameters(target.Application.codeDescriptor,...
                    selectedApplicationNode.NodeData.path,target.filters.currentSystemAndBelow);
                    params=params';
                    blkpaths=cell(size(params));
                    for idx=1:length(params)
                        blkpaths{idx}=slrealtime.internal.guis.Explorer.StaticUtils.convertBlockPathsToDisplayString(params(idx).BlockPath);
                    end




                    if~isempty(params)
                        [~,idx]=unique(strcat(pad(blkpaths),' ',{params.BlockParameterName}'));
                        blkpaths=blkpaths(idx);
                        params=params(idx);
                        paramnames={params.BlockParameterName}';
                    else
                        paramnames=cell(size(params));
                    end



                    if~isempty(blkpaths)
                        if~isempty(target.filters.parametersFilterContents)
                            paramNameIdxs=find(cellfun(@(x)contains(x,target.filters.parametersFilterContents,'IgnoreCase',true),paramnames));
                            blkPathIdxs=find(cellfun(@(x)contains(x,target.filters.parametersFilterContents,'IgnoreCase',true),blkpaths));
                            idxs=union(paramNameIdxs,blkPathIdxs);
                            blkpaths=blkpaths(idxs);
                            paramnames=paramnames(idxs);
                            params=params(idxs);
                        end
                    end



                    if clearParamCache


                        target.Application.paramValues=containers.Map('KeyType','char','ValueType','any');
                        this.App.TargetManager.targetMap(targetName)=target;
                    end
                    [valStrs,types,dims,vals]=this.getSLRTTargetParameterValues(targetName,params,blkpaths);



                    [params.value]=vals{:};
                    this.App.ParametersTab.ParametersTable.UserData=params;
                    this.App.ParametersTab.ParametersTable.Data=[blkpaths,paramnames,valStrs,types,dims];
                    if~this.App.ParametersTab.EnableParamTableButton.Visible




                        this.App.ParametersTab.ParametersTable.Enable='on';
                        this.App.ParametersTab.RefreshParamValuesButton.Enable='on';
                        this.App.ParametersTab.RefreshParamValuesButton.Tooltip=...
                        getString(message('slrealtime:explorer:refreshParamValuesButtonTooltip'));
                    end



                    this.App.ParametersTab.HighlightParameterInModelButton.Enable='off';
                    this.App.ParametersTab.HighlightParameterInModelButton.Tooltip='';
                end
            end
        end

        function ForTargetApplicationSignalsGroup(this,targetName)







            if strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)

                target=this.App.TargetManager.getTargetFromMap(targetName);
                pInst=target.instruments.pending;


                this.App.SignalsTab.updateInstrumentationTable(pInst);




                this.adjustInstrumentButtons(target);
            end
        end

        function ForMoveTargetControls(this,targetName)




            if this.App.TargetsTree.TargetComputersNode==1
                this.disableWidgets(this.App.TargetsTree.UpButton);
                this.disableWidgets(this.App.TargetsTree.DownButton);
            else
                nodes=this.App.TargetsTree.TargetComputersNode.Children;
                idxs=strcmp(arrayfun(@(x)x.NodeData.targetName,nodes,'UniformOutput',false),targetName);
                if length(idxs)==1
                    this.disableWidgets(this.App.TargetsTree.UpButton);
                    this.disableWidgets(this.App.TargetsTree.DownButton);
                elseif idxs(1)
                    this.disableWidgets(this.App.TargetsTree.UpButton);
                    this.enableWidgets(this.App.TargetsTree.DownButton);
                elseif idxs(end)
                    this.enableWidgets(this.App.TargetsTree.UpButton);
                    this.disableWidgets(this.App.TargetsTree.DownButton);
                else
                    this.enableWidgets(this.App.TargetsTree.UpButton);
                    this.enableWidgets(this.App.TargetsTree.DownButton);
                end
            end
        end




        function disableGUIForTargetApplication(this)






            this.App.ApplicationTree.disable();
            this.App.SignalsPanel.disable();
            this.App.SignalsTab.disable();
            this.App.ParametersPanel.disable();
            this.App.ParametersTab.disable();
        end

        function enableLoadStartStopWidgets(this)
            this.App.TargetManager.LoadApplicationButton.Enabled=true;
            this.App.TargetManager.StartStopButton.Enabled=true;
            this.App.TargetManager.StopTimeField.Enabled=true;
            this.App.TargetManager.HoldUpdatesButton.Enabled=true;
        end

        function disableLoadStartStopWidgets(this)
            this.App.TargetManager.LoadApplicationButton.Enabled=false;
            this.App.TargetManager.StartStopButton.Enabled=false;
            this.App.TargetManager.StopTimeField.Enabled=false;
            this.App.TargetManager.HoldUpdatesButton.Enabled=false;
            this.App.TargetManager.UpdateParamsButton=false;
            this.App.TargetManager.HoldUpdatesButton.Value=false;
        end

        function adjustInstrumentButtons(this,target)








            pInst=target.instruments.pending;


            if isempty(pInst.signals)




                this.App.SignalsTab.AddInstrumentButton.Enable='off';
                this.App.SignalsTab.AddInstrumentButton.Icon=this.App.Icons.addInstrumentIcon;
                this.App.SignalsTab.AddInstrumentButton.Tooltip='';
                this.App.SignalsTab.AddInstrumentButton.Text=...
                getString(message('slrealtime:explorer:addInstrument'));
            elseif isempty(target.instruments.streamed)




                this.App.SignalsTab.AddInstrumentButton.Enable='on';
                this.App.SignalsTab.AddInstrumentButton.Icon=this.App.Icons.addInstrumentIcon;
                this.App.SignalsTab.AddInstrumentButton.Tooltip=...
                getString(message(this.App.Tooltips.streamSignalGroupTooltip));
                this.App.SignalsTab.AddInstrumentButton.Text=...
                getString(message('slrealtime:explorer:addInstrument'));
            elseif isequal(pInst.signals,target.instruments.streamed.signals)





                this.App.SignalsTab.AddInstrumentButton.Enable='off';
                this.App.SignalsTab.AddInstrumentButton.Icon=this.App.Icons.addInstrumentIcon;
                this.App.SignalsTab.AddInstrumentButton.Tooltip='';
                this.App.SignalsTab.AddInstrumentButton.Text=...
                getString(message('slrealtime:explorer:addInstrument'));
            else





                this.App.SignalsTab.AddInstrumentButton.Enable='on';
                this.App.SignalsTab.AddInstrumentButton.Icon=this.App.Icons.configureInstrumentIcon;
                this.App.SignalsTab.AddInstrumentButton.Tooltip=...
                getString(message(this.App.Tooltips.streamSignalGroupTooltip));
                this.App.SignalsTab.AddInstrumentButton.Text=...
                getString(message('slrealtime:explorer:configureInstrument'));
            end


            if isempty(target.instruments.streamed)

                this.App.SignalsTab.RemoveInstrumentButton.Enable='off';
                this.App.SignalsTab.RemoveInstrumentButton.Tooltip='';
            else

                this.App.SignalsTab.RemoveInstrumentButton.Enable='on';
                this.App.SignalsTab.RemoveInstrumentButton.Tooltip=...
                getString(message(this.App.Tooltips.stopStreamSignalGroupTooltip));
            end



            this.App.SignalsTab.MonitorModeButton.Enable='on';
            this.App.SignalsTab.MonitorModeButton.Tooltip=...
            getString(message(this.App.Tooltips.pressToMonitor));


            if~isempty(target.instruments.streamed)&&~isempty(target.instruments.streamed.LockedByTarget)





                this.App.SignalsTab.MonitorModeButton.Value=true;


                this.App.SignalsTab.InstrumentationTable.ColumnName={...
                getString(message(this.App.Messages.tableColumnNameBlockPathMsgId));...
                getString(message(this.App.Messages.tableColumnNameValueMsgId))};
                this.App.SignalsTab.InstrumentationTable.ColumnWidth={'1x','1x'};
                n=size(this.App.SignalsTab.InstrumentationTable.Data,1);
                this.App.SignalsTab.InstrumentationTable.Data=...
                [this.App.SignalsTab.InstrumentationTable.Data(:,1),cell(n,1)];
            end



            this.App.SignalsTab.updateAcquireListManagement('on');
        end
    end



    methods(Static,Access=private)




        function enableWidgets(widget)
            slrealtime.internal.guis.Explorer.StaticUtils.enableDisableWidgets(widget,'on');
        end

        function disableWidgets(widget)
            slrealtime.internal.guis.Explorer.StaticUtils.enableDisableWidgets(widget,'off');
        end

    end





    methods(Access=public,Hidden=true)

        function TargetConfigurationForDefaultTarget(this,~)










            targetNames=this.App.TargetManager.targetMap.keys;
            for i=1:length(targetNames)
                targetName=targetNames{i};
                target=this.App.TargetManager.getTargetFromMap(targetName);
                target.node.Text=this.App.TargetManager.getTreeNodeTextForTarget(targetName);
            end



            defaultTargetName=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTDefaultTargetName();
            isDefaultTarget=strcmp(this.App.TargetManager.getSelectedTargetName(),defaultTargetName);
            this.App.TargetConfiguration.DefaultCheckBox.Value=isDefaultTarget;
            this.App.TargetConfiguration.DefaultCheckBox.Enable=~isDefaultTarget;

        end

        function TargetConfigurationForTargetSettings(this,targetName)






            if strcmp(this.App.TargetManager.getSelectedTargetName(),targetName)

                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                settings=tg.TargetSettings;

                this.App.TargetConfiguration.NameEditField.Value=settings.name;
                this.App.TargetConfiguration.IPaddressEditField.Value=settings.address;
            end
        end



































































    end



    methods(Access=public,Hidden=true)

        function huifig=getShowingUIFigure(this)

            huifig=[];
            documents=this.App.App.getDocuments;
            for i=1:length(documents)
                if documents{i}.Showing

                    huifig=documents{i}.Figure;
                    return
                end
            end
        end

    end


end
