classdef TargetConfiguration<matlab.apps.AppBase





    properties(Access=public)
App
        UIFigure matlab.ui.Figure
        TopGridLayout matlab.ui.container.GridLayout
        GridLayout matlab.ui.container.GridLayout
        ApplicationGridLayout matlab.ui.container.GridLayout
        ButtonLayout matlab.ui.container.GridLayout
        AppButtonLayout matlab.ui.container.GridLayout
        UpdateSoftwareButton matlab.ui.control.Button
        ChangeIPAddressButton matlab.ui.control.Button
        RebootButton matlab.ui.control.Button
        NameEditFieldLabel matlab.ui.control.Label
        NameEditField matlab.ui.control.EditField
        IPaddressEditFieldLabel matlab.ui.control.Label
        IPaddressEditField matlab.ui.control.EditField
        DefaultCheckBox matlab.ui.control.CheckBox
        DiskUsageLabel matlab.ui.control.Label
        DiskUsageProgressBarGrid matlab.ui.container.GridLayout
        DiskUsageProgressBarText matlab.ui.control.Label
        DiskUsageProgressBar matlab.ui.control.internal.ProgressIndicator
        DiskUsageUpdateButtonGrid matlab.ui.container.GridLayout
        DiskUsageUpdateButton matlab.ui.control.Button
        ApplicationUITable matlab.ui.control.Table
        AppDeleteButton matlab.ui.control.Button
        AppPropertiesButton matlab.ui.control.Button
        AppUITableNameLabel matlab.ui.control.Label
    end

    properties(Access=public)
RebootProgressDlg
    end

    properties(Access=private)






updateMessageListener
updateCompletedListener
updateFailedListener
updateRebootListener






rebootListener







ipAddrChangedListener
    end


    methods(Access=public)


        function app=TargetConfiguration(hApp,huifigure)
            app.App=hApp;



            app.UIFigure=huifigure;
            app.UIFigure.Visible='off';


            app.createComponents();

            app.updateApplicationUITable();

        end


        function delete(app)

            app.clearUpdateListeners();
            app.clearRebootListener();
            app.clearIpAddrChangedListener();
        end
    end


    methods(Access=public,Hidden)

        function updateApplicationUITable(app)

            targetName=app.App.TargetManager.getSelectedTargetName();

            if slrealtime.internal.guis.Explorer.StaticUtils.isSLRTTargetConnected(targetName)

                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);

                target=app.App.TargetManager.getTargetFromMap(targetName);
                applicationNodes=target.node.Children;
                data=cell(length(applicationNodes),5);

                target=app.App.TargetManager.updateStartupAppInMap(targetName);
                startupApp=target.startupApp.appName;

                rowToDelete=[];
                for i=1:length(applicationNodes)
                    n=applicationNodes(i);
                    appName=n.NodeData.appName;

                    filename=getAppFile(tg,appName);
                    if~isempty(filename)
                        appObj=slrealtime.Application(filename);
                        appInfo=appObj.getInformation;

                        isStartupApp=false;
                        if strcmp(appName,startupApp)
                            isStartupApp=true;
                        end

                        data(i,:)={appName,...
                        appInfo.ModelName,...
                        appInfo.ApplicationLastModifiedDate,...
                        appInfo.ModelLastModifiedDate,...
                        isStartupApp};
                    else

















                        delete(n);
                        rowToDelete=[rowToDelete,i];
                    end
                end
                data(rowToDelete,:)=[];
                app.ApplicationUITable.Data=data;
                app.ApplicationUITable.Enable='on';

                if isempty(app.ApplicationUITable.Selection)
                    app.AppDeleteButton.Enable='off';
                    app.AppPropertiesButton.Enable='off';
                else
                    appNum=size(app.ApplicationUITable.Data,1);
                    if any(appNum<app.ApplicationUITable.Selection)
                        app.ApplicationUITable.Selection=[];
                        app.AppDeleteButton.Enable='off';
                        app.AppPropertiesButton.Enable='off';
                    else
                        app.AppDeleteButton.Enable='on';
                        app.AppPropertiesButton.Enable='on';
                    end
                end
            else



                app.ApplicationUITable.Data=[];


                app.ApplicationUITable.Enable='off';


                app.AppDeleteButton.Enable='off';
                app.AppPropertiesButton.Enable='off';

            end

        end

        function clearUpdateListeners(app)

            if~isempty(app.updateMessageListener)
                delete(app.updateMessageListener);
                app.updateMessageListener=[];
            end
            if~isempty(app.updateCompletedListener)
                delete(app.updateCompletedListener);
                app.updateCompletedListener=[];
            end
            if~isempty(app.updateFailedListener)
                delete(app.updateFailedListener);
                app.updateFailedListener=[];
            end
            if~isempty(app.updateRebootListener)
                delete(app.updateRebootListener);
                app.updateRebootListener=[];
            end
        end

        function clearRebootListener(app)

            if~isempty(app.rebootListener)
                delete(app.rebootListener);
                app.rebootListener=[];
            end
        end

        function clearIpAddrChangedListener(app)

            if~isempty(app.ipAddrChangedListener)
                delete(app.ipAddrChangedListener);
                app.ipAddrChangedListener=[];
            end
        end

        function updateGUIForApplicationStartup(app,~,targetName)




            selectedTargetName=app.App.TargetManager.getSelectedTargetName();
            isSelectedTarget=strcmp(selectedTargetName,targetName);
            if isSelectedTarget
                data=app.ApplicationUITable.Data;
            end
            target=app.App.TargetManager.updateStartupAppInMap(targetName);
            startupApp=target.startupApp.appName;







            for i=1:length(target.node.Children)

                appName=target.node.Children(i).NodeData.appName;
                target.node.Children(i).Text=app.App.TargetsTree.getTreeNodeTextForApplication(appName,targetName);



                if isSelectedTarget
                    data{i,5}=strcmp(startupApp,appName);
                end



                runOnStartupMenu=target.node.Children(i).ContextMenu.findobj('Tag',"runOnStartupMenu");
                runOnStartupMenu.Checked=strcmp(startupApp,appName);
            end




            if isSelectedTarget
                app.ApplicationUITable.Data=data;
            end
        end

        function appDeleteConfirmCloseFcn(app,~,event,targetName,appNames)
            if strcmp(event.SelectedOption,'OK')
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                for k=1:length(appNames)
                    appName=appNames{k};
                    try
                        tg.removeApplication(appName);
                    catch ME
                        uialert(app.App.UpdateApp.getShowingUIFigure(),ME.message,message('slrealtime:explorer:error').getString());
                    end
                end

                app.App.TargetManager.updateTreeNodeForApplication(targetName);
                app.updateApplicationUITable();

                app.ApplicationUITable.Selection=[];
                app.AppDeleteButton.Enable='off';
                app.AppPropertiesButton.Enable='off';
            end
        end

        function updateDiskUsageProgressBar(app,tg)







            if~isempty(tg)&&tg.isConnected
                try
                    sshCmd=strcat("df -h /");
                    res=tg.executeCommand(sshCmd);
                    sizestr=split(res.Output);
                    sizestr=sizestr(~cellfun('isempty',sizestr));
                    pctstr=regexp(sizestr{5},'\d*','match');

                    app.DiskUsageProgressBarText.Text=getString(message('slrealtime:explorer:usedOf',sizestr{5},sizestr{2}));
                    app.DiskUsageProgressBar.Value=str2double(pctstr{1})/100;
                catch
                    app.DiskUsageProgressBarText.Text=getString(message('slrealtime:explorer:connectToSeeDiskUsage'));
                    app.DiskUsageProgressBar.Value=0;
                end
            else
                app.DiskUsageProgressBarText.Text=getString(message('slrealtime:explorer:connectToSeeDiskUsage'));
                app.DiskUsageProgressBar.Value=0;
            end
        end

    end


    methods(Access=private)


        function createComponents(app)


            app.TopGridLayout=uigridlayout(app.UIFigure);
            app.TopGridLayout.ColumnWidth={'1x'};
            app.TopGridLayout.RowHeight={5,205,'1x',5};


            app.GridLayout=uigridlayout(app.TopGridLayout);
            app.GridLayout.ColumnWidth={150,340,100,'1x'};
            app.GridLayout.RowHeight={25,25,25,10,70,'1x'};
            app.GridLayout.Layout.Row=2;
            app.GridLayout.Layout.Column=1;


            app.ApplicationGridLayout=uigridlayout(app.TopGridLayout);
            app.ApplicationGridLayout.ColumnWidth={'1x'};
            app.ApplicationGridLayout.RowHeight={25,'1x',25};
            app.ApplicationGridLayout.Layout.Row=3;
            app.ApplicationGridLayout.Layout.Column=1;


            app.ButtonLayout=uigridlayout(app.GridLayout);
            app.ButtonLayout.ColumnWidth={'1x','10x','10x','10x','1x'};
            app.ButtonLayout.RowHeight={'1x'};
            app.ButtonLayout.RowSpacing=1;
            app.ButtonLayout.Padding=[1,1,1,1];
            app.ButtonLayout.Layout.Row=5;
            app.ButtonLayout.Layout.Column=2;


            app.AppButtonLayout=uigridlayout(app.ApplicationGridLayout);
            app.AppButtonLayout.ColumnWidth={'1x',100,100};
            app.AppButtonLayout.RowHeight={'1x'};
            app.AppButtonLayout.RowSpacing=1;
            app.AppButtonLayout.Padding=[1,1,1,1];
            app.AppButtonLayout.Layout.Row=3;
            app.AppButtonLayout.Layout.Column=1;


            app.UpdateSoftwareButton=uibutton(app.ButtonLayout,'push');
            app.UpdateSoftwareButton.Layout.Row=1;
            app.UpdateSoftwareButton.Layout.Column=2;
            app.UpdateSoftwareButton.Text=getString(message(app.App.Messages.updateSoftwareButtonTextMsgId));
            app.UpdateSoftwareButton.Icon=app.App.Icons.updateIcon;
            app.UpdateSoftwareButton.IconAlignment='top';
            app.UpdateSoftwareButton.Tooltip=getString(message(app.App.Messages.updateSoftwareTooltipMsgId));
            app.UpdateSoftwareButton.ButtonPushedFcn=createCallbackFcn(app,@UpdateSoftwareButtonPushed,true);


            app.ChangeIPAddressButton=uibutton(app.ButtonLayout,'push');
            app.ChangeIPAddressButton.Layout.Row=1;
            app.ChangeIPAddressButton.Layout.Column=3;
            app.ChangeIPAddressButton.Text=getString(message(app.App.Messages.changeIPAddressButtonTextMsgId));
            app.ChangeIPAddressButton.Icon=app.App.Icons.ipAddrIcon;
            app.ChangeIPAddressButton.IconAlignment='top';
            app.ChangeIPAddressButton.Tooltip=getString(message(app.App.Messages.changeIPAddressButtonTooltipMsgId));
            app.ChangeIPAddressButton.ButtonPushedFcn=createCallbackFcn(app,@ChangeIPAddrButtonPushed,true);


            app.RebootButton=uibutton(app.ButtonLayout,'push');
            app.RebootButton.Layout.Row=1;
            app.RebootButton.Layout.Column=4;
            app.RebootButton.Text=getString(message(app.App.Messages.rebootButtonTextMsgId));
            app.RebootButton.Icon=app.App.Icons.rebootIcon;
            app.RebootButton.IconAlignment='top';
            app.RebootButton.Tooltip=getString(message(app.App.Messages.rebootButtonTooltipMsgId));
            app.RebootButton.ButtonPushedFcn=createCallbackFcn(app,@RebootButtonPushed,true);


            app.NameEditFieldLabel=uilabel(app.GridLayout);
            app.NameEditFieldLabel.HorizontalAlignment='right';
            app.NameEditFieldLabel.Layout.Row=1;
            app.NameEditFieldLabel.Layout.Column=1;
            app.NameEditFieldLabel.Text=getString(message(app.App.Messages.nameMsgId));


            app.NameEditField=uieditfield(app.GridLayout,'text');
            app.NameEditField.ValueChangedFcn=createCallbackFcn(app,@NameEditFieldValueChanged,true);
            app.NameEditField.Layout.Row=1;
            app.NameEditField.Layout.Column=2;



            app.IPaddressEditFieldLabel=uilabel(app.GridLayout);
            app.IPaddressEditFieldLabel.HorizontalAlignment='right';
            app.IPaddressEditFieldLabel.Layout.Row=2;
            app.IPaddressEditFieldLabel.Layout.Column=1;
            app.IPaddressEditFieldLabel.Text=getString(message(app.App.Messages.ipAddressEditFieldLabelTextMsgId));


            app.IPaddressEditField=uieditfield(app.GridLayout,'text');
            app.IPaddressEditField.ValueChangedFcn=createCallbackFcn(app,@IPAddressEditFieldValueChanged,true);
            app.IPaddressEditField.Layout.Row=2;
            app.IPaddressEditField.Layout.Column=2;


            app.DefaultCheckBox=uicheckbox(app.GridLayout);
            app.DefaultCheckBox.ValueChangedFcn=createCallbackFcn(app,@DefaultCheckBoxValueChanged,true);
            app.DefaultCheckBox.Text=getString(message(app.App.Messages.defaultMsgId));
            app.DefaultCheckBox.Layout.Row=1;
            app.DefaultCheckBox.Layout.Column=3;
            app.DefaultCheckBox.Value=true;


            app.DiskUsageLabel=uilabel(app.GridLayout);
            app.DiskUsageLabel.HorizontalAlignment='right';
            app.DiskUsageLabel.Layout.Row=3;
            app.DiskUsageLabel.Layout.Column=1;
            app.DiskUsageLabel.Text=getString(message('slrealtime:explorer:diskUsage'));


            app.DiskUsageProgressBarGrid=uigridlayout(app.GridLayout);
            app.DiskUsageProgressBarGrid.ColumnWidth={'1x'};
            app.DiskUsageProgressBarGrid.RowHeight={'1x','0.25x'};
            app.DiskUsageProgressBarGrid.RowSpacing=0.1;
            app.DiskUsageProgressBarGrid.Padding=[0,0,0,0];
            app.DiskUsageProgressBarGrid.Layout.Row=3;
            app.DiskUsageProgressBarGrid.Layout.Column=2;


            app.DiskUsageProgressBarText=uilabel(app.DiskUsageProgressBarGrid);
            app.DiskUsageProgressBarText.HorizontalAlignment='center';
            app.DiskUsageProgressBarText.Layout.Row=1;
            app.DiskUsageProgressBarText.Layout.Column=1;



            app.DiskUsageProgressBar=matlab.ui.control.internal.ProgressIndicator('Parent',app.DiskUsageProgressBarGrid);
            app.DiskUsageProgressBar.Layout.Row=2;
            app.DiskUsageProgressBar.Layout.Column=1;


            app.DiskUsageUpdateButtonGrid=uigridlayout(app.GridLayout);
            app.DiskUsageUpdateButtonGrid.ColumnWidth={25,'1x'};
            app.DiskUsageUpdateButtonGrid.RowHeight={'1x'};
            app.DiskUsageUpdateButtonGrid.RowSpacing=0;
            app.DiskUsageUpdateButtonGrid.Padding=[0,0,0,0];
            app.DiskUsageUpdateButtonGrid.Layout.Row=3;
            app.DiskUsageUpdateButtonGrid.Layout.Column=3;


            app.DiskUsageUpdateButton=uibutton(app.DiskUsageUpdateButtonGrid,'push');
            app.DiskUsageUpdateButton.Layout.Row=1;
            app.DiskUsageUpdateButton.Layout.Column=1;
            app.DiskUsageUpdateButton.Text='';
            app.DiskUsageUpdateButton.Icon=app.App.Icons.rebootIcon;
            app.DiskUsageUpdateButton.Tooltip=getString(message('slrealtime:explorer:diskUsageUpdateButtonTooltip'));
            app.DiskUsageUpdateButton.ButtonPushedFcn=createCallbackFcn(app,@DiskUsageUpdateButtonPushed,true);


            app.AppUITableNameLabel=uilabel(app.ApplicationGridLayout);
            app.AppUITableNameLabel.HorizontalAlignment='left';
            app.AppUITableNameLabel.Layout.Row=1;
            app.AppUITableNameLabel.Layout.Column=1;
            app.AppUITableNameLabel.Text=[getString(message('slrealtime:explorer:applicationsOnTargetComputer')),':'];


            app.ApplicationUITable=uitable(app.ApplicationGridLayout);
            app.ApplicationUITable.Layout.Row=2;
            app.ApplicationUITable.Layout.Column=1;
            app.ApplicationUITable.ColumnName={...
            message('slrealtime:explorer:applicationName').getString;...
            message('slrealtime:explorer:modelName').getString;...
            message('slrealtime:explorer:applicationLastModified').getString;...
            message('slrealtime:explorer:modelLastModified').getString;...
            message('slrealtime:explorer:runOnStartup').getString};
            app.ApplicationUITable.ColumnWidth={'1x','1x','1x','1x','1x'};
            app.ApplicationUITable.ColumnEditable=[false,false,false,false,true];
            app.ApplicationUITable.RowName={};
            app.ApplicationUITable.CellSelectionCallback=createCallbackFcn(app,@AppUITableCellSelection,true);
            app.ApplicationUITable.CellEditCallback=createCallbackFcn(app,@AppUITableCellEdit,true);
            app.ApplicationUITable.SelectionType='row';


            app.AppDeleteButton=uibutton(app.AppButtonLayout,'push');
            app.AppDeleteButton.ButtonPushedFcn=createCallbackFcn(app,@AppDeleteButtonPushed,true);
            app.AppDeleteButton.Layout.Row=1;
            app.AppDeleteButton.Layout.Column=3;
            app.AppDeleteButton.Text=getString(message(app.App.Messages.deleteMsgId));


            app.AppPropertiesButton=uibutton(app.AppButtonLayout,'push');
            app.AppPropertiesButton.ButtonPushedFcn=createCallbackFcn(app,@AppPropertiesButtonPushed,true);
            app.AppPropertiesButton.Layout.Row=1;
            app.AppPropertiesButton.Layout.Column=2;
            app.AppPropertiesButton.Text=message('slrealtime:explorer:properties').getString;


            app.UIFigure.Visible='on';
        end
    end


    methods(Access=private)


        function UpdateSoftwareButtonPushed(app,event)
            selectedTargetName=app.App.TargetManager.getSelectedTargetName();
            msg1=message(app.App.Messages.configureTargetComputerSoftwarePromptMsgId,selectedTargetName);
            msg2=message(app.App.Messages.configureTargetComputerSoftwareConfirmMsgId);
            uiconfirm(app.UIFigure,...
            msg1.getString(),msg2.getString(),...
            'CloseFcn',@(o,e)app.configureTargetComputerSoftwareMenuCloseFcn(o,e,selectedTargetName));
        end


        function ChangeIPAddrButtonPushed(app,event)
            selectedTargetName=app.App.TargetManager.getSelectedTargetName();

            msg=message(app.App.Messages.configureTargetComputerIPAddressGetValuesMsgId);
            title=message(app.App.Messages.configureTargetComputerIPAddressMsgId);
            app.App.TargetManager.progressDlg=uiprogressdlg(app.UIFigure,...
            'Indeterminate','on',...
            'Message',msg.getString(),...
            'Title',title.getString());

            try
                [ipaddr,netmask]=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTIpAddrAndNetMask(selectedTargetName);
            catch ME
                if~isempty(app.App.TargetManager.progressDlg)
                    delete(app.App.TargetManager.progressDlg);
                    app.App.TargetManager.progressDlg=[];
                end

                uialert(app.UIFigure,ME.message,title.getString());
                return;
            end

            if~isempty(app.App.TargetManager.progressDlg)
                delete(app.App.TargetManager.progressDlg);
                app.App.TargetManager.progressDlg=[];
            end




            if isempty(ipaddr)
                uialert(app.UIFigure,getString(message(app.App.Messages.emptyTargetIpAddressErrorMsgId)),title.getString());
                return;
            end

            answer=inputdlg({getString(message(app.App.Messages.newIPAddressMsgId)),getString(message(app.App.Messages.newNetmaskMsgId))},title.getString(),[1,65;1,65],{ipaddr,netmask});
            app.App.App.bringToFront();
            if isempty(answer)
                return;
            end
            newAddr=answer{1};
            newNetmask=answer{2};


            if~slrealtime.internal.validateIpAddress(newAddr)
                msg1=message(app.App.Messages.invalidIpAddressMsgId,newAddr);
                msg2=message(app.App.Messages.errorMsgId);
                uialert(app.UIFigure,msg1.getString(),msg2.getString());
                return;
            end


            if~slrealtime.internal.validateIpAddress(newNetmask)
                msg1=message(app.App.Messages.invalidNetmaskMsgId,newNetmask);
                msg2=message(app.App.Messages.errorMsgId);
                uialert(app.UIFigure,msg1.getString(),msg2.getString());
                return;
            end

            if strcmp(newAddr,ipaddr)
                newAddr=[];
            end
            if strcmp(newNetmask,netmask)
                newNetmask=[];
            end

            if isempty(newAddr)&&isempty(newNetmask)

                return;
            end

            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
            if isempty(newAddr)
                newAddr=tg.TargetSettings.address;
            end

            if isempty(newNetmask)
                msg1=message(app.App.Messages.configureTargetComputerIPAddressOnlyMsgId,newAddr);
            else
                msg1=message(app.App.Messages.configureTargetComputerIPAddressAndNetmaskMsgId,newAddr,newNetmask);
            end

            msg2=message(app.App.Messages.configureTargetComputerIPAddressPromptMsgId,selectedTargetName,msg1.getString());
            msg3=message(app.App.Messages.configureTargetComputerIPAddressConfirmMsgId);
            uiconfirm(app.UIFigure,...
            msg2.getString(),msg3.getString(),...
            'CloseFcn',@(o,e)app.configureTargetComputerIPAddressMenuCloseFcn(o,e,selectedTargetName,newAddr,newNetmask));
        end


        function RebootButtonPushed(app,event)
            selectedTargetName=app.App.TargetManager.getSelectedTargetName();
            msg1=message(app.App.Messages.targetComputerRebootPromptMsgId,selectedTargetName);
            msg2=message(app.App.Messages.targetComputerRebootConfirmMsgId);
            uiconfirm(app.UIFigure,...
            msg1.getString(),msg2.getString(),...
            'CloseFcn',@(o,e)app.configureTargetComputerRebootMenuCloseFcn(o,e,selectedTargetName));
        end


        function AppDeleteButtonPushed(app,event)
            sels=app.ApplicationUITable.Selection;
            if isempty(sels)
                return;
            end

            targetName=app.App.TargetManager.getSelectedTargetName();
            target=app.App.TargetManager.getTargetFromMap(targetName);
            appNames=arrayfun(@(x)target.node.Children(x).NodeData.appName,...
            sels,'UniformOutput',false);

            if length(sels)>1
                msg=message('slrealtime:explorer:deleteAppPrompt2',length(sels));
            else
                msg=message('slrealtime:explorer:deleteAppPrompt1',appNames{1});
            end
            title=message('slrealtime:explorer:deleteAppConfirm');

            uiconfirm(app.UIFigure,...
            msg.getString(),title.getString(),...
            'CloseFcn',@(o,e)app.appDeleteConfirmCloseFcn(o,e,targetName,appNames));
        end


        function AppPropertiesButtonPushed(app,~)
            sels=app.ApplicationUITable.Selection;
            if isempty(sels)
                return;
            end

            targetName=app.App.TargetManager.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
            target=app.App.TargetManager.getTargetFromMap(targetName);
            for k=1:length(sels)
                appName=target.node.Children(sels(k)).NodeData.appName;
                slrealtime.internal.guis.Explorer.AppPropertiesDialogWrapper.open(app.App,appName,tg);
            end




        end


        function AppUITableCellSelection(app,event)
            sels=event.Source.Selection;
            if isempty(sels)
                app.AppDeleteButton.Enable='off';

                app.AppPropertiesButton.Enable='off';
            else
                app.AppDeleteButton.Enable='on';

                app.AppPropertiesButton.Enable='on';
            end
        end


        function AppUITableCellEdit(app,event)
            edits=event.Indices(:,1);

            if~isequal(event.NewData,event.PreviousData)
                targetName=app.App.TargetManager.getSelectedTargetName();
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);

                msg=message(app.App.Messages.configuringMsgId);
                title=message(app.App.Messages.configureRunOnStartupMsgId);
                app.App.TargetManager.progressDlg=uiprogressdlg(app.UIFigure,...
                'Indeterminate','on',...
                'Message',msg.getString(),...
                'Title',title.getString());

                try
                    if event.NewData
                        target=app.App.TargetManager.getTargetFromMap(targetName);
                        tg.setStartupApp(target.node.Children(edits).NodeData.appName,'SkipInstall',true);
                    else
                        tg.clearStartupApp;
                    end
                catch ME
                    if~isempty(app.App.TargetManager.progressDlg)
                        delete(app.App.TargetManager.progressDlg);
                        app.App.TargetManager.progressDlg=[];
                    end

                    uialert(app.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
                end
            end
        end


        function NameEditFieldValueChanged(app,event)
            widget=event.Source;
            name=event.Value;
            oldValue=event.PreviousValue;
            if isempty(name)
                msg1=message(app.App.Messages.emptyTargetNameMsgId);
                msg2=message(app.App.Messages.errorMsgId);
                uialert(app.UIFigure,msg1.getString(),msg2.getString(),'CloseFcn',@(~,~)widget.set('Value',oldValue));
            else
                app.valueChangedHandler(event,'name',name);
            end
        end


        function IPAddressEditFieldValueChanged(app,event)

            isValidIp=slrealtime.internal.validateIpAddress(event.Value);
            if~isValidIp
                widget=event.Source;
                oldValue=event.PreviousValue;
                msg1=message(app.App.Messages.invalidIpAddressMsgId,event.Value);
                msg2=message(app.App.Messages.errorMsgId);
                uialert(app.UIFigure,msg1.getString(),msg2.getString(),'CloseFcn',@(~,~)widget.set('Value',oldValue));
                return;
            end



            isIpAddrUsed=slrealtime.internal.guis.Explorer.StaticUtils.isDuplicateIP(event.Value);

            if(isIpAddrUsed)
                widget=event.Source;
                oldValue=event.PreviousValue;
                uialert(app.UIFigure,...
                getString(message(app.App.Messages.duplicateTargetIpAddressErrorMsgId)),...
                message('slrealtime:explorer:error').getString(),'CloseFcn',@(~,~)widget.set('Value',oldValue));
                return;
            end

            app.valueChangedHandler(event,'address',event.Value);
        end


        function DefaultCheckBoxValueChanged(app,event)







            slrealtime.internal.guis.Explorer.StaticUtils.enableDisableWidgets(app.DefaultCheckBox,'off');



            app.DefaultCheckBox.Value=true;

            try
                targets=slrealtime.Targets;
                targets.setDefaultTargetName(app.App.TargetManager.getSelectedTargetName());
            catch ME
                msg=message(app.App.Messages.errorMsgId);
                uialert(app.UIFigure,ME.message,msg.getString(),...
                'CloseFcn',@(~,~)app.App.UpdateApp.TargetConfigurationForDefaultTarget());
            end
        end


        function DiskUsageUpdateButtonPushed(app,event)
            targetName=app.App.TargetManager.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
            app.updateDiskUsageProgressBar(tg);
        end

    end


    methods(Access=private)



        function configureTargetComputerRebootMenuCloseFcn(app,~,event,targetName)






            if strcmp(event.SelectedOption,'OK')
                msg=message(app.App.Messages.rebootingMsgId);
                title=message(app.App.Messages.targetComputerRebootMsgId);
                app.RebootProgressDlg=uiprogressdlg(app.UIFigure,...
                'Message',msg.getString(),...
                'Title',title.getString());

                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                app.rebootListener=addlistener(tg,'RebootIssued',@(src,evnt)app.App.EventCallBack.targetRebootIssued(src,evnt));
                try
                    tg.reboot();
                catch ME
                    if~isempty(app.RebootProgressDlg)
                        delete(app.RebootProgressDlg);
                        app.RebootProgressDlg=[];
                    end
                    uialert(app.UIFigure,ME.message,title.getString());
                end
            end
        end

        function configureTargetComputerIPAddressMenuCloseFcn(app,~,event,targetName,newAddr,newNetmask)






            if strcmp(event.SelectedOption,'OK')

                msg=message(app.App.Messages.configuringMsgId);
                title=message(app.App.Messages.configureTargetComputerIPAddressMsgId);
                app.App.TargetManager.progressDlg=uiprogressdlg(app.UIFigure,...
                'Indeterminate','on',...
                'Message',msg.getString(),...
                'Title',title.getString());

                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                app.ipAddrChangedListener=addlistener(tg,'SetIPAddressCompleted',@(src,evnt)app.App.EventCallBack.targetIPAddress(src,evnt));
                try
                    if isempty(newNetmask)
                        tg.setipaddr(newAddr);
                    else
                        tg.setipaddr(newAddr,newNetmask);
                    end
                catch ME
                    if~isempty(app.App.TargetManager.progressDlg)
                        delete(app.App.TargetManager.progressDlg);
                        app.App.TargetManager.progressDlg=[];
                    end

                    uialert(app.UIFigure,ME.message,title.getString());
                end
            end
        end

        function configureTargetComputerSoftwareMenuCloseFcn(app,~,event,targetName)






            if strcmp(event.SelectedOption,'OK')

                msg=message(app.App.Messages.configuringMsgId);
                title=message(app.App.Messages.configureTargetComputerSoftwareMsgId);
                app.RebootProgressDlg=uiprogressdlg(app.UIFigure,...
                'Message',msg.getString(),...
                'Title',title.getString());

                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                app.updateMessageListener=addlistener(tg,'UpdateMessage',@(src,evnt)app.App.EventCallBack.targetUpdateProgressDlgMessage(src,evnt));
                app.updateCompletedListener=addlistener(tg,'UpdateCompleted',@(src,evnt)app.App.EventCallBack.targetUpdateCompleted(src,evnt));
                app.updateFailedListener=addlistener(tg,'UpdateFailed',@(src,evnt)app.App.EventCallBack.targetUpdateFailed(src,evnt));
                app.updateRebootListener=addlistener(tg,'RebootIssued',@(src,evnt)app.App.EventCallBack.targetUpdateReboot(src,evnt));
                try
                    tg.update();
                catch ME
                    if~isempty(app.RebootProgressDlg)
                        delete(app.RebootProgressDlg);
                        app.RebootProgressDlg=[];
                    end
                    uialert(app.UIFigure,ME.message,title.getString());
                end
            end
        end

        function valueChangedHandler(app,event,setting,newValue)



            oldValue=event.PreviousValue;
            widget=event.Source;
            try
                targetName=app.App.TargetManager.getSelectedTargetName();
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                tg.TargetSettings.(setting)=newValue;
            catch ME
                msg=message(app.App.Messages.errorMsgId);
                uialert(app.UIFigure,ME.message,msg.getString(),'CloseFcn',@(~,~)widget.set('Value',oldValue));
            end
        end

    end

end
