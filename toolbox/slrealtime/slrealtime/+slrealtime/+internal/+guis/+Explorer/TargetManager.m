classdef TargetManager<handle





    properties(Access=public)
TargetLabel
ConnectDisconnectButton
LoadApplicationButton
StartStopButton
StopTimeField
HoldUpdatesButton
UpdateParamsButton
ImportFileLogButton
RecordingControlButton
StartButtonReloadOnStopOption
StartButtonAutoImportFileLogOption

progressDlg
ImportUIFigure
LoadApplicationUIFigure
    end

    properties(Access=public,Hidden=true)
targetMap
    end


    properties(Access=private)
App

addTargetListener
removeTargetListener
defaultTargetListener
renameTargetListener

renameTargetOldName
    end

    events
targetChangeEvent
dynamicSignalsChangeEvent
    end



    methods
        function obj=TargetManager(hApp)

            obj.App=hApp;

            obj.targetMap=[];
            obj.progressDlg=[];
            obj.addTargetListener=[];
            obj.removeTargetListener=[];

            obj.setupTargetComputerManager();

        end

        function delete(this)





            if~isempty(this.targetMap)
                targetNames=this.targetMap.keys;
                for i=1:length(targetNames)
                    this.removeTarget(targetNames{i});
                end
            end


            delete(this.addTargetListener);
            delete(this.removeTargetListener);
            delete(this.defaultTargetListener);
            delete(this.renameTargetListener);


            delete(this.ImportUIFigure);
            this.ImportUIFigure=[];
            delete(this.LoadApplicationUIFigure);
            this.LoadApplicationUIFigure=[];
        end

        function enableTargetManager(this)
            this.ConnectDisconnectButton.Enabled=true;
            this.LoadApplicationButton.Enabled=true;
            this.StartStopButton.Enabled=true;
            this.StopTimeField.Enabled=true;
        end

        function disableTargetManager(this)
            this.ConnectDisconnectButton.Enabled=false;
            this.LoadApplicationButton.Enabled=false;
            this.StartStopButton.Enabled=false;
            this.StopTimeField.Enabled=false;
        end
    end



    methods(Access=public,Hidden=true)
        function selectedTargetName=getSelectedTargetName(this)



            selectedTargetName=this.TargetLabel.Text;
            if strcmp(selectedTargetName,'Manage Target Computers ...')
                selectedTargetName=[];
            end
        end

        function target=getTargetFromMap(this,targetName)



            if isempty(this.targetMap)||~this.targetMap.isKey(targetName)
                assert(false,message(this.App.Messages.noTargetMsgId,targetName));
            end
            target=this.targetMap(targetName);
        end

        function[target,performUpdate]=updateStartupAppInMap(this,targetName)

            target=this.getTargetFromMap(targetName);
            performUpdate=false;
            if(~target.startupApp.isSet)
                performUpdate=true;
                target.startupApp.appName=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTStartupAppName(targetName);
                target.startupApp.isSet=true;
                this.targetMap(targetName)=target;
            end
        end

        function tg=getTargetObject(this)
            targetName=this.getSelectedTargetName();

            if slrealtime.internal.guis.Explorer.StaticUtils.isSLRTTargetConnected(targetName)



                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
            else

                tg=[];
            end
        end
    end



    methods(Access=public,Hidden)


        function clearTargetApplicationCachedProperties(this,targetName)









            target=this.getTargetFromMap(targetName);
            if~isempty(target.Application)

                delete(target.Application.startListener);
                delete(target.Application.stopListener);
                delete(target.Application.stopTimeListener);
                delete(target.Application.paramChangedListener);
                delete(target.Application.paramSetChangedListener);
                delete(target.Application.calPageChangedListener);
                delete(target.Application.codeDescriptor);
                delete(target.Application.SLRTthis);
                target.Application.codeDescriptor=[];
                target.Application.SLRTthis=[];
                target.Application.codeDescFolder=[];
                target.Application=[];

                this.targetMap(targetName)=target;
            end
        end

        function clearCachedInstruments(this,targetName)









            target=this.getTargetFromMap(targetName);
            if~isempty(target.instruments)
                delete(target.instruments.pending);

                target.instruments=[];
                this.targetMap(targetName)=target;
            end
        end

        function treeNodeText=getTreeNodeTextForTarget(this,targetName)



            treeNodeText=targetName;
            if strcmp(targetName,slrealtime.internal.guis.Explorer.StaticUtils.getSLRTDefaultTargetName())
                msg=message(this.App.Messages.defaultMsgId);
                treeNodeText=[targetName,' (',msg.getString(),')'];
            end
        end

        function updateTreeNodeForApplication(this,targetName)





            connected=slrealtime.internal.guis.Explorer.StaticUtils.isSLRTTargetConnected(targetName);
            if connected

                target=this.getTargetFromMap(targetName);

                nc=target.node.Children;
                appsInNode=cell(length(nc),1);
                for i=1:length(nc)
                    appsInNode{i}=nc(i).NodeData.appName;
                end
                apps=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTInstalledApps(targetName);
                d1=setdiff(apps,appsInNode);
                d2=setdiff(appsInNode,apps);
                if~isempty(d1)
                    for i=1:length(d1)
                        n=uitreenode(target.node);
                        n.NodeData=slrealtime.internal.guis.TCMTreeNodeData.createAppTreeNodeData(targetName,d1{i});
                        n.Icon=this.App.Icons.mldatxIcon;
                        n.Text=this.App.TargetsTree.getTreeNodeTextForApplication(d1{i},targetName);


                        target=this.updateStartupAppInMap(targetName);
                        this.applyContextMenuToTargetsTreeAppNode(n,strcmp(d1{i},target.startupApp.appName));
                    end
                end
                if~isempty(d2)
                    idx=ismember(appsInNode,d2);
                    nc(idx).delete;
                end
                target.node.collapse();
            else



                this.App.TargetsTree.removeAllAppNodes(targetName);
            end
        end


        function addTarget(this,targetName)




            if isempty(this.targetMap)
                this.targetMap=containers.Map('KeyType','char','ValueType','any');
            end

            if this.targetMap.isKey(targetName)
                error(strcat('Target ''',targetName,''' already exists'));
            end



            node=uitreenode(this.App.TargetsTree.TargetComputersNode);
            node.NodeData=slrealtime.internal.guis.TCMTreeNodeData.createTargetTreeNodeData(targetName);
            node.Text=this.getTreeNodeTextForTarget(targetName);

            connected=slrealtime.internal.guis.Explorer.StaticUtils.isSLRTTargetConnected(targetName);


            startupAppName=[];
            startAppIsSet=false;
            if connected
                startupAppName=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTStartupAppName(targetName);
                startAppIsSet=true;
                apps=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTInstalledApps(targetName);
                for i=1:length(apps)
                    n=uitreenode(node);
                    n.NodeData=slrealtime.internal.guis.TCMTreeNodeData.createAppTreeNodeData(targetName,apps{i});
                    n.Icon=this.App.Icons.mldatxIcon;
                    this.applyContextMenuToTargetsTreeAppNode(n,strcmp(apps{i},startupAppName));











                    treeNodeText=apps{i};
                    if strcmp(apps{i},startupAppName)
                        msg=message(this.App.Messages.startupMsgId);
                        treeNodeText=[apps{i},' (',msg.getString(),')'];
                    end
                    n.Text=treeNodeText;
                end
                node.collapse();
            end






            warnings=containers.Map('KeyType','char','ValueType','any');































            if~warnings.isempty
                node.Icon=this.App.Icons.warningIcon;

            elseif connected
                node.Icon=this.App.Icons.connectedIcon;

            else
                node.Icon=this.App.Icons.disconnectedIcon;

            end










            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
            listeners=event.listener.empty;

            listeners(end+1)=addlistener(tg,'Connected',@(src,evnt)this.App.EventCallBack.targetConnected(src,evnt));
            listeners(end+1)=addlistener(tg,'Disconnected',@(src,evnt)this.App.EventCallBack.targetDisconnected(src,evnt));
            listeners(end+1)=addlistener(tg,'Installed',@(src,evnt)this.App.EventCallBack.targetApplicationInstalled(src,evnt));
            listeners(end+1)=addlistener(tg,'Loaded',@(src,evnt)this.App.EventCallBack.targetApplicationLoaded(src,evnt));
            listeners(end+1)=addlistener(tg,'StartupAppChanged',@(src,evnt)this.App.EventCallBack.targetStartupAppChanged(src,evnt));
            listeners(end+1)=addlistener(tg.TargetSettings,'address','PostSet',@(src,evnt)this.App.EventCallBack.targetSettingsChanged(src,evnt));
            listeners(end+1)=addlistener(tg,'RecordingStopped',@(src,evnt)this.App.EventCallBack.RecordingStatusChanged(src,evnt));
            listeners(end+1)=addlistener(tg,'RecordingStarted',@(src,evnt)this.App.EventCallBack.RecordingStatusChanged(src,evnt));
            if connected
                listeners(end+1)=addlistener(tg.get('tc'),'ModelState','PostSet',@(src,evnt)this.App.EventCallBack.modelStateChanged(src,evnt,targetName));
                listeners(end+1)=addlistener(tg.get('tc'),'ModelExecProperties','PostSet',@(src,evnt)this.App.EventCallBack.execTimeChanged(src,evnt,targetName));
            end

            filters=struct(...
            'signalsFilterContents','',...
            'parametersFilterContents','',...
            'currentSystemAndBelow',false...
            );

            tuning=struct(...
            'updatesOnHold',false,...
            'paramTableChanged',false...
            );
            startupApp=struct(...
            'isSet',startAppIsSet,...
            'appName',startupAppName);


            this.targetMap(targetName)=...
            struct(...
            'node',node,...
            'listeners',listeners,...
            'warnings',warnings,...
            'filters',filters,...
            'tuning',tuning,...
            'Application',[],...
            'startupApp',startupApp,...
            'systemLogViewer',[],...
            'instruments',[]...
            );
        end

        function addStatusBarListeners(this,targetName)

            connected=slrealtime.internal.guis.Explorer.StaticUtils.isSLRTTargetConnected(targetName);
            if connected
                target=this.getTargetFromMap(targetName);
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);

                modelStateCB=@(src,evnt)this.App.EventCallBack.modelStateChanged(src,evnt,targetName);
                execTimeCB=@(src,evnt)this.App.EventCallBack.execTimeChanged(src,evnt,targetName);
                if~any(cellfun(@(x)strcmp(func2str(modelStateCB),func2str(x)),{target.listeners.Callback}))
                    target.listeners(end+1)=addlistener(tg.get('tc'),'ModelState','PostSet',...
                    modelStateCB);
                end
                if~any(cellfun(@(x)strcmp(func2str(execTimeCB),func2str(x)),{target.listeners.Callback}))
                    target.listeners(end+1)=addlistener(tg.get('tc'),'ModelExecProperties','PostSet',...
                    execTimeCB);
                end

                this.targetMap(targetName)=target;
            end
        end


        function removeTarget(this,targetName)






            selectedTargetName=this.getSelectedTargetName();
            needsUpdate=strcmp(selectedTargetName,targetName);



            this.clearTargetApplicationCachedProperties(targetName);
            this.clearCachedInstruments(targetName);
            this.App.SystemLogTab.clearSystemLogViewerCachedProperties(targetName);

            target=this.getTargetFromMap(targetName);
            drawnow;
            delete(target.node);
            for i=1:length(target.listeners)
                delete(target.listeners(i));
            end

            this.targetMap.remove(targetName);



            try
                if needsUpdate
                    defaultTargetName=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTDefaultTargetName();
                    this.App.UpdateApp.ForSelectedTarget(defaultTargetName);
                end
            catch

            end
        end

        function renameTarget(this,targetName,newTargetName)






            selectedTargetName=this.getSelectedTargetName();
            selTargetRenamed=strcmp(selectedTargetName,targetName);



            target=this.getTargetFromMap(targetName);
            target.node.NodeData.targetName=newTargetName;
            target.node.Text=this.getTreeNodeTextForTarget(newTargetName);
            this.targetMap.remove(targetName);
            this.targetMap(newTargetName)=target;



            if selTargetRenamed

                this.App.UpdateApp.ForSelectedTarget(newTargetName);
            end
        end

        function applyContextMenuToTargetsTreeAppNode(this,appNode,isStartupApp)
            if~isa(appNode,'matlab.ui.container.TreeNode')
                return;
            end

            targetName=appNode.NodeData.targetName;
            appName=appNode.NodeData.appName;

            cm=uicontextmenu(ancestor(appNode,'figure'));
            m1=uimenu(cm,'Text',message('slrealtime:explorer:load').getString(),...
            'MenuSelectedFcn',@(src,event)this.MenuSelectedLoadCB(src,event,targetName,appName));
            m1.Tag="loadMenu";
            m2=uimenu(cm,'Text',message('slrealtime:explorer:runOnStartup').getString(),...
            'Checked',isStartupApp,...
            'MenuSelectedFcn',@(src,event)this.MenuSelectedRunOnStartupCB(src,event,targetName,appName));
            m2.Tag="runOnStartupMenu";
            m3=uimenu(cm,'Text',message('slrealtime:explorer:properties').getString(),...
            'MenuSelectedFcn',@(src,event)this.MenuSelectedPropertiesCB(src,event,targetName,appName));
            m3.Tag="propertiesMenu";
            m4=uimenu(cm,'Text',message('slrealtime:explorer:delete').getString(),...
            'MenuSelectedFcn',@(src,event)this.MenuSelectedDeleteCB(src,event,targetName,appName));
            m4.Tag="deleteMenu";
            appNode.ContextMenu=cm;
        end

    end



    methods(Access=public,Hidden)




        function path=getPathForApplicationNodeWork(app,node,path)
            if strcmp(node.Type,'uitree')
                return;
            else
                nodeText=node.Text;
                if strcmp(node.Icon,app.App.Icons.modelrefIcon)
                    idxs=strfind(nodeText,' (');
                    nodeText=nodeText(1:idxs(end));
                end

                if isempty(path)
                    path=nodeText;
                else
                    path=strcat(nodeText,'/',path);
                end
                path=app.getPathForApplicationNodeWork(node.Parent,path);
            end
        end

        function path=getPathForApplicationNode(app,node)






            path='';
            if isempty(node)
                return;
            end
            path=app.getPathForApplicationNodeWork(node,path);
        end
    end



    methods(Access=public,Hidden)





        function ConnectDisconnectButtonPushed(this,ConnectDisconnectButton,event)
            selectedTargetName=this.getSelectedTargetName();
            try
                if strcmp(this.ConnectDisconnectButton.Icon.Description,this.App.Icons.disconnectedIcon)



                    msg1=message(this.App.Messages.connectingMsgId);
                    msg2=message(this.App.Messages.connectingTargetComputerMsgId);

                    this.progressDlg=uiprogressdlg(this.App.UpdateApp.getShowingUIFigure(),...
                    'Indeterminate','on',...
                    'Message',msg1.getString(),...
                    'Title',msg2.getString());

                    tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
                    tg.connect;
                else



                    msg1=message(this.App.Messages.disconnectingMsgId);
                    msg2=message(this.App.Messages.disconnectingTargetComputerMsgId);
                    this.progressDlg=uiprogressdlg(this.App.UpdateApp.getShowingUIFigure(),...
                    'Indeterminate','on',...
                    'Message',msg1.getString(),...
                    'Title',msg2.getString());
                    tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
                    tg.disconnect;
                end
            catch ME
                if~isempty(this.progressDlg)
                    delete(this.progressDlg);
                    this.progressDlg=[];
                end

                msg=[];
                if~isempty(ME.cause)&&strcmp(ME.cause{1}.identifier,'slrealtime:target:versionMismatch')


                    res=tg.executeCommand('ver --json');
                    info=jsondecode(res.Output);

                    hostMatlabVer=['R',version('-release')];
                    installedSupportPackages=matlabshared.supportpkg.getInstalled;
                    if~isempty(installedSupportPackages)
                        idx=strcmpi('Simulink Real-Time Target Support Package',...
                        {installedSupportPackages.Name});
                        hostSupportPackageVer=installedSupportPackages(idx).InstalledVersion;
                    else
                        hostSupportPackageVer=[];
                    end

                    if~isequal(hostMatlabVer,info.slrttools_release)
                        msgSub=message(this.App.Messages.slrtVersionMismatchMsgID,...
                        info.slrttools_release,hostMatlabVer);
                        msg=[msg,newline,msgSub.getString()];
                    end
                    if~isequal(hostSupportPackageVer,info.qnxtools_version)
                        if isempty(hostSupportPackageVer)
                            msgSub=message(this.App.Messages.supportPkgVersionMismatch1MsgId,...
                            info.qnxtools_version);
                            msg=[msg,newline,msgSub.getString()];
                        else
                            msgSub=message(this.App.Messages.supportPkgVersionMismatch2MsgId,...
                            info.qnxtools_version,hostSupportPackageVer);
                            msg=[msg,newline,msgSub.getString()];
                        end
                    end



                    errorMsg=message('slrealtime:target:connectError',selectedTargetName,...
                    message(this.App.Messages.targetVersionMismatch).getString).getString;

                else
                    errorMsg=slrealtime.internal.replaceHyperlinks(ME.message);
                end

                if~isempty(msg)
                    uialert(this.App.UpdateApp.getShowingUIFigure(),[errorMsg,newline,msg],message('slrealtime:explorer:error').getString());
                else
                    uialert(this.App.UpdateApp.getShowingUIFigure(),errorMsg,message('slrealtime:explorer:error').getString());
                end
            end
        end


        function LoadApplicationButtonPushed(this,LoadApplicationButton,event)

            selectedTargetName=this.getSelectedTargetName();
            this.LoadApplicationUIFigure=...
            slrealtime.internal.guis.Explorer.LoadApplicationDialog(...
            this.App,...
            selectedTargetName,...
            @(loadFromTarget,name,pathname)this.FinishLoadApplicationButtonPushed(loadFromTarget,name,pathname));

        end

        function FinishLoadApplicationButtonPushed(this,loadFromTarget,name,pathname)

            this.App.App.bringToFront();

            msg1=message(this.App.Messages.loadingMsgId);
            msg2=message(this.App.Messages.loadingApplicationOnTargetComputerMsgId);
            this.progressDlg=uiprogressdlg(this.App.UpdateApp.getShowingUIFigure(),...
            'Indeterminate','on',...
            'Message',msg1.getString(),...
            'Title',msg2.getString());

            selectedTargetName=this.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
            if loadFromTarget
                try
                    tg.load(name,'SkipInstall',true);
                catch ME
                    if~isempty(this.progressDlg)
                        delete(this.progressDlg);
                        this.progressDlg=[];
                    end
                    uialert(this.App.UpdateApp.getShowingUIFigure(),ME.message,message('slrealtime:explorer:error').getString());
                end
            else
                try
                    tg.load(fullfile(pathname,name));
                catch ME
                    if~isempty(this.progressDlg)
                        delete(this.progressDlg);
                        this.progressDlg=[];
                    end

                    uialert(this.App.UpdateApp.getShowingUIFigure(),ME.message,message('slrealtime:explorer:error').getString());
                end
            end


            this.App.SignalsDocument.Showing=true;
        end


        function StartStopButtonPushed(this,StartStopButton,event)

            selectedTargetName=this.getSelectedTargetName();
            try
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
                if strcmp(this.StartStopButton.Icon.Description,this.App.Icons.runIcon)



                    msg1=message(this.App.Messages.startingMsgId);
                    msg2=message(this.App.Messages.startingApplicationOnTargetComputerMsgId);
                    this.progressDlg=uiprogressdlg(this.App.UpdateApp.getShowingUIFigure(),...
                    'Indeterminate','on',...
                    'Message',msg1.getString(),...
                    'Title',msg2.getString());
                    isReloadOnStop=this.StartButtonReloadOnStopOption.Value;
                    isAutoImportFileLog=this.StartButtonAutoImportFileLogOption.Value;
                    tg.start('ReloadOnStop',isReloadOnStop,'AutoImportFileLog',isAutoImportFileLog);
                else



                    msg1=message(this.App.Messages.stoppingMsgId);
                    msg2=message(this.App.Messages.stoppingApplicationOnTargetComputerMsgId);
                    this.progressDlg=uiprogressdlg(this.App.UpdateApp.getShowingUIFigure(),...
                    'Indeterminate','on',...
                    'Message',msg1.getString(),...
                    'Title',msg2.getString());
                    tg.stop;
                end
            catch ME
                if~isempty(this.progressDlg)
                    delete(this.progressDlg);
                    this.progressDlg=[];
                end

                uialert(this.App.UpdateApp.getShowingUIFigure(),ME.message,message('slrealtime:explorer:error').getString());
            end
        end

        function StopTimeFieldValueChanged(this,editfield,event)
            newStopTimeStr=this.StopTimeField.Value;

            selectedTargetName=this.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
            currStopTimeStr=num2str(tg.ModelStatus.StopTime);

            newStopTime=str2double(newStopTimeStr);
            if isnan(newStopTime)||~isreal(newStopTime)
                msg=message(this.App.Messages.invalidStopTimeMsgID);
                uialert(this.App.UpdateApp.getShowingUIFigure(),msg.getString(),message('slrealtime:explorer:error').getString(),'CloseFcn',@(~,~)this.setStopTimeValue(currStopTimeStr));
            else
                try
                    tg.setStopTime(newStopTime);
                catch ME
                    uialert(this.App.UpdateApp.getShowingUIFigure(),ME.message,message('slrealtime:explorer:error').getString(),'CloseFcn',@(~,~)this.setStopTimeValue(currStopTimeStr));
                end
            end
        end


        function HoldUpdatesButtonPushed(this,HoldUpdatesButton,event)
            selectedTargetName=this.getSelectedTargetName();
            target=this.getTargetFromMap(selectedTargetName);
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);


            pgs=[tg.getECUPage,tg.getXCPPage];

            if this.HoldUpdatesButton.Value==true

                this.UpdateParamsButton.Enabled=true;
                target.tuning.updatesOnHold=true;


                if pgs(1)==0
                    pgs(2)=1;
                else
                    pgs(2)=0;
                end



                target.Application.calPageChangedListener.Enabled=false;



                tg.copyPage(pgs(1),pgs(2));
                tg.setXCPPage(pgs(2));
            else
                copyP=false;
                if target.tuning.paramTableChanged
                    select=uiconfirm(this.App.ParametersPanel.UIFigure,...
                    getString(message('slrealtime:explorer:batchOffParamTableChangedWarning')),...
                    getString(message('slrealtime:explorer:warning')),...
                    'Icon','warning',...
                    'Options',{getString(message('slrealtime:explorer:discardChanges')),getString(message('slrealtime:explorer:cancel'))});

                    if isequal(select,getString(message('slrealtime:explorer:cancel')))
                        this.HoldUpdatesButton.Value=true;
                        return;
                    else
                        copyP=true;
                    end
                end


                tg.setXCPPage(pgs(1));



                if copyP
                    tg.copyPage(pgs(1),pgs(2));



                    target.Application.paramValues=containers.Map('KeyType','char','ValueType','any');
                    this.targetMap(selectedTargetName)=target;


                    params=this.App.ParametersTab.ParametersTable.UserData;
                    blkpaths=this.App.ParametersTab.ParametersTable.Data(:,1);
                    [valStrs,types,dims,vals]=...
                    this.App.UpdateApp.getSLRTTargetParameterValues(selectedTargetName,params,blkpaths);

                    [params.value]=vals{:};
                    this.App.ParametersTab.ParametersTable.UserData=params;
                    this.App.ParametersTab.ParametersTable.Data(:,3:5)=[valStrs,types,dims];


                    if~isempty(this.App.ParametersTab.ValueEditor)&&isvalid(this.App.ParametersTab.ValueEditor.VarEditor)

                        paramValue=params(strcmp(this.App.ParametersTab.ValueEditor.ParamName,{params.BlockParameterName})).value;
                        this.App.ParametersTab.ValueEditor.updateParamValueInVarEditor(paramValue);
                    end

                    target.tuning.paramTableChanged=false;
                end


                this.UpdateParamsButton.Enabled=false;
                target.tuning.updatesOnHold=false;


                this.App.ParametersTab.ParametersTable.Enable='on';


                cleanup=onCleanup(@()this.locEnableListener(target.Application.calPageChangedListener));
                clear cleanup
            end

            this.targetMap(selectedTargetName)=target;
        end

        function locEnableListener(this,evtLis)

            evtLis.Enabled=true;
        end


        function UpdateParamsButtonPushed(this,UpdateParamsButton,event)
            selectedTargetName=this.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);


            pgs=[tg.getECUPage,tg.getXCPPage];


            tg.setECUPage(pgs(2));


            tg.copyPage(pgs(2),pgs(1));


            tg.setXCPPage(pgs(1));

            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
            target.tuning.paramTableChanged=false;

            this.App.TargetManager.targetMap(selectedTargetName)=target;
        end

        function ImportFileLogButtonPushed(this,varargin)
            this.ImportUIFigure=slrealtime.internal.guis.Explorer.ImportFileLogDialog(this.App);
        end

        function RecordingControlButtonPushedFcn(this,varargin)
            selectedTargetName=this.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
            try
                if tg.get('Recording')
                    tg.stopRecording();
                else
                    tg.startRecording();
                end
            catch ME
                rethrow(ME);
            end
        end

        function MenuSelectedRunOnStartupCB(this,src,event,targetName,appName)

            if strcmp(src.Checked,'off')
                src.Checked='on';
            else
                src.Checked='off';
            end

            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);

            msg=message(this.App.Messages.configuringMsgId);
            title=message(this.App.Messages.configureRunOnStartupMsgId);
            this.progressDlg=uiprogressdlg(this.App.UpdateApp.getShowingUIFigure(),...
            'Indeterminate','on',...
            'Message',msg.getString(),...
            'Title',title.getString());

            try
                if src.Checked
                    tg.setStartupApp(appName,'SkipInstall',true);
                else
                    tg.clearStartupApp;
                end
            catch ME
                if~isempty(this.progressDlg)
                    delete(this.progressDlg);
                    this.progressDlg=[];
                end

                uialert(this.App.UpdateApp.getShowingUIFigure(),ME.message,message('slrealtime:explorer:error').getString());
            end
        end

        function MenuSelectedLoadCB(this,src,event,targetName,appName)

            msg1=message(this.App.Messages.loadingMsgId);
            msg2=message(this.App.Messages.loadingApplicationOnTargetComputerMsgId);
            this.progressDlg=uiprogressdlg(this.App.UpdateApp.getShowingUIFigure(),...
            'Indeterminate','on',...
            'Message',msg1.getString(),...
            'Title',msg2.getString());

            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);

            try
                tg.load(appName,'SkipInstall',true);
            catch ME
                if~isempty(this.progressDlg)
                    delete(this.progressDlg);
                    this.progressDlg=[];
                end
                uialert(this.App.UpdateApp.getShowingUIFigure(),ME.message,message('slrealtime:explorer:error').getString());
            end

            if strcmp(this.getSelectedTargetName(),targetName)

                this.App.SignalsDocument.Showing=true;
            end
        end

        function MenuSelectedPropertiesCB(this,src,event,targetName,appName)
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
            slrealtime.internal.guis.Explorer.AppPropertiesDialogWrapper.open(this.App,appName,tg);
        end

        function MenuSelectedDeleteCB(this,src,event,targetName,appName)
            msg=message('slrealtime:explorer:deleteAppPrompt1',appName);
            title=message('slrealtime:explorer:deleteAppConfirm');

            uiconfirm(this.App.UpdateApp.getShowingUIFigure(),...
            msg.getString(),title.getString(),...
            'CloseFcn',@(o,e)this.App.TargetConfiguration.appDeleteConfirmCloseFcn(o,e,targetName,{appName}));
        end

    end



    methods(Access=private)


        function setupTargetComputerManager(this)



            TabGroup=this.App.App.getTabGroup("ExplorerTabGroup");
            TargetTab=TabGroup.getChildByTag("targetTab");

            section=TargetTab.getChildByTag("connectToTargetComputerSection");
            column=section.getChildByTag("connectToTargetComputerColumn");
            this.TargetLabel=column.getChildByTag("targetComputerLabel");
            this.ConnectDisconnectButton=column.getChildByTag("connectDisconnectButton");

            section=TargetTab.getChildByTag("prepareSection");
            column=section.getChildByTag("loadColumn");
            this.LoadApplicationButton=column.getChildByTag("loadApplicationButton");

            section=TargetTab.getChildByTag("runOnTargetSection");
            column=section.getChildByTag("startStopColumn");
            this.StartStopButton=column.getChildByTag("startStopButton");
            this.StartButtonReloadOnStopOption=this.StartStopButton.Popup.getChildByTag("startButtonReloadOnStop");
            this.StartButtonAutoImportFileLogOption=this.StartStopButton.Popup.getChildByTag("startButtonAutoImportFileLog");
            column=section.getChildByTag("stopTimeColumn");
            this.StopTimeField=column.getChildByTag("stopTimeField");

            section=TargetTab.getChildByTag("tuneParametersSection");
            column=section.getChildByTag("holdColumn");
            this.HoldUpdatesButton=column.getChildByTag("holdUpdatesButton");
            column=section.getChildByTag("updateParamColumn");
            this.UpdateParamsButton=column.getChildByTag("updateParamButton");

            section=TargetTab.getChildByTag("reviewResultsSection");
            column=section.getChildByTag("importFileLogColumn");
            this.ImportFileLogButton=column.getChildByTag("importFileLogButton");

            column=section.getChildByTag("recordingControlColumn");
            this.RecordingControlButton=column.getChildByTag("recordingControlButton");

            targets=slrealtime.Targets;
            targetNames=targets.getTargetNames;
            for i=1:length(targetNames)
                this.addTarget(targetNames{i});
            end



            this.App.TargetsTree.TargetComputersNode.NodeData=slrealtime.internal.guis.TCMTreeNodeData.createRootTreeNodeData();



            newNodes=[];
            nodes=this.App.TargetsTree.TargetComputersNode.Children;


            targetOrder=targetNames(:);
            for nTarget=1:length(targetOrder)
                idxs=strcmp(arrayfun(@(x)x.NodeData.targetName,nodes,'UniformOutput',false),targetOrder{nTarget});
                if any(idxs)
                    newNodes=[newNodes;nodes(idxs)];%#ok
                    nodes=nodes(~idxs);
                end
            end
            newNodes=[newNodes;nodes];
            this.App.TargetsTree.TargetComputersNode.Children=newNodes;





            this.addTargetListener=addlistener(targets,'AddedTarget',@(src,evnt)this.App.EventCallBack.targetAdded(src,evnt));
            this.removeTargetListener=addlistener(targets,'RemovedTarget',@(src,evnt)this.App.EventCallBack.targetRemoved(src,evnt));
            this.defaultTargetListener=addlistener(targets,'DefaultTargetChanged',@(src,evnt)this.App.EventCallBack.defaultTargetChanged(src,evnt));
            this.renameTargetListener=addlistener(targets,'TargetNameChanged',@(src,evnt)this.App.EventCallBack.targetRenamed(src,evnt));


            this.ConnectDisconnectButton.ButtonPushedFcn=@this.ConnectDisconnectButtonPushed;
            this.ConnectDisconnectButton.Icon=this.App.Icons.connectedIcon;


            this.LoadApplicationButton.ButtonPushedFcn=@this.LoadApplicationButtonPushed;


            this.StartStopButton.ButtonPushedFcn=@this.StartStopButtonPushed;
            this.StartStopButton.Icon=this.App.Icons.runIcon;
            this.StartStopButton.Description=getString(message('slrealtime:explorer:startButtonTooltip'));


            this.StopTimeField.ValueChangedFcn=@this.StopTimeFieldValueChanged;


            this.HoldUpdatesButton.ValueChangedFcn=@this.HoldUpdatesButtonPushed;


            this.UpdateParamsButton.ButtonPushedFcn=@this.UpdateParamsButtonPushed;


            this.ImportFileLogButton.ButtonPushedFcn=@this.ImportFileLogButtonPushed;


            this.RecordingControlButton.ButtonPushedFcn=@this.RecordingControlButtonPushedFcn;



            defaultTargetName=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTDefaultTargetName();
            this.TargetLabel.Text=defaultTargetName;

        end

        function setStopTimeValue(this,vStr)
            this.StopTimeField.Value=vStr;
        end
    end

end
