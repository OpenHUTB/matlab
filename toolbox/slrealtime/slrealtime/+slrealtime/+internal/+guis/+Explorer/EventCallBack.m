classdef EventCallBack<handle













    properties
App
    end


    methods
        function this=EventCallBack(hApp)
            this.App=hApp;
        end
    end

    methods(Access=public,Hidden=true)


        function targetConnected(this,src,~)



            targetName=src.TargetSettings.name;
            this.App.UpdateApp.ForTargetConnected(targetName);
            notify(this.App.TargetManager,'targetChangeEvent')



            this.App.TargetManager.addStatusBarListeners(targetName);



            [target,performUpdate]=this.App.TargetManager.updateStartupAppInMap(targetName);
            if(performUpdate)
                this.App.TargetConfiguration.updateGUIForApplicationStartup(target.startupApp.appName,targetName);
            end





            if~isempty(this.App.TargetManager.progressDlg)
                drawnow;
                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=[];
            end
        end

        function targetDisconnected(this,src,~)








            targetName=src.TargetSettings.name;
            this.App.TargetManager.clearTargetApplicationCachedProperties(targetName);
            this.App.TargetManager.clearCachedInstruments(targetName);
            this.App.SystemLogTab.clearSystemLogViewerCachedProperties(targetName);
            this.App.UpdateApp.ForTargetDisconnected(targetName);
            notify(this.App.TargetManager,'targetChangeEvent')





            if~isempty(this.App.TargetManager.progressDlg)
                drawnow;
                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=[];
            end
        end

        function targetApplicationInstalled(this,src,event)



            targetName=src.TargetSettings.name;
            applicationName=event.appName;
            target=this.App.TargetManager.getTargetFromMap(targetName);



            if isempty(target.node.Children)||...
                (~any(strcmp(arrayfun(@(x)x.NodeData.appName,target.node.Children,'UniformOutput',false),applicationName)))
                n=uitreenode(target.node);
                n.NodeData=slrealtime.internal.guis.TCMTreeNodeData.createAppTreeNodeData(targetName,applicationName);
                n.Icon=this.App.Icons.mldatxIcon;
                n.Text=this.App.TargetsTree.getTreeNodeTextForApplication(applicationName,targetName);


                target=this.App.TargetManager.updateStartupAppInMap(targetName);
                this.App.TargetManager.applyContextMenuToTargetsTreeAppNode(n,strcmp(applicationName,target.startupApp.appName));
            end
            target.node.collapse();



            this.App.TargetConfiguration.updateApplicationUITable();
        end

        function targetApplicationLoaded(this,src,event)









            targetName=src.TargetSettings.name;
            applicationName=src.get('tc.ModelProperties.Application');

            if~event.IsReloadOnStop
                this.App.TargetManager.clearTargetApplicationCachedProperties(targetName);
                this.App.TargetManager.clearCachedInstruments(targetName);
            end
            this.App.UpdateApp.ForTargetApplicationLoaded(targetName,applicationName,...
            'StopTime',event.StopTime);
            notify(this.App.TargetManager,'targetChangeEvent')

            target=this.App.TargetManager.getTargetFromMap(targetName);




            if event.IsReloadOnStop&&(~isempty(target.instruments.streamed))
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                try
                    if this.App.SignalsTab.MonitorModeButton.Value
                        tg.addInstrument(target.instruments.streamed);
                    end
                    tg.addInstrument(target.instruments.duplicate);
                catch ME

                    try
                        tg.removeInstrument(target.instruments.streamed);
                        tg.removeInstrument(target.instruments.duplicate);
                    catch
                    end
                    delete(target.instruments.streamed);
                    target.instruments.streamed=[];
                    this.App.TargetManager.targetMap(targetName)=target;



                    this.App.UpdateApp.adjustInstrumentButtons(target);
                    huifig=this.App.UpdateApp.getShowingUIFigure();
                    if isempty(huifig)
                        huifig=this.App.SignalsPanel.UIFigure;
                    end
                    uialert(huifig,ME.message,message('slrealtime:explorer:error').getString());
                end
            end



            if isempty(target.node.Children)||...
                (~any(strcmp(arrayfun(@(x)x.NodeData.appName,target.node.Children,'UniformOutput',false),applicationName)))
                n=uitreenode(target.node);
                n.NodeData=slrealtime.internal.guis.TCMTreeNodeData.createAppTreeNodeData(targetName,applicationName);
                n.Icon=this.App.Icons.mldatxIcon;
                n.Text=this.App.TargetsTree.getTreeNodeTextForApplication(applicationName,targetName);


                target=this.App.TargetManager.updateStartupAppInMap(targetName);
                this.App.TargetManager.applyContextMenuToTargetsTreeAppNode(n,strcmp(applicationName,target.startupApp.appName));
            end
            target.node.collapse();



            this.App.TargetConfiguration.updateApplicationUITable();





            if~isempty(this.App.TargetManager.progressDlg)
                drawnow;
                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=[];
            end
        end

        function targetApplicationStarted(this,src,event)




            targetName=src.TargetSettings.name;
            this.App.UpdateApp.ForTargetApplicationStatus(targetName);
            notify(this.App.TargetManager,'targetChangeEvent')





            if~isempty(this.App.TargetManager.progressDlg)
                drawnow;
                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=[];
            end
        end

        function targetApplicationStopped(this,src,~)




            targetName=src.TargetSettings.name;
            this.App.UpdateApp.ForTargetApplicationStatus(targetName);
            notify(this.App.TargetManager,'targetChangeEvent')





            if~isempty(this.App.TargetManager.progressDlg)&&...
                strcmp(this.App.TargetManager.progressDlg.Title,...
                getString(message('slrealtime:explorer:stoppingApplicationOnTargetComputer')))
                drawnow;
                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=[];
            end
        end

        function targetStopTime(this,src,evnt)



            srcTargetName=src.TargetSettings.name;
            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            if~strcmp(srcTargetName,selectedTargetName)
                return;
            end
            this.App.TargetManager.StopTimeField.Value=num2str(evnt.stoptime);
        end

        function targetParamChanged(this,src,evnt)
            if this.App.ParametersTab.EnableParamTableButton.Visible






                return;
            end








            paramNameLevels=split(evnt.paramName,'.');
            [paramName,~]=slrealtime.internal.guis.Explorer.StaticUtils.parseForIndex(paramNameLevels{1});


            updateParamValuesCache(evnt.blockPath,paramName);


            this.locUpdateParametersTable(evnt.paramName,evnt.value,evnt.blockPath,paramName);




            function updateParamValuesCache(blockPath,paramName)
                target=this.App.TargetManager.getTargetFromMap(src.TargetSettings.name);
                key=slrealtime.internal.guis.Explorer.StaticUtils.convertToParamValuesCacheKey(blockPath,paramName);
                if target.Application.paramValues.isKey(key)
                    target.Application.paramValues.remove(key);
                end
            end
        end

        function targetParamSetChanged(this,src,evnt)
            if this.App.ParametersTab.EnableParamTableButton.Visible






                return;
            end
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(src.TargetSettings.name);
            if~isequal(evnt.Page,tg.getECUPage())




                return;
            end


            clearParamValuesCache();


            for k=1:length(evnt.BlockPath)



                this.locUpdateParametersTable(evnt.ParamName{k},evnt.Value{k},evnt.BlockPath{k},evnt.ParamName{k});
            end




            function clearParamValuesCache()
                target=this.App.TargetManager.getTargetFromMap(src.TargetSettings.name);
                target.Application.paramValues=containers.Map('KeyType','char','ValueType','any');
                this.App.TargetManager.targetMap(src.TargetSettings.name)=target;
            end
        end

        function targetReachedStopTime(this,src,~)




            this.App.UpdateApp.ForTargetApplicationStatus(src.Settings.Name);
            notify(this,'targetChangeEvent')
        end

        function targetAdded(this,~,evnt)



            this.App.TargetManager.addTarget(evnt.name);
        end

        function targetRemoved(this,~,evnt)



            this.App.TargetManager.removeTarget(evnt.name);
        end

        function targetRenamed(this,~,evnt)




            this.App.TargetManager.renameTarget(evnt.oldName,evnt.newName);
        end

        function targetDynamicSignalsChanged(this,~,~,targetName)





            notify(this.App.TargetManager,'dynamicSignalsChangeEvent');
        end

        function targetUpdateProgressDlgMessage(this,~,evnt)











            if~isempty(this.App.TargetConfiguration.RebootProgressDlg)
                this.App.TargetConfiguration.RebootProgressDlg.Message=evnt.message;
                switch evnt.message
                case message('slrealtime:target:updatingFile',...
                    message('slrealtime:target:bootImage').getString).getString
                    value=0.1;
                case message('slrealtime:target:updatingFile',...
                    message('slrealtime:target:slrtFiles').getString).getString
                    value=1/4;
                case message('slrealtime:target:updatingFile',...
                    message('slrealtime:target:qnxTools').getString).getString
                    value=2/4;
                case message('slrealtime:target:updateRestart').getString
                    value=3/4;
                otherwise
                    assert(false,'Explorer needs to update ''UpdateMessage'' event callback.');
                end
                this.App.TargetConfiguration.RebootProgressDlg.Value=value;
            end
        end

        function targetUpdateCompleted(this,src,~)




            this.App.TargetConfiguration.clearUpdateListeners;

            if~isempty(this.App.TargetConfiguration.RebootProgressDlg)
                delete(this.App.TargetConfiguration.RebootProgressDlg);
                this.App.TargetConfiguration.RebootProgressDlg=[];
            end

            msg=message(this.App.Messages.configureTargetComputerSoftwareUpToDateMsgId,src.TargetSettings.name);
            title=message(this.App.Messages.configureTargetComputerSoftwareMsgId);
            uiconfirm(this.App.TargetConfiguration.UIFigure,...
            msg.getString(),title.getString(),'Icon','success','Options',{getString(message('MATLAB:uitools:uidialogs:OK'))});
        end

        function targetUpdateFailed(this,~,~)




            this.App.TargetConfiguration.clearUpdateListeners;

            if~isempty(this.App.TargetConfiguration.RebootProgressDlg)
                delete(this.App.TargetConfiguration.RebootProgressDlg);
                this.App.TargetConfiguration.RebootProgressDlg=[];
            end



        end

        function targetUpdateReboot(this,src,evnt)




            this.App.TargetConfiguration.clearUpdateListeners;


            startTime=tic;
            pause(1);
            timeoutVal=240;
            timeout=true;
            while toc(startTime)<timeoutVal

                if~isempty(this.App.TargetConfiguration.RebootProgressDlg)
                    this.App.TargetConfiguration.RebootProgressDlg.Value=...
                    3/4+(1/4)*(toc(startTime)/timeoutVal);
                end

                if ispc
                    cmd=['ping -n 1 ',src.TargetSettings.address];
                else
                    cmd=['ping -c 1 ',src.TargetSettings.address];
                end
                [status,result]=system(cmd);
                if~status&&contains(result,'TTL','IgnoreCase',true)
                    timeout=false;
                    break;
                end
                pause(2);
            end
            if timeout
                msg=message(this.App.Messages.configureTargetComputerSoftwareNotAliveMsgId,src.TargetSettings.name,timeoutVal);
                title=message(this.App.Messages.configureTargetComputerSoftwareMsgId);

                uialert(this.App.UpdateApp.getShowingUIFigure(),msg.getString(),title.getString());
            else
                this.targetUpdateCompleted(src,evnt);
            end

            if~isempty(this.App.TargetConfiguration.RebootProgressDlg)
                delete(this.App.TargetConfiguration.RebootProgressDlg);
                this.App.TargetConfiguration.RebootProgressDlg=[];
            end
        end


        function targetRebootIssued(this,src,~)




            this.App.TargetConfiguration.clearRebootListener();


            startTime=tic;
            pause(1);
            timeoutVal=240;
            timeout=true;
            while toc(startTime)<timeoutVal

                if~isempty(this.App.TargetConfiguration.RebootProgressDlg)
                    this.App.TargetConfiguration.RebootProgressDlg.Value=...
                    toc(startTime)/timeoutVal;
                end

                if ispc
                    cmd=['ping -n 1 ',src.TargetSettings.address];
                else
                    cmd=['ping -c 1 ',src.TargetSettings.address];
                end
                [status,result]=system(cmd);
                if~status&&contains(result,'TTL','IgnoreCase',true)
                    timeout=false;
                    break;
                end
                pause(2);
            end
            title=message(this.App.Messages.targetComputerRebootMsgId);
            if timeout
                msg=message(this.App.Messages.targetComputerRebootNotAliveMsgId,src.TargetSettings.name,timeoutVal);

                uialert(this.App.UpdateApp.getShowingUIFigure(),msg.getString(),title.getString());
            else
                msg=message(this.App.Messages.targetComputerRebootSuccessMsgId,src.TargetSettings.name);

                uiconfirm(this.App.TargetConfiguration.UIFigure,...
                msg.getString(),title.getString(),'Icon','success','Options',{getString(message('MATLAB:uitools:uidialogs:OK'))});
            end

            if~isempty(this.App.TargetConfiguration.RebootProgressDlg)
                delete(this.App.TargetConfiguration.RebootProgressDlg);
                this.App.TargetConfiguration.RebootProgressDlg=[];
            end
        end

        function targetIPAddress(this,src,evnt)



            this.App.TargetConfiguration.clearIpAddrChangedListener();

            if~isempty(this.App.TargetManager)&&~isempty(this.App.TargetManager.progressDlg)
                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=[];
            end
        end

        function targetStartupAppChanged(this,src,~)
            targetName=src.TargetSettings.name;
            target=this.App.TargetManager.getTargetFromMap(targetName);
            target.startupApp.appName=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTStartupAppName(targetName);
            target.startupApp.isSet=true;
            this.App.TargetManager.targetMap(targetName)=target;
            this.App.TargetConfiguration.updateGUIForApplicationStartup(target.startupApp.appName,targetName);





            if~isempty(this.App.TargetManager.progressDlg)
                drawnow;
                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=[];
            end
        end

        function targetSettingsChanged(this,~,evnt)
            this.App.UpdateApp.TargetConfigurationForTargetSettings(evnt.AffectedObject.name);


            if strcmp(this.App.TargetManager.getSelectedTargetName(),evnt.AffectedObject.name)

                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(evnt.AffectedObject.name);
                this.App.TargetConfiguration.updateDiskUsageProgressBar(tg);
            end
        end

        function RecordingStatusChanged(this,~,evnt)



            if strcmpi(evnt.EventName,'RecordingStopped')
                this.App.TargetManager.RecordingControlButton.Icon=this.App.Icons.startRecordingIcon;
                this.App.TargetManager.RecordingControlButton.Text=getString(message('slrealtime:explorer:startRecording'));
                this.App.TargetManager.RecordingControlButton.Description=getString(message('slrealtime:explorer:startRecordingDescription'));
            else
                this.App.TargetManager.RecordingControlButton.Icon=this.App.Icons.stopRecordingIcon;
                this.App.TargetManager.RecordingControlButton.Text=getString(message('slrealtime:explorer:stopRecording'));
                this.App.TargetManager.RecordingControlButton.Description=getString(message('slrealtime:explorer:stopRecordingDescription'));
            end
            this.App.StatusBar.recordingStatusChanged();
        end

        function defaultTargetChanged(this,~,evnt)
            this.App.UpdateApp.TargetConfigurationForDefaultTarget(evnt.newName);
        end

        function modelStateChanged(this,src,evnt,varargin)
            targetName=varargin{1};
            this.App.StatusBar.modelStateChanged(src,evnt,targetName);
        end

        function execTimeChanged(this,src,evnt,varargin)
            targetName=varargin{1};
            this.App.StatusBar.execTimeChanged(src,evnt,targetName);
        end

        function targetCalPageChanged(this,src,evnt)
            srcTargetName=src.TargetSettings.name;
            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            if~strcmp(srcTargetName,selectedTargetName)
                return;
            end


            this.App.ParametersTab.ParametersTable.Enable='off';
            this.App.ParametersTab.ParametersTable.Tooltip=...
            getString(message('slrealtime:explorer:paramTableDisabledDueToPageSwitching'));
            this.App.TargetManager.HoldUpdatesButton.Enabled=false;


            this.App.TargetManager.HoldUpdatesButton.Value=false;
            this.App.TargetManager.HoldUpdatesButton.Enabled=false;
            this.App.TargetManager.UpdateParamsButton.Enabled=false;


            data=this.App.ParametersTab.ParametersTable.Data(:,3:5);
            this.App.ParametersTab.ParametersTable.Data(:,3:5)=cell(size(data));


            this.App.ParametersTab.ParametersTable.Selection=[];
            this.App.ParametersTab.HighlightParameterInModelButton.Enable='off';
            this.App.ParametersTab.HighlightParameterInModelButton.Tooltip='';


            this.App.ParametersTab.RefreshParamValuesButton.Enable='off';
            this.App.ParametersTab.RefreshParamValuesButton.Tooltip='';


            this.App.ParametersTab.EnableParamTableButton.Visible='on';
        end

    end




    methods(Access=private,Hidden=true)
        function locUpdateParametersTable(this,evntParamName,evntValue,evntBlockPath,paramName)


















            if isempty(this.App.ParametersTab.ParametersTable.Data)
                return;
            end
            blkpaths=this.App.ParametersTab.ParametersTable.Data(:,1);
            paramnames=this.App.ParametersTab.ParametersTable.Data(:,2);
            types=this.App.ParametersTab.ParametersTable.Data(:,4);



            blockPath=slrealtime.internal.guis.Explorer.StaticUtils.convertBlockPathsToDisplayString(evntBlockPath);




            idx=find(strcmp(regexprep(blkpaths,newline,' '),regexprep(blockPath,newline,' ')));
            idx2=find(strcmp(paramnames(idx),paramName));
            if~isempty(idx(idx2))
                if strcmp(evntParamName,paramName)
                    paramValue=evntValue;
                else
                    [~,ei]=regexp(evntParamName,['^',paramName]);
                    paramValue=this.App.ParametersTab.ParametersTable.UserData(idx(idx2)).value;
                    try



                        eval(['paramValue',evntParamName(ei+1:end),';']);
                    catch


                        return;
                    end
                    eval(['paramValue',evntParamName(ei+1:end),' = evntValue;']);
                end
                this.App.ParametersTab.ParametersTable.UserData(idx(idx2)).value=paramValue;

                try
                    dim=size(paramValue);
                    if(length(dim)>2)&&(length(dim)<5)




                    elseif(length(dim)>=5)




                    elseif strcmp(types(idx(idx2)),'struct')

                        if~isempty(this.App.ParametersTab.ValueEditor)&&isvalid(this.App.ParametersTab.ValueEditor.VarEditor)...
                            &&isequal(this.App.ParametersTab.ValueEditor.ParamName,paramnames{idx(idx2)})


                            this.App.ParametersTab.ValueEditor.updateParamValueInVarEditor(paramValue);
                        end
                    else

                        this.App.ParametersTab.ParametersTable.Data{idx(idx2),3}=mat2str(paramValue);
                    end
                catch
                    this.App.ParametersTab.ParametersTable.Data{idx(idx2),3}='<error getting value>';
                end
            end
        end
    end

end
