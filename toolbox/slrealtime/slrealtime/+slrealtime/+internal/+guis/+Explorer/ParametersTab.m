classdef ParametersTab<handle






    properties
App

GridLayout
BottomGridLayout
HighlightButtonGridLayout
HighlightParameterInModelButton

ParametersavailabletotuneontargetLabel
ParametersTable

ValueEditor

EnableParamTableButtonGridLayout
EnableParamTableButton
RefreshParamValuesButton
    end


    methods
        function this=ParametersTab(hApp)
            this.App=hApp;


            this.GridLayout=uigridlayout(this.App.ParametersPanel.GridLayout);
            this.GridLayout.ColumnWidth={'1x'};
            this.GridLayout.RowHeight={30,'1x',30};
            this.GridLayout.ColumnSpacing=1;
            this.GridLayout.RowSpacing=1;
            this.GridLayout.Padding=[5,5,5,5];

            this.BottomGridLayout=uigridlayout(this.GridLayout);
            this.BottomGridLayout.ColumnWidth={'3x',30,'3x'};
            this.BottomGridLayout.RowHeight={'1x'};
            this.BottomGridLayout.ColumnSpacing=1;
            this.BottomGridLayout.RowSpacing=1;
            this.BottomGridLayout.Padding=[0,0,0,0];
            this.BottomGridLayout.Layout.Row=3;
            this.BottomGridLayout.Layout.Column=1;


            this.HighlightButtonGridLayout=uigridlayout(this.BottomGridLayout);
            this.HighlightButtonGridLayout.ColumnWidth={'1x','2x','1x'};
            this.HighlightButtonGridLayout.RowHeight={'1x'};
            this.HighlightButtonGridLayout.ColumnSpacing=1;
            this.HighlightButtonGridLayout.RowSpacing=1;
            this.HighlightButtonGridLayout.Padding=[0,0,0,0];
            this.HighlightButtonGridLayout.Layout.Row=1;
            this.HighlightButtonGridLayout.Layout.Column=1;


            this.HighlightParameterInModelButton=uibutton(this.HighlightButtonGridLayout,'push');
            this.HighlightParameterInModelButton.Layout.Row=1;
            this.HighlightParameterInModelButton.Layout.Column=2;
            this.HighlightParameterInModelButton.Text=getString(message(this.App.Messages.highlightInModelButtonTextMsgId));
            this.HighlightParameterInModelButton.Icon=this.App.Icons.hiliteInModelIcon;
            this.HighlightParameterInModelButton.ButtonPushedFcn=@this.HighlightParameterInModelButtonPushed;


            this.EnableParamTableButtonGridLayout=uigridlayout(this.BottomGridLayout);
            this.EnableParamTableButtonGridLayout.ColumnWidth={'0.01x','1x','0.1x','1x','0.01x'};

            this.EnableParamTableButtonGridLayout.RowHeight={'1x'};
            this.EnableParamTableButtonGridLayout.ColumnSpacing=5;
            this.EnableParamTableButtonGridLayout.RowSpacing=1;
            this.EnableParamTableButtonGridLayout.Padding=[0,0,0,0];
            this.EnableParamTableButtonGridLayout.Layout.Row=1;
            this.EnableParamTableButtonGridLayout.Layout.Column=3;


            this.RefreshParamValuesButton=uibutton(this.EnableParamTableButtonGridLayout,'push');
            this.RefreshParamValuesButton.Layout.Row=1;
            this.RefreshParamValuesButton.Layout.Column=2;
            this.RefreshParamValuesButton.Text=getString(message('slrealtime:explorer:refreshValues'));
            this.RefreshParamValuesButton.Tooltip=getString(message('slrealtime:explorer:refreshParamValuesButtonTooltip'));
            this.RefreshParamValuesButton.Icon=this.App.Icons.rebootIcon;
            this.RefreshParamValuesButton.ButtonPushedFcn=@this.RefreshParamValuesButtonPushed;


            this.EnableParamTableButton=uibutton(this.EnableParamTableButtonGridLayout,'push');
            this.EnableParamTableButton.Layout.Row=1;
            this.EnableParamTableButton.Layout.Column=4;
            this.EnableParamTableButton.Text=getString(message('slrealtime:explorer:enableParamTable'));
            this.EnableParamTableButton.Icon=this.App.Icons.enableTableIcon;
            this.EnableParamTableButton.ButtonPushedFcn=@this.EnableParamTableButtonPushed;
            this.EnableParamTableButton.Visible='off';


            this.ParametersavailabletotuneontargetLabel=uilabel(this.GridLayout);
            this.ParametersavailabletotuneontargetLabel.FontSize=11;
            this.ParametersavailabletotuneontargetLabel.FontAngle='italic';
            this.ParametersavailabletotuneontargetLabel.Text=getString(message(this.App.Messages.parametersavailabletotuneontargetLabelTextMsgId));
            this.ParametersavailabletotuneontargetLabel.Layout.Row=1;
            this.ParametersavailabletotuneontargetLabel.Layout.Column=1;


            this.ParametersTable=uitable(this.GridLayout);
            this.ParametersTable.ColumnName={getString(message(this.App.Messages.tableColumnNameBlockPathMsgId));...
            getString(message(this.App.Messages.nameMsgId));...
            getString(message(this.App.Messages.tableColumnNameValueMsgId));...
            getString(message(this.App.Messages.parametersTableColumnNameTypeMsgId));...
            getString(message(this.App.Messages.parametersTableColumnNameSizeMsgId))};
            this.ParametersTable.RowName={};
            this.ParametersTable.ColumnSortable=true;
            this.ParametersTable.ColumnWidth={'1x','1x','1x','1x','1x'};
            this.ParametersTable.ColumnEditable=[false,false,true,false,false];
            this.ParametersTable.Layout.Row=2;
            this.ParametersTable.Layout.Column=1;
            this.ParametersTable.CellSelectionCallback=@this.ParametersTableCellSelection;
            this.ParametersTable.CellEditCallback=@this.ParametersTableCellEdit;

            this.ValueEditor=[];
        end

        function delete(this)
            if~isempty(this.ValueEditor)
                delete(this.ValueEditor);
                this.ValueEditor=[];
            end
        end

        function disable(this)
            this.ParametersTable.UserData=[];
            this.ParametersTable.Data=[];
            this.ParametersTable.Enable='off';
            this.App.TargetManager.HoldUpdatesButton.Enabled=false;

            this.ParametersTable.Tooltip='';

            this.App.TargetManager.HoldUpdatesButton.Enabled=false;
            this.App.TargetManager.HoldUpdatesButton.Value=false;
            this.App.TargetManager.UpdateParamsButton.Enabled=false;

            this.HighlightParameterInModelButton.Enable='off';
            this.HighlightParameterInModelButton.Tooltip='';

            this.RefreshParamValuesButton.Enable='off';
            this.RefreshParamValuesButton.Tooltip='';

            this.EnableParamTableButton.Visible='off';
        end

    end

    methods(Access=private)



        function HighlightParameterInModelButtonPushed(app,Button,event)
            sels=app.ParametersTable.Selection;
            if isempty(sels)
                return
            end

            if~isempty(app.ParametersTable.Data)

                selectedRows=unique(sels(:,1));
                idx=selectedRows(1);
                blkpath=app.ParametersTable.Data{idx,1};
                if length(selectedRows)>1



                    idx2=(sels(:,1)==idx);
                    app.ParametersTable.Selection=sels(idx2,:);
                end
                try
                    slrealtime.internal.highlightParameter(blkpath);
                catch ME
                    if isequal(ME.identifier,'slrealtime:explorer:highlightParameterInvalidPathError')&&...
                        app.ParametersTable.UserData(idx).IsModelArgument&&...
                        iscell(app.ParametersTable.UserData(idx).BlockPath)
                        try
                            slrealtime.internal.highlightParameter(app.ParametersTable.UserData(idx).BlockPath{1});
                        catch ME2
                            uialert(app.App.ParametersPanel.UIFigure,ME2.message,message('slrealtime:explorer:error').getString());
                        end
                    else
                        uialert(app.App.ParametersPanel.UIFigure,ME.message,message('slrealtime:explorer:error').getString());
                    end
                end

            end
        end

        function EnableParamTableButtonPushed(this,Button,event)
            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
            if~isequal(tg.getECUPage,tg.getXCPPage)
                select=uiconfirm(this.App.ParametersPanel.UIFigure,...
                getString(message('slrealtime:explorer:enableParamTablePagesDiffError')),...
                getString(message('slrealtime:explorer:error')),...
                'Options',{getString(message('slrealtime:explorer:fixIt')),getString(message('slrealtime:explorer:cancel'))},...
                'Icon','error');
                if isequal(select,getString(message('slrealtime:explorer:fixIt')))

                    target.Application.calPageChangedListener.Enabled=false;

                    cleanup=onCleanup(@()this.locEnableListener(target.Application.calPageChangedListener));


                    tg.setXCPPage(tg.getECUPage);


                    clear cleanup;
                else
                    return;
                end
            end


            this.ParametersTable.Enable='on';
            this.ParametersTable.Tooltip='';
            this.RefreshParamValuesButton.Enable='on';
            this.RefreshParamValuesButton.Tooltip=getString(message('slrealtime:explorer:refreshParamValuesButtonTooltip'));
            this.EnableParamTableButton.Visible='off';
            this.App.TargetManager.HoldUpdatesButton.Enabled=true;



            target.Application.paramValues=containers.Map('KeyType','char','ValueType','any');
            this.App.TargetManager.targetMap(selectedTargetName)=target;


            params=this.ParametersTable.UserData;
            blkpaths=this.ParametersTable.Data(:,1);
            [valStrs,types,dims,vals]=...
            this.App.UpdateApp.getSLRTTargetParameterValues(selectedTargetName,params,blkpaths);

            [params.value]=vals{:};
            this.ParametersTable.UserData=params;
            this.ParametersTable.Data(:,3:5)=[valStrs,types,dims];
        end

        function locEnableListener(this,evtLis)

            evtLis.Enabled=true;
        end

        function RefreshParamValuesButtonPushed(this,Button,event)
            selectedTargetName=this.App.TargetManager.getSelectedTargetName();


            params=this.ParametersTable.UserData;
            blkpaths=this.ParametersTable.Data(:,1);
            [valStrs,types,dims,vals]=...
            this.App.UpdateApp.getSLRTTargetParameterValues(selectedTargetName,params,blkpaths,'refreshValues',true);

            [params.value]=vals{:};
            this.ParametersTable.UserData=params;
            this.ParametersTable.Data(:,3:5)=[valStrs,types,dims];
        end

        function ParametersTableCellSelection(this,Table,event)
            sels=Table.Selection;
            if isempty(sels)
                this.HighlightParameterInModelButton.Enable='off';
                this.HighlightParameterInModelButton.Tooltip='';
            else
                this.HighlightParameterInModelButton.Enable='on';
                this.HighlightParameterInModelButton.Tooltip=getString(message(this.App.Tooltips.highlightParameterButtonTooltip));














                selectedRows=unique(sels(:,1));
                selectedData=this.ParametersTable.Data(selectedRows,:);
                blkpathStrs=selectedData(:,1);
                valStrs=selectedData(:,3);
                types=selectedData(:,4);
                params=this.ParametersTable.UserData(selectedRows,:);
                vals={params.value}';

                idx=strcmp(valStrs,'<user cancelled>');
                if any(idx)
                    idx2=find(idx);
                    params_cancelled=params(idx2);
                    blkpathStrs_cancelled=blkpathStrs(idx2);
                    if length(params_cancelled)>10
                        showProgressDlg=true;
                    else
                        showProgressDlg=false;
                    end
                    selectedTargetName=this.App.TargetManager.getSelectedTargetName();

                    [valStrs_cancelled,types_cancelled,dims_cancelled,vals_cancelled]=...
                    this.App.UpdateApp.getSLRTTargetParameterValues(...
                    selectedTargetName,...
                    params_cancelled,...
                    blkpathStrs_cancelled,...
                    'showProgressDlg',showProgressDlg);

                    this.ParametersTable.Data(selectedRows(idx2),3)=valStrs_cancelled;
                    this.ParametersTable.Data(selectedRows(idx2),4)=types_cancelled;
                    this.ParametersTable.Data(selectedRows(idx2),5)=dims_cancelled;
                    this.ParametersTable.UserData(selectedRows(idx2))=params_cancelled;



                    types(idx2)=types_cancelled;
                    vals(idx2)=vals_cancelled;
                end

                idx=strcmp(types,'struct');
                if any(idx)&&isequal(unique(sels(:,2)),3)



                    blkpaths={params.BlockPath}';
                    paramnames={params.BlockParameterName}';


                    structVal=vals(idx);
                    structVal=structVal{1};
                    structName=paramnames(idx);
                    structName=structName{1};
                    blkpath=blkpaths(idx);
                    blkpath=blkpath{1};

                    if~isempty(this.ValueEditor)

                        delete(this.ValueEditor);
                    end
                    selectedTargetName=this.App.TargetManager.getSelectedTargetName();
                    tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
                    this.ValueEditor=...
                    slrealtime.internal.guis.Explorer.ValueEditor(tg,structName,structVal,blkpath,this.App);
                end
            end

        end

        function ParametersTableCellEdit(this,Table,event)


            row=event.Indices(1);
            data=this.ParametersTable.Data;
            params=this.ParametersTable.UserData;

            blkpath=params(row).BlockPath;
            paramname=params(row).BlockParameterName;
            valStr=data{row,3};



            orig_data=data;
            orig_data{row,3}=event.PreviousData;



            try
                val=eval(valStr);
            catch ME
                uialert(this.App.ParametersPanel.UIFigure,ME.message,...
                message('slrealtime:explorer:error').getString(),...
                'CloseFcn',@(~,~)this.ParametersTable.set('Data',orig_data));
                return;
            end



            try
                if~isenum(val)
                    type=data{row,4};
                    try
                        type=eval(type);
                    catch
                    end
                    if isa(type,'Simulink.NumericType')||isa(type,'embedded.numerictype')
                        val=fi(val,type);
                    else
                        type=data{row,4};
                        val=eval([type,'(',valStr,')']);
                        this.ParametersTable.Data{row,3}=mat2str(val);
                    end
                end
            catch ME
                uialert(this.App.ParametersPanel.UIFigure,ME.message,...
                message('slrealtime:explorer:error').getString(),...
                'CloseFcn',@(~,~)this.ParametersTable.set('Data',orig_data));
                return;
            end



            selectedTargetName=this.App.TargetManager.getSelectedTargetName();
            tg=slrealtime.internal.guis.Explorer.StaticUtils.getSLRTTargetObject(selectedTargetName);
            try
                tg.setparam(blkpath,paramname,val);
            catch ME
                if~isempty(ME.cause)&&strcmp(ME.cause{1}.identifier,'slrealtime:paramtune:paramMinMax')
                    select=uiconfirm(this.App.ParametersPanel.UIFigure,ME.message,...
                    getString(message('slrealtime:explorer:error')),...
                    'Options',{getString(message('slrealtime:explorer:override')),getString(message('slrealtime:explorer:cancel'))},...
                    'DefaultOption',getString(message('slrealtime:explorer:cancel')),...
                    'Icon','error');
                    if isequal(select,getString(message('slrealtime:explorer:override')))

                        try
                            tg.setparam(blkpath,paramname,val,'Force',true);
                        catch ME2
                            uialert(this.App.ParametersPanel.UIFigure,ME2.message,...
                            message('slrealtime:explorer:error').getString(),...
                            'CloseFcn',@(~,~)this.ParametersTable.set('Data',orig_data));
                        end
                    else

                        this.ParametersTable.set('Data',orig_data);
                    end
                else
                    uialert(this.App.ParametersPanel.UIFigure,ME.message,...
                    message('slrealtime:explorer:error').getString(),...
                    'CloseFcn',@(~,~)this.ParametersTable.set('Data',orig_data));
                end
            end



            if this.App.TargetManager.UpdateParamsButton.Enabled
                target=this.App.TargetManager.getTargetFromMap(selectedTargetName);
                target.tuning.paramTableChanged=true;

                this.App.TargetManager.targetMap(selectedTargetName)=target;
            end
        end


    end

end
