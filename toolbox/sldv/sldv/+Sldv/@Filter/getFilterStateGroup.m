function groupFilterState=getFilterStateGroup(this,tag,widgetId,varargin)





    [table,noRules]=this.getFilterState;
    numOfCols=table.Size(2);
    filterState.Type='table';
    filterState.Size=table.Size;
    filterState.ColHeader=table.ColHeader;
    filterState.Data=table.Data;
    filterState.SelectionBehavior='Row';
    filterState.HeaderVisibility=[0,1];
    filterState.Editable=true;
    filterState.RowSpan=[2,4];
    filterState.ColSpan=[1,9];
    filterState.ColumnStretchable=ones(1,numOfCols);
    filterState.ReadOnlyColumns=table.ReadOnlyColumns;
    if~isempty(table.SelectedRow)
        filterState.SelectedRow=table.SelectedRow;
    end
    filterState.ValueChangedCallback=@modelTableChanged;
    filterState.SelectionChangedCallback=@eventTableSelectionChanged;
    filterState.ItemDoubleClickedCallback=@eventItemDoubleClicked;
    filterState.Mode=true;
    filterState.DialogRefresh=true;
    filterState.Tag=[tag,'filterState'];
    filterState.WidgetId=[widgetId,'filterState'];

    filterStateNameText.Tag=[tag,'filterStateNameText'];
    filterStateNameText.Type='text';
    filterStateNameText.Bold=true;
    filterStateNameText.Name=getString(message('Sldv:Filter:dvFilterSelectedRule'));
    filterStateNameText.RowSpan=[5,5];
    filterStateNameText.ColSpan=[1,1];

    filterStateName.Tag=[tag,'filterStateName'];
    filterStateName.Type='text';
    filterStateName.WidgetId=[widgetId,'filterStateName'];
    if~isempty(table.SelectedRow)
        filterStateName.Name=table.Data{table.SelectedRow+1,1};
    end
    filterStateName.Graphical=true;
    filterStateName.RowSpan=[5,5];
    filterStateName.ColSpan=[2,9];

    filterRemoveItem.Name=getString(message('Sldv:Filter:dvFilterRemoveRule'));
    filterRemoveItem.Type='pushbutton';
    filterRemoveItem.RowSpan=[2,2];
    filterRemoveItem.ColSpan=[1,1];
    filterRemoveItem.Enabled=~noRules;
    filterRemoveItem.DialogRefresh=true;
    filterRemoveItem.Tag=[tag,'filterRemoveItem'];
    filterRemoveItem.WidgetId=[widgetId,'filterRemoveItem'];
    filterRemoveItem.MatlabMethod='filterRemoveCallback';
    filterRemoveItem.MatlabArgs={this,'%dialog',[tag,'filterState'],false};

    highlight.Name=getString(message('Sldv:Filter:dvFilterViewInModel'));
    highlight.Type='pushbutton';
    highlight.RowSpan=[3,3];
    highlight.ColSpan=[1,1];
    highlight.Enabled=~noRules;
    highlight.DialogRefresh=true;
    highlight.Tag=[tag,'highlight'];
    highlight.WidgetId=[widgetId,'highlight'];
    highlight.MatlabMethod='highliteCallback';
    highlight.MatlabArgs={this,'%dialog',[tag,'filterState']};

    pushPanel.Type='panel';
    pushPanel.Items={filterRemoveItem,highlight};
    pushPanel.RowSpan=[1,4];
    pushPanel.ColSpan=[10,10];
    pushPanel.LayoutGrid=[4,1];
    pushPanel.RowStretch=[1,0,0,1];

    emptyTxt.Name='  ';
    emptyTxt.Type='text';
    emptyTxt.RowSpan=[1,1];
    emptyTxt.ColSpan=[1,3];

    modelTab.Name=getString(message('Sldv:Filter:dvFilterModelTab'));
    modelTab.Items={filterState,filterStateNameText,filterStateName,emptyTxt,pushPanel};
    modelTab.LayoutGrid=[5,10];
    modelTab.RowStretch=[0,1,1,1,0];
    modelTab.Tag=[tag,'modelTab'];
    modelTab.WidgetId=[widgetId,'modelTab'];


    [table,noRules]=this.getFilterState(true);
    numOfRows=table.Size(1);
    numOfCols=table.Size(2);

    selectedRow=table.SelectedRow;
    if isempty(selectedRow)&&(numOfRows>0)
        selectedRow=0;
    end
    cfilterState.Type=filterState.Type;
    cfilterState.Size=table.Size;
    cfilterState.ColHeader=filterState.ColHeader;
    cfilterState.Data=table.Data;
    cfilterState.SelectionBehavior=filterState.SelectionBehavior;
    cfilterState.HeaderVisibility=filterState.HeaderVisibility;
    cfilterState.Editable=filterState.Editable;
    cfilterState.RowSpan=filterState.RowSpan;
    cfilterState.ColSpan=filterState.ColSpan;
    cfilterState.ColumnStretchable=ones(1,numOfCols);
    cfilterState.ReadOnlyColumns=table.ReadOnlyColumns;
    if~isempty(selectedRow)
        cfilterState.SelectedRow=selectedRow;
    end
    cfilterState.ValueChangedCallback=@codeTableChanged;
    cfilterState.SelectionChangedCallback=@eventTableSelectionChanged;
    cfilterState.ItemDoubleClickedCallback=@eventItemDoubleClicked;
    cfilterState.Mode=filterState.Mode;
    cfilterState.DialogRefresh=filterState.DialogRefresh;
    cfilterState.Tag=[tag,'cfilterState'];
    cfilterState.WidgetId=[widgetId,'cfilterState'];

    cfilterStateNameText.Tag=[tag,'cfilterStateNameText'];
    cfilterStateNameText.Type='text';
    cfilterStateNameText.Bold=true;
    cfilterStateNameText.Name=getString(message('Sldv:Filter:dvFilterSelectedRule'));
    cfilterStateNameText.RowSpan=[5,5];
    cfilterStateNameText.ColSpan=[1,1];

    if~isempty(selectedRow)
        cfilterStateName.Name=genCodeFilterDescription(this,selectedRow);
    end
    cfilterStateName.Type='text';
    cfilterStateName.WordWrap=1;
    cfilterStateName.RowSpan=[5,5];
    cfilterStateName.ColSpan=[2,9];
    cfilterStateName.Tag=[tag,'cfilterStateName'];
    cfilterStateName.WidgetId=[widgetId,'cfilterStateName'];
    cfilterStateName.Graphical=true;

    cfilterRemoveItem.Name=getString(message('Sldv:Filter:dvFilterRemoveRule'));
    cfilterRemoveItem.Type='pushbutton';
    cfilterRemoveItem.RowSpan=[2,2];
    cfilterRemoveItem.ColSpan=[1,1];
    cfilterRemoveItem.Enabled=~noRules;
    cfilterRemoveItem.DialogRefresh=true;
    cfilterRemoveItem.Tag=[tag,'cfilterRemoveItem'];
    cfilterRemoveItem.WidgetId=[widgetId,'cfilterRemoveItem'];
    cfilterRemoveItem.MatlabMethod='filterRemoveCallback';
    cfilterRemoveItem.MatlabArgs={this,'%dialog',[tag,'cfilterState'],true};

    cpushPanel.Type='panel';
    cpushPanel.Items={cfilterRemoveItem};
    cpushPanel.RowSpan=[1,4];
    cpushPanel.ColSpan=[10,10];
    cpushPanel.LayoutGrid=[4,1];
    cpushPanel.RowStretch=[1,0,0,1];

    codeTab.Name=getString(message('Sldv:Filter:dvFilterCodeTab'));
    codeTab.Items={cfilterState,cfilterStateNameText,cfilterStateName,emptyTxt,cpushPanel};
    codeTab.LayoutGrid=[5,10];
    codeTab.RowStretch=[0,1,1,1,0];
    codeTab.Tag=[tag,'codeTab'];
    codeTab.WidgetId=[widgetId,'codeTab'];


    ruleTab.Type='tab';
    ruleTab.Tabs={modelTab,codeTab};
    ruleTab.Tag=[tag,'rulesTab'];
    ruleTab.WidgetId=[widgetId,'rulesTab'];

    groupFilterState=ruleTab;
end

function eventItemDoubleClicked(dlg,~,~,~)
    if~isempty(dlg)
        obj=dlg.getSource;
        obj.hasUnappliedChanges=true;
        dlg.refresh;
        dlg.enableApplyButton(true);
    end
end

function eventTableSelectionChanged(dlg,widgetTag)
    idx=dlg.getSelectedTableRows(widgetTag);
    if numel(idx)>1
        dlg.selectTableRow(widgetTag,idx(1));
    end

    Sldv.Filter.updateFilterNameWidget(dlg,widgetTag);
end

function modelTableChanged(dlg,ridx,cidx,value)
    tableChanged(dlg,ridx,cidx,value,false)
end

function codeTableChanged(dlg,ridx,cidx,value)
    tableChanged(dlg,ridx,cidx,value,true)
end

function tableChanged(dlg,ridx,cidx,value,forCode)
    obj=dlg.getSource;

    if(cidx==3)
        addRationaleCallback(obj,dlg,ridx+1,cidx+1,value,forCode)
    else
        changeFilterModeCallback(obj,dlg,ridx+1,value,forCode);
    end
end


