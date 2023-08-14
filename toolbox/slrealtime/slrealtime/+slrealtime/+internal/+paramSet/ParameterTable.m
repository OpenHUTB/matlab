classdef ParameterTable<handle





    properties(Hidden=true)
Icons
Tooltips
Messages

        UIFigure matlab.ui.Figure
        GridLayout matlab.ui.container.GridLayout
        GridLayout2 matlab.ui.container.GridLayout
        ParameterSetLabel matlab.ui.control.Label
        SearchImage matlab.ui.control.Image
        FilterContentsEditField matlab.ui.control.EditField
HighlightParameterInModelButton
FeedBackToModelButton
UITable
ParameterSet
ValueEditor
    end

    methods
        function this=ParameterTable(paramSet)

            this.Icons=slrealtime.internal.guis.Explorer.Icons;
            this.Messages=slrealtime.internal.guis.Explorer.Messages;
            this.Tooltips=slrealtime.internal.guis.Explorer.Tooltips;

            this.ParameterSet=paramSet;

            this.UIFigure=uifigure;
            this.UIFigure.Visible='off';
            this.UIFigure.Position=[100,100,800,300];
            this.UIFigure.Name=getString(message('slrealtime:paramSet:TableName'));
            this.UIFigure.CloseRequestFcn=@this.UIFigureCloseCB;


            this.GridLayout=uigridlayout(this.UIFigure);
            this.GridLayout.ColumnWidth={'1x'};
            this.GridLayout.RowHeight={30,50,'4x'};
            this.GridLayout.ColumnSpacing=1;
            this.GridLayout.RowSpacing=1;
            this.GridLayout.Padding=[10,10,10,10];



            this.ParameterSetLabel=uilabel(this.GridLayout);
            this.ParameterSetLabel.Layout.Row=1;
            this.ParameterSetLabel.Layout.Column=1;
            this.ParameterSetLabel.FontWeight='bold';
            this.ParameterSetLabel.Text=strcat('Parameter Set: ','"',this.ParameterSet.filename,'"');


            this.GridLayout2=uigridlayout(this.GridLayout);
            this.GridLayout2.Layout.Row=2;
            this.GridLayout2.Layout.Column=1;
            this.GridLayout2.ColumnWidth={28,160,'1x','1x','1x'};
            this.GridLayout2.RowHeight={'1x'};
            this.GridLayout2.ColumnSpacing=1;
            this.GridLayout2.RowSpacing=1;
            this.GridLayout2.Padding=[10,10,10,10];


            this.SearchImage=uiimage(this.GridLayout2);
            this.SearchImage.ScaleMethod='none';
            this.SearchImage.Layout.Row=1;
            this.SearchImage.Layout.Column=1;

            this.SearchImage.ImageSource=this.Icons.searchIcon;


            this.FilterContentsEditField=uieditfield(this.GridLayout2,'text');
            this.FilterContentsEditField.ValueChangedFcn=@this.FilterContentsEditFieldValueChanged;
            this.FilterContentsEditField.Layout.Row=1;
            this.FilterContentsEditField.Layout.Column=2;


            this.HighlightParameterInModelButton=uibutton(this.GridLayout2,'push');
            this.HighlightParameterInModelButton.Layout.Row=1;
            this.HighlightParameterInModelButton.Layout.Column=5;
            this.HighlightParameterInModelButton.Text=getString(message(this.Messages.highlightInModelButtonTextMsgId));
            this.HighlightParameterInModelButton.Icon=this.Icons.hiliteInModelIcon;
            this.HighlightParameterInModelButton.ButtonPushedFcn=@this.HighlightParameterInModelButtonPushed;
            this.HighlightParameterInModelButton.Enable='off';


            this.UITable=uitable(this.GridLayout);
            this.UITable.ColumnName={'Block Path';'Name';'Data Type';'Value';'Size'};
            this.UITable.ColumnSortable=true;
            this.UITable.ColumnWidth={'auto','auto','auto','auto'};
            this.UITable.Layout.Row=3;
            this.UITable.Layout.Column=1;
            this.UITable.ColumnEditable=[false,false,false,true,false];
            this.UITable.addStyle(uistyle('HorizontalAlignment','left'),'table','');
            this.UITable.Data=this.ParameterSet.paramsForDisplay;
            this.UITable.CellSelectionCallback=@this.UITableCellSelection;
            this.UITable.CellEditCallback=@this.UITableCellEdit;

            this.UIFigure.Visible='on';
        end

        function bringToFront(this)
            figure(this.UIFigure);
        end

        function delete(this)
            if~isempty(this.ValueEditor)
                delete(this.ValueEditor);
                this.ValueEditor=[];
            end
            if isgraphics(this.UIFigure)
                delete(this.UIFigure);
            end
        end

    end

    methods(Access=private)



        function UIFigureCloseCB(this,~,~)
            if~isempty(this.ValueEditor)
                delete(this.ValueEditor);
                this.ValueEditor=[];
            end
            delete(this.UIFigure);
        end




        function FilterContentsEditFieldValueChanged(this,EditField,event)
            value=this.FilterContentsEditField.Value;
            if isempty(value)

                newTableForDisplay=this.ParameterSet.paramsForDisplay;
            else

                paramNameIdxs=find(cellfun(@(x)contains(x,value,'IgnoreCase',true),{this.ParameterSet.metadata.parameters.Name}));
                paramName=this.ParameterSet.paramsForDisplay.paramName(paramNameIdxs);
                newTableForDisplay=this.ParameterSet.paramsForDisplay(ismember(this.ParameterSet.paramsForDisplay.paramName,paramName),:);
            end
            this.UITable.Data=newTableForDisplay;
        end



        function HighlightParameterInModelButtonPushed(this,Button,event)
            sels=this.UITable.Selection;
            if isempty(sels)
                return
            end

            if~isempty(this.UITable.Data)

                selectedRows=unique(sels(:,1));
                row=selectedRows(1);
                blkpath=char(this.UITable.Data{row,1});

                try
                    slrealtime.internal.highlightParameter(blkpath);
                    if length(selectedRows)>1



                        idx2=(sels(:,1)==row);
                        this.UITable.Selection=sels(~idx2,:);
                    end
                catch ME
                    uialert(this.UIFigure,ME.message,getString(message('slrealtime:paramSet:error')));
                end
                return;
            end
        end



        function UITableCellSelection(this,Table,event)
            sels=Table.Selection;
            if isempty(sels)
                this.HighlightParameterInModelButton.Enable='off';
                this.HighlightParameterInModelButton.Tooltip='';
            else
                this.HighlightParameterInModelButton.Enable='on';
                this.HighlightParameterInModelButton.Tooltip=getString(message(this.Tooltips.highlightParameterButtonTooltip));
            end

            [row,~]=size(sels);
            if(~isempty(sels))&&(row==1)
                selectedRows=unique(sels(:,1));
                if strcmp(this.UITable.Data{selectedRows,3},'struct')&&(sels(2)==4)
                    if~isempty(this.ValueEditor)

                        delete(this.ValueEditor);
                        this.ValueEditor=[];
                    end
                    blkPath=char(this.UITable.Data{selectedRows,1});
                    pName=char(this.UITable.Data{selectedRows,2});
                    pValue=cell2mat(this.UITable.Data{selectedRows,4});
                    this.ValueEditor=slrealtime.internal.paramSet.ParamEditor(blkPath,pName,pValue,this.ParameterSet,selectedRows,this.UIFigure);
                end
            end
        end



        function UITableCellEdit(this,Table,event)
            sels=Table.Selection;
            [row,~]=size(sels);
            if(~isempty(sels))&&(row==1)
                selectedRows=unique(sels(:,1));
                blkPath=char(Table.Data.blkPath(selectedRows));
                paramName=char(Table.Data.paramName(selectedRows));
                dataType=char(Table.Data.dataType(selectedRows));

                try
                    if strcmp(dataType,'char')
                        this.ParameterSet.set(blkPath,paramName,event.NewData);
                    else
                        newVal=str2num(event.NewData);
                        if isempty(newVal)
                            slrealtime.internal.throw.Error('slrealtime:paramSet:typeNotMatch');
                        end
                        this.ParameterSet.set(blkPath,paramName,newVal);
                    end
                catch ME
                    Table.Data.value(selectedRows)={event.PreviousData};
                    uialert(this.UIFigure,ME.message,getString(message('slrealtime:paramSet:error')));
                end

            end
        end

    end

end