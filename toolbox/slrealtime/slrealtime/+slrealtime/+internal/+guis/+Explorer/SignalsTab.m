classdef SignalsTab<handle





    properties
App

GridLayout
HighlightButtonGridLayout
SDIButtonGridLayout

HighlightSignalInModelButton
AddInstrumentButton
RemoveInstrumentButton
MonitorModeButton

SignalsavailableontargetcomputerLabel
SignalsTable
InstrumentationTable

TopRightGridLayout
GroupsignalstostreamtoSDILabel
ImportAcquireListButton
ExportAcquireListButton
PublishAcquireListButton

MiddleGridLayout
AddToSignalGroupButton
RemoveFromSignalGroupButton
    end


    methods
        function this=SignalsTab(hApp)
            this.App=hApp;


            this.GridLayout=uigridlayout(this.App.SignalsPanel.GridLayout);
            this.GridLayout.ColumnWidth={'3x',30,'3x'};
            this.GridLayout.RowHeight={30,'1x',30};
            this.GridLayout.ColumnSpacing=1;
            this.GridLayout.RowSpacing=1;
            this.GridLayout.Padding=[5,5,5,5];



            this.HighlightButtonGridLayout=uigridlayout(this.GridLayout);
            this.HighlightButtonGridLayout.ColumnWidth={'1x','2x','1x'};
            this.HighlightButtonGridLayout.RowHeight={'1x'};
            this.HighlightButtonGridLayout.ColumnSpacing=1;
            this.HighlightButtonGridLayout.RowSpacing=1;
            this.HighlightButtonGridLayout.Padding=[0,0,0,0];
            this.HighlightButtonGridLayout.Layout.Row=3;
            this.HighlightButtonGridLayout.Layout.Column=1;


            this.HighlightSignalInModelButton=uibutton(this.HighlightButtonGridLayout,'push');
            this.HighlightSignalInModelButton.Layout.Row=1;
            this.HighlightSignalInModelButton.Layout.Column=2;
            this.HighlightSignalInModelButton.Text=getString(message(this.App.Messages.highlightInModelButtonTextMsgId));
            this.HighlightSignalInModelButton.Icon=this.App.Icons.hiliteInModelIcon;
            this.HighlightSignalInModelButton.ButtonPushedFcn=@this.HighlightSignalInModelButtonPushed;
            this.HighlightSignalInModelButton.Enable='off';



            this.SDIButtonGridLayout=uigridlayout(this.GridLayout);
            this.SDIButtonGridLayout.ColumnWidth={'0.01x','1x','1x','1x','0.01x'};
            this.SDIButtonGridLayout.RowHeight={'1x'};
            this.SDIButtonGridLayout.ColumnSpacing=5;
            this.SDIButtonGridLayout.RowSpacing=1;
            this.SDIButtonGridLayout.Padding=[0,0,0,0];
            this.SDIButtonGridLayout.Layout.Row=3;
            this.SDIButtonGridLayout.Layout.Column=3;


            this.AddInstrumentButton=uibutton(this.SDIButtonGridLayout,'push');
            this.AddInstrumentButton.Layout.Row=1;
            this.AddInstrumentButton.Layout.Column=2;
            this.AddInstrumentButton.Text=getString(message('slrealtime:explorer:addInstrument'));
            this.AddInstrumentButton.Icon=this.App.Icons.addInstrumentIcon;
            this.AddInstrumentButton.ButtonPushedFcn=@this.AddInstrumentButtonPushed;
            this.AddInstrumentButton.Enable='off';
            this.AddInstrumentButton.Tooltip='';


            this.RemoveInstrumentButton=uibutton(this.SDIButtonGridLayout,'push');
            this.RemoveInstrumentButton.Layout.Row=1;
            this.RemoveInstrumentButton.Layout.Column=3;
            this.RemoveInstrumentButton.Text=getString(message('slrealtime:explorer:removeInstrument'));
            this.RemoveInstrumentButton.Icon=this.App.Icons.removeInstrumentIcon;
            this.RemoveInstrumentButton.ButtonPushedFcn=@this.RemoveInstrumentButtonPushed;
            this.RemoveInstrumentButton.Enable='off';
            this.RemoveInstrumentButton.Tooltip='';


            this.MonitorModeButton=uibutton(this.SDIButtonGridLayout,'state');
            this.MonitorModeButton.Layout.Row=1;
            this.MonitorModeButton.Layout.Column=4;
            this.MonitorModeButton.Text=getString(message(this.App.Messages.monitorModeButtonTextMsgId));
            this.MonitorModeButton.Icon=this.App.Icons.viewValuesIcon;
            this.MonitorModeButton.ValueChangedFcn=@this.MonitorModeButtonValueChanged;


            this.SignalsavailableontargetcomputerLabel=uilabel(this.GridLayout);
            this.SignalsavailableontargetcomputerLabel.FontSize=11;
            this.SignalsavailableontargetcomputerLabel.FontAngle='italic';
            this.SignalsavailableontargetcomputerLabel.Text=getString(message(this.App.Messages.signalsAvailableOnTargetComputerLabelTextMsgId));
            this.SignalsavailableontargetcomputerLabel.Layout.Row=1;
            this.SignalsavailableontargetcomputerLabel.Layout.Column=1;


            this.SignalsTable=uitable(this.GridLayout);
            this.SignalsTable.ColumnName={getString(message(this.App.Messages.tableColumnNameBlockPathMsgId));...
            getString(message(this.App.Messages.signalsTableColumnNameSignalNameMsgId))};
            this.SignalsTable.RowName={};
            this.SignalsTable.ColumnSortable=true;
            this.SignalsTable.ColumnEditable=false;
            this.SignalsTable.ColumnWidth={'1x','1x'};
            this.SignalsTable.Layout.Row=2;
            this.SignalsTable.Layout.Column=1;
            this.SignalsTable.CellSelectionCallback=@this.SignalsTableCellSelection;
            this.SignalsTable.SelectionType='row';



            this.InstrumentationTable=uitable(this.GridLayout);
            this.InstrumentationTable.ColumnName={getString(message(this.App.Messages.tableColumnNameBlockPathMsgId))};
            this.InstrumentationTable.RowName={};
            this.InstrumentationTable.ColumnSortable=false;
            this.InstrumentationTable.ColumnEditable=false;
            this.InstrumentationTable.ColumnWidth={'1x'};
            this.InstrumentationTable.Layout.Row=2;
            this.InstrumentationTable.Layout.Column=3;
            this.InstrumentationTable.CellSelectionCallback=@this.InstrumentationTableCellSelection;
            this.InstrumentationTable.SelectionType='row';


            this.TopRightGridLayout=uigridlayout(this.GridLayout);
            this.TopRightGridLayout.ColumnWidth={'1x','1x',30,30,30};
            this.TopRightGridLayout.RowHeight={'1x'};
            this.TopRightGridLayout.ColumnSpacing=1;
            this.TopRightGridLayout.RowSpacing=1;
            this.TopRightGridLayout.Padding=[0,0,0,0];
            this.TopRightGridLayout.Layout.Row=1;
            this.TopRightGridLayout.Layout.Column=3;


            this.GroupsignalstostreamtoSDILabel=uilabel(this.TopRightGridLayout);
            this.GroupsignalstostreamtoSDILabel.FontSize=11;
            this.GroupsignalstostreamtoSDILabel.FontAngle='italic';
            this.GroupsignalstostreamtoSDILabel.Layout.Row=1;
            this.GroupsignalstostreamtoSDILabel.Layout.Column=1;
            this.GroupsignalstostreamtoSDILabel.Text=getString(message(this.App.Messages.groupSignalstoStreamtoSDILabelTextMsgId));

            this.ExportAcquireListButton=uibutton(this.TopRightGridLayout,'push');
            this.ExportAcquireListButton.ButtonPushedFcn=@this.ExportAcquireListButtonPushed;
            this.ExportAcquireListButton.Tooltip={''};
            this.ExportAcquireListButton.Layout.Row=1;
            this.ExportAcquireListButton.Layout.Column=3;
            this.ExportAcquireListButton.Text='';
            this.ExportAcquireListButton.Icon=this.App.Icons.exportIcon;

            this.ImportAcquireListButton=uibutton(this.TopRightGridLayout,'push');
            this.ImportAcquireListButton.ButtonPushedFcn=@this.ImportAcquireListButtonPushed;
            this.ImportAcquireListButton.Tooltip={''};
            this.ImportAcquireListButton.Layout.Row=1;
            this.ImportAcquireListButton.Layout.Column=4;
            this.ImportAcquireListButton.Text='';
            this.ImportAcquireListButton.Icon=this.App.Icons.importIcon;

            this.PublishAcquireListButton=uibutton(this.TopRightGridLayout,'push');
            this.PublishAcquireListButton.ButtonPushedFcn=@this.PublishAcquireListButtonPushed;
            this.PublishAcquireListButton.Tooltip={''};
            this.PublishAcquireListButton.Layout.Row=1;
            this.PublishAcquireListButton.Layout.Column=5;
            this.PublishAcquireListButton.Text='';
            this.PublishAcquireListButton.Icon=this.App.Icons.publishIcon;


            this.MiddleGridLayout=uigridlayout(this.GridLayout);
            this.MiddleGridLayout.ColumnWidth={'1x'};
            this.MiddleGridLayout.RowHeight={'1x',30,'1x',30,'1x'};
            this.MiddleGridLayout.ColumnSpacing=1;
            this.MiddleGridLayout.RowSpacing=1;
            this.MiddleGridLayout.Padding=[1,1,1,1];
            this.MiddleGridLayout.Layout.Row=2;
            this.MiddleGridLayout.Layout.Column=2;


            this.AddToSignalGroupButton=uibutton(this.MiddleGridLayout,'push');
            this.AddToSignalGroupButton.ButtonPushedFcn=@this.AddToSignalGroupButtonPushed;
            this.AddToSignalGroupButton.Tooltip={''};
            this.AddToSignalGroupButton.Layout.Row=2;
            this.AddToSignalGroupButton.Layout.Column=1;
            this.AddToSignalGroupButton.Text='';
            this.AddToSignalGroupButton.Icon=this.App.Icons.addRowIcon;


            this.RemoveFromSignalGroupButton=uibutton(this.MiddleGridLayout,'push');
            this.RemoveFromSignalGroupButton.ButtonPushedFcn=@this.RemoveFromSignalGroupButtonPushed;
            this.RemoveFromSignalGroupButton.Layout.Row=4;
            this.RemoveFromSignalGroupButton.Layout.Column=1;
            this.RemoveFromSignalGroupButton.Text='';
            this.RemoveFromSignalGroupButton.Icon=this.App.Icons.removeRowIcon;
        end

        function delete(this)
            if(this.MonitorModeButton.Value)
                selectedTargetName=this.App.TargetManager.getSelectedTargetName();
                target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
                if~isempty(target.instruments)&&~isempty(target.instruments.streamed)
                    sInst=target.instruments.streamed;
                    tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
                    try
                        tg.removeInstrument(sInst);
                    catch
                    end
                end
            end
        end

        function disable(this)

            this.InstrumentationTable.UserData=[];
            this.InstrumentationTable.Data=[];
            this.InstrumentationTable.Selection=[];
            this.InstrumentationTable.Enable='off';

            this.SignalsTable.UserData=[];
            this.SignalsTable.Data=[];
            this.SignalsTable.Selection=[];
            this.SignalsTable.Enable='off';

            this.AddToSignalGroupButton.Enable='off';
            this.RemoveFromSignalGroupButton.Enable='off';

            this.HighlightSignalInModelButton.Enable='off';
            this.HighlightSignalInModelButton.Tooltip='';

            this.AddInstrumentButton.Enable='off';
            this.AddInstrumentButton.Tooltip={''};

            this.RemoveInstrumentButton.Enable='off';
            this.RemoveInstrumentButton.Tooltip={''};

            this.MonitorModeButton.Value=false;
            this.MonitorModeButton.Enable='off';
            this.MonitorModeButton.Tooltip={''};



            this.InstrumentationTable.ColumnName={...
            getString(message(this.App.Messages.tableColumnNameBlockPathMsgId))};
            this.InstrumentationTable.ColumnWidth={'1x'};
            this.InstrumentationTable.Data=cell(0,1);

            this.updateAcquireListManagement('off');
        end


        function updateAcquireListManagement(this,flag)

            if strcmp(flag,'on')

                this.ImportAcquireListButton.Enable='on';
                this.ExportAcquireListButton.Enable='on';
                this.PublishAcquireListButton.Enable='on';

                this.ImportAcquireListButton.Tooltip=getString(message(this.App.Tooltips.importAcquireList));
                this.ExportAcquireListButton.Tooltip=getString(message(this.App.Tooltips.exportAcquireList));
                this.PublishAcquireListButton.Tooltip=getString(message(this.App.Tooltips.publishAcquireList));
            else
                this.ImportAcquireListButton.Enable='off';
                this.ExportAcquireListButton.Enable='off';
                this.PublishAcquireListButton.Enable='off';

                this.ImportAcquireListButton.Tooltip='';
                this.ExportAcquireListButton.Tooltip='';
                this.PublishAcquireListButton.Tooltip='';
            end

        end

        function updateInstrumentationTable(this,pInst)



            nsigs=length(pInst.signals);

            blkpathsToDisp=cell(nsigs,1);
            blockpaths=cell(nsigs,1);
            portindices=cell(nsigs,1);
            statenames=cell(nsigs,1);
            signames=cell(nsigs,1);
            groupNumber=cell(nsigs,1);
            signalIndex=cell(nsigs,1);
            nSig=1;

            for si=1:nsigs
                signalIndex{nSig}=si;
                blockpaths{nSig}=pInst.signals(si).blockpath.convertToCell();
                portindices{nSig}=pInst.signals(si).portindex;
                signames{nSig}=pInst.signals(si).signame;
                statenames{nSig}=pInst.signals(si).statename;
                metadata=pInst.signals(si).metadata;
                if isfield(metadata,'isPathWithinSubsystemWithHiddenContents')&&metadata.isPathWithinSubsystemWithHiddenContents
                    tmpblkpath=metadata.grBlockPath;
                else
                    tmpblkpath=blockpaths{nSig};
                end
                blkpathsToDisp{nSig}=slrealtime.internal.guis.Explorer.StaticUtils.convertBlockPathsToDisplayStringForSignal(tmpblkpath,portindices{nSig},statenames{nSig});
                nSig=nSig+1;
            end

            if this.MonitorModeButton.Value


                this.InstrumentationTable.ColumnName={...
                getString(message(this.App.Messages.tableColumnNameBlockPathMsgId));...
                getString(message(this.App.Messages.tableColumnNameValueMsgId))};
                this.InstrumentationTable.ColumnWidth={'1x','1x'};
                this.InstrumentationTable.Data=[blkpathsToDisp,cell(nsigs,1)];
            else


                this.InstrumentationTable.ColumnName={...
                getString(message(this.App.Messages.tableColumnNameBlockPathMsgId))};
                this.InstrumentationTable.ColumnWidth={'1x'};
                this.InstrumentationTable.Data=blkpathsToDisp;
            end
            this.InstrumentationTable.UserData=[blockpaths,portindices,signames,groupNumber,signalIndex];
            this.InstrumentationTable.Enable='on';
        end

        function createAndCacheInstrumentsIfNeeded(this)
            targetName=this.App.TargetManager.getSelectedTargetName();
            target=this.App.TargetManager.getTargetFromMap(targetName);

            if isempty(target.instruments)
                instruments=struct(...
                'pending',[],...
                'streamed',[],...
                'duplicate',[]...
                );

                pInst=slrealtime.Instrument(target.Application.mldatx);
                tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(targetName);
                if~tg.isRunning
                    pInst.addInstrumentedSignals();
                end
                instruments.pending=pInst;

                if~isempty(pInst.signals)


                    instruments.streamed=pInst.copy();
                    instruments.streamed.RemoveOnStop=true;
                    instruments.streamed.connectCallback(@this.MonitorModeCallback);

                    instruments.duplicate=pInst.copy();
                    instruments.duplicate.UUID=Simulink.HMI.AsyncQueueObserverAPI.getUUIdFromString(char(matlab.lang.internal.uuid));
                    instruments.duplicate.RemoveOnStop=true;
                    try
                        if this.App.SignalsTab.MonitorModeButton.Value
                            tg.addInstrument(instruments.streamed);
                        end
                        tg.addInstrument(instruments.duplicate);
                    catch ME


                        try
                            tg.removeInstrument(instruments.streamed);
                            tg.removeInstrument(instruments.duplicate);
                        catch
                        end
                        delete(instruments.streamed);
                        instruments.streamed=[];



                        huifig=this.App.UpdateApp.getShowingUIFigure();
                        if this.App.App.Visible&&isempty(huifig)
                            huifig=this.App.SignalsPanel.UIFigure;
                        end
                        if~isempty(huifig)
                            uialert(huifig,ME.message,message('slrealtime:explorer:error').getString());
                        end
                    end
                end

                target.instruments=instruments;
                this.App.TargetManager.targetMap(targetName)=target;
            end
        end

    end

    methods(Access=private)



        function HighlightSignalInModelButtonPushed(this,Button,event)

            if isempty(this.SignalsTable.Selection)
                return
            end

            if~isempty(this.SignalsTable.Data)

                idx=this.SignalsTable.Selection(1);
                sig=this.SignalsTable.UserData(idx);
                try
                    slrealtime.internal.highlightSignal(Simulink.SimulationData.BlockPath(sig.BlockPath),sig.PortIndex);
                    if length(this.SignalsTable.Selection)>1



                        this.SignalsTable.Selection=idx;
                    end
                catch ME
                    uialert(this.App.SignalsPanel.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
                end
                return;
            end





        end

        function AddToSignalGroupButtonPushed(this,Button,event)

            sels=this.SignalsTable.Selection;
            if isempty(sels)
                return;
            end

            sigs=this.SignalsTable.UserData(sels);

            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
            pInst=target.instruments.pending;

            if length(sigs)>10
                if isempty(this.App.TargetManager.progressDlg)
                    msg1=message('slrealtime:explorer:addingSignals');
                    msg2=message('slrealtime:explorer:addingSignalsToInstrument');
                    this.App.TargetManager.progressDlg=uiprogressdlg(...
                    this.App.SignalsPanel.UIFigure,...
                    'Indeterminate','on',...
                    'Message',msg1.getString(),...
                    'Title',msg2.getString());
                end
            end

            try

                S=warning('off','SimulinkRealTime:slrt:InstrumentationAlreadyAdded');
                for i=1:length(sigs)
                    pInst.addSignal(sigs(i).BlockPath,sigs(i).PortIndex);
                end

                warning(S);


                this.App.UpdateApp.ForTargetApplicationSignalsGroup(selectedTargetName);
            catch ME
                uialert(this.App.SignalsPanel.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
            end

            if~isempty(this.App.TargetManager.progressDlg)
                drawnow;
                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=[];
            end

            this.SignalsTable.Selection=[];

            this.AddToSignalGroupButton.Enable='off';
            this.HighlightSignalInModelButton.Enable='off';
            this.HighlightSignalInModelButton.Tooltip={''};
        end

        function RemoveFromSignalGroupButtonPushed(this,Button,event)

            rows=this.InstrumentationTable.Selection;
            if~any(rows)
                return;
            end

            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
            pInst=target.instruments.pending;

            nSig=length(rows);
            if(length(pInst.signals)-nSig)>10
                if isempty(this.App.TargetManager.progressDlg)
                    msg1=message('slrealtime:explorer:removingSignals');
                    msg2=message('slrealtime:explorer:removingSignalsFromInstrument');
                    this.App.TargetManager.progressDlg=uiprogressdlg(...
                    this.App.SignalsPanel.UIFigure,...
                    'Indeterminate','on',...
                    'Message',msg1.getString(),...
                    'Title',msg2.getString());
                end
            end

            try


                appName=pInst.Application;
                pInst.validate([]);
                for i=nSig:-1:1
                    row=rows(i);
                    pInst.removeSignal(this.InstrumentationTable.UserData{row,1},this.InstrumentationTable.UserData{row,2});
                end

                pInst.validate(appName);


                this.App.UpdateApp.ForTargetApplicationSignalsGroup(selectedTargetName);
            catch ME
                uialert(this.App.SignalsPanel.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
            end

            if~isempty(this.App.TargetManager.progressDlg)
                drawnow;
                delete(this.App.TargetManager.progressDlg);
                this.App.TargetManager.progressDlg=[];
            end

            this.InstrumentationTable.Selection=[];
            this.RemoveFromSignalGroupButton.Enable='off';
        end

        function AddInstrumentButtonPushed(this,Button,event)
            this.AddInstrumentButton.Enable='off';
            this.AddInstrumentButton.Tooltip='';

            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);



            if~isempty(target.instruments.streamed)
                try
                    if this.MonitorModeButton.Value
                        tg.removeInstrument(target.instruments.streamed);
                    end
                    tg.removeInstrument(target.instruments.duplicate);
                catch ME
                    uialert(this.App.SignalsPanel.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
                end
                delete(target.instruments.streamed);
                target.instruments.streamed=[];
                this.App.TargetManager.targetMap(selectedTargetName)=target;



                this.AddInstrumentButton.Text=getString(message('slrealtime:explorer:addInstrument'));
                this.AddInstrumentButton.Icon=this.App.Icons.addInstrumentIcon;
            end

            pInst=target.instruments.pending;

            if~isempty(pInst.signals)




                target.instruments.streamed=pInst.copy();
                target.instruments.streamed.RemoveOnStop=true;
                target.instruments.streamed.connectCallback(@this.MonitorModeCallback);



                if isempty(target.instruments.duplicate)
                    duplicate_uuid=Simulink.HMI.AsyncQueueObserverAPI.getUUIdFromString(char(matlab.lang.internal.uuid));
                else
                    duplicate_uuid=target.instruments.duplicate.UUID;
                end
                delete(target.instruments.duplicate);
                target.instruments.duplicate=pInst.copy();
                target.instruments.duplicate.UUID=duplicate_uuid;
                target.instruments.duplicate.RemoveOnStop=true;

                this.App.TargetManager.targetMap(selectedTargetName)=target;

                if length(target.instruments.streamed.signals)>10
                    if isempty(this.App.TargetManager.progressDlg)
                        msg1=message('slrealtime:explorer:startingStreaming');
                        msg2=message('slrealtime:explorer:startingStreamingToSDI');
                        this.App.TargetManager.progressDlg=uiprogressdlg(...
                        this.App.SignalsPanel.UIFigure,...
                        'Indeterminate','on',...
                        'Message',msg1.getString(),...
                        'Title',msg2.getString());
                    end
                end

                try
                    if this.MonitorModeButton.Value
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
                    this.App.TargetManager.targetMap(selectedTargetName)=target;

                    if~isempty(this.App.TargetManager.progressDlg)
                        drawnow;
                        delete(this.App.TargetManager.progressDlg);
                        this.App.TargetManager.progressDlg=[];
                    end


                    this.AddInstrumentButton.Enable='on';
                    this.AddInstrumentButton.Tooltip=getString(message(this.App.Tooltips.streamSignalGroupTooltip));

                    uialert(this.App.SignalsPanel.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
                    return;
                end

                if~isempty(this.App.TargetManager.progressDlg)
                    drawnow;
                    delete(this.App.TargetManager.progressDlg);
                    this.App.TargetManager.progressDlg=[];
                end
            end

            this.RemoveInstrumentButton.Enable='on';
            this.RemoveInstrumentButton.Tooltip=getString(message(this.App.Tooltips.stopStreamSignalGroupTooltip));
        end


        function RemoveInstrumentButtonPushed(this,Button,event)
            this.RemoveInstrumentButton.Enable='off';
            this.RemoveInstrumentButton.Tooltip='';

            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);

            if~isempty(target.instruments.streamed)
                if length(target.instruments.streamed.signals)>50
                    if isempty(this.App.TargetManager.progressDlg)
                        msg1=message('slrealtime:explorer:stoppingStreaming');
                        msg2=message('slrealtime:explorer:stoppingStreamingToSDI');
                        this.App.TargetManager.progressDlg=uiprogressdlg(...
                        this.App.SignalsPanel.UIFigure,...
                        'Indeterminate','on',...
                        'Message',msg1.getString(),...
                        'Title',msg2.getString());
                    end
                end

                try
                    if this.MonitorModeButton.Value
                        tg.removeInstrument(target.instruments.streamed);
                    end
                    tg.removeInstrument(target.instruments.duplicate);
                catch ME
                    uialert(this.App.SignalsPanel.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
                end
                delete(target.instruments.streamed);
                target.instruments.streamed=[];
                this.App.TargetManager.targetMap(selectedTargetName)=target;

                if~isempty(this.App.TargetManager.progressDlg)
                    drawnow;
                    delete(this.App.TargetManager.progressDlg);
                    this.App.TargetManager.progressDlg=[];
                end
            end

            if isempty(target.instruments.pending.signals)




                this.AddInstrumentButton.Enable='off';
                this.AddInstrumentButton.Tooltip='';
            else
                this.AddInstrumentButton.Enable='on';
                this.AddInstrumentButton.Tooltip=getString(message(this.App.Tooltips.streamSignalGroupTooltip));
            end
            this.AddInstrumentButton.Text=getString(message('slrealtime:explorer:addInstrument'));
            this.AddInstrumentButton.Icon=this.App.Icons.addInstrumentIcon;
        end

        function MonitorModeButtonValueChanged(this,Button,event)
            value=event.Value;

            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
            sInst=target.instruments.streamed;
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);

            if value



                this.InstrumentationTable.ColumnWidth={'1x','1x'};
                this.InstrumentationTable.ColumnName={...
                getString(message(this.App.Messages.tableColumnNameBlockPathMsgId));...
                getString(message(this.App.Messages.tableColumnNameValueMsgId))};
                n=size(this.InstrumentationTable.Data,1);
                this.InstrumentationTable.Data=[this.InstrumentationTable.Data(:,1),cell(n,1)];

                if~isempty(sInst)
                    try
                        tg.addInstrument(sInst);
                    catch ME

                    end
                end
            else


                if~isempty(sInst)
                    try
                        tg.removeInstrument(sInst);
                    catch ME

                    end
                end


                this.InstrumentationTable.ColumnWidth={'1x'};
                this.InstrumentationTable.ColumnName={...
                getString(message(this.App.Messages.tableColumnNameBlockPathMsgId))};
                this.InstrumentationTable.Data=this.InstrumentationTable.Data(:,1);
            end
        end

        function MonitorModeCallback(this,~,eventData)
            import slrealtime.internal.guis.Explorer.StaticUtils.num2string

            tableData=this.InstrumentationTable.Data;

            nSigInTable=size(this.InstrumentationTable.UserData,1);
            if size(tableData,2)==1
                value=cell(nSigInTable,1);
                tableData=[tableData,value];
            else
                value=tableData(:,2);
            end

            for row=1:length(eventData.Source.signals)
                signal=eventData.Source.signals(row);
                keyStr=slrealtime.Instrument.getSignalStringToDisplay(signal);
                if eventData.Map.isKey(keyStr)
                    v=eventData.Map(keyStr);
                    agi=v(1);
                    si=v(2);

                    agData=eventData.AcquireGroupData(agi).Data;
                    time=eventData.AcquireGroupData(agi).Time;

                    if~isempty(agData)
                        sData=agData{si};
                        if isempty(sData)
                            continue
                        end
                        if length(time)==1
                            d=sData;
                        elseif ndims(sData)<=2

                            d=sData(end,:);
                        else

                            d=sData(:,:,end);
                        end
                        if iscell(d)
                            d=d{:};
                        end
                        if ischar(d)
                            val=d;
                        else
                            try
                                val=char(num2string(d));
                            catch


                                val='<signal type not supported>';
                            end
                        end
                    end
                else

                    val='<signal type not supported>';
                end

                blockpaths=this.InstrumentationTable.UserData(:,1);
                portindices=this.InstrumentationTable.UserData(:,2);
                idx1=cellfun(@(x)isequal(x,signal.blockpath.convertToCell()),blockpaths);
                idx2=cellfun(@(x)isequal(x,signal.portindex),portindices(idx1));
                if any(idx2)
                    origialIdx=[1:length(value)]';
                    tmpIdx=origialIdx(idx1);
                    value{tmpIdx(idx2)}=val;
                end
            end

            this.InstrumentationTable.Data=[tableData(:,1),value];
        end

        function ExportAcquireListButtonPushed(this,button,event)


            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
            pInst=target.instruments.pending;


            [file,path]=uiputfile('*.mat',getString(message(this.App.Messages.exportInstrumentMsgId)));

            if file==0

                return
            end

            save(fullfile(path,file),'pInst');
        end

        function ImportAcquireListButtonPushed(this,button,event)
            [file,path]=uigetfile('*.mat',getString(message(this.App.Messages.importInstrumentMsgId)));

            if file==0

                return
            end

            [filepath,fname,ext]=fileparts(fullfile(path,file));


            if~strcmp(ext,'.mat')

                msg=message(this.App.Messages.invalidImportedFileMsgID);
                uialert(this.App.SignalsPanel.UIFigure,msg.getString(),message('slrealtime:explorer:error').getString());
                return;
            end


            originalState(1)=warning('off','MATLAB:load:classErrorNoCtor');
            originalState(2)=warning('off','MATLAB:load:classError');
            originalState(3)=warning('off','MATLAB:class:LoadInvalidDefaultElement');
            try

                S=load(fullfile(filepath,fname),'pInst');
            catch ME
                uialert(this.App.SignalsPanel.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
                return;
            end

            warning(originalState);

            if~isfield(S,'pInst')
                msg=message(this.App.Messages.invalidFileContentMsgID);
                uialert(this.App.SignalsPanel.UIFigure,msg.getString(),message('slrealtime:explorer:error').getString());
                return;
            end
            pInst=S.pInst;


            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
            targetmldatx=target.Application.mldatx;


            unavailSignals=pInst.validate(targetmldatx);

            if~isempty(unavailSignals.signals)

                originalState=warning('off','slrealtime:instrument:CannotInstrument');
                try
                    pInst.removeSignal(unavailSignals.signals);
                catch ME
                    uialert(this.App.SignalsPanel.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
                end

                warning(originalState);

                uialert(this.App.SignalsPanel.UIFigure,...
                message('slrealtime:explorer:removeUnavailSignals').getString(),...
                message('slrealtime:explorer:warning').getString(),'Icon','warning');
            end


            target.instruments.pending=pInst;
            this.App.TargetManager.targetMap(selectedTargetName)=target;


            this.App.UpdateApp.ForTargetApplicationSignalsGroup(selectedTargetName);
        end

        function PublishAcquireListButtonPushed(this,Button,event)

            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
            pInst=target.instruments.pending;
            pInst.generateScript;
        end


        function SignalsTableCellSelection(this,Table,event)
            sels=Table.Selection;
            if isempty(sels)
                this.AddToSignalGroupButton.Enable='off';
                this.HighlightSignalInModelButton.Enable='off';
                this.HighlightSignalInModelButton.Tooltip={''};
            else
                this.AddToSignalGroupButton.Enable='on';
                this.HighlightSignalInModelButton.Enable='on';
                this.HighlightSignalInModelButton.Tooltip=getString(message(this.App.Tooltips.highlightSignalButtonTooltip));
            end
        end


        function InstrumentationTableCellSelection(this,Table,event)
            sels=Table.Selection;
            if isempty(sels)
                this.RemoveFromSignalGroupButton.Enable='off';
            else
                this.RemoveFromSignalGroupButton.Enable='on';
            end
        end
    end

end
