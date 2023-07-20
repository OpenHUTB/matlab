function groupFilterState=getFilterStateGroup(this,tag,widgetId,varargin)




    emptyTxt.Name='  ';
    emptyTxt.Type='text';
    emptyTxt.RowSpan=[1,1];
    emptyTxt.ColSpan=[1,3];


    [table,noRules]=this.getFilterState(true);
    numOfRows=table.Size(1);
    numOfCols=table.Size(2);

    selectedRow=table.SelectedRow;
    if isempty(selectedRow)&&(numOfRows>0)
        selectedRow=0;
    end
    cfilterState.Type='table';
    cfilterState.Size=table.Size;
    cfilterState.ColHeader=table.ColHeader;
    cfilterState.Data=table.Data;
    cfilterState.SelectionBehavior='Row';
    cfilterState.HeaderVisibility=[0,1];
    cfilterState.Editable=true;
    cfilterState.RowSpan=[2,4];
    cfilterState.ColSpan=[1,9];
    cfilterState.ColumnStretchable=ones(1,numOfCols);
    cfilterState.ReadOnlyColumns=table.ReadOnlyColumns;
    if~isempty(selectedRow)
        cfilterState.SelectedRow=selectedRow;
    end
    cfilterState.ValueChangedCallback=@tableChanged;
    cfilterState.SelectionChangedCallback=@eventTableSelectionChanged;

    cfilterState.Mode=true;
    cfilterState.DialogRefresh=true;
    cfilterState.Tag=[tag,'cfilterState'];
    cfilterState.WidgetId=[widgetId,'cfilterState'];

    cfilterStateNameText.Tag=[tag,'cfilterStateNameText'];
    cfilterStateNameText.Type='text';
    cfilterStateNameText.Bold=true;
    cfilterStateNameText.Name=getString(message('Slvnv:simcoverage:covFilterSelectedRule'));
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

    cfilterRemoveItem.Name=getString(message('Slvnv:simcoverage:covFilterRemoveRule'));
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

    codeTab.Name=getString(message('Slvnv:simcoverage:covFilterCodeTab'));
    codeTab.Items={cfilterState,cfilterStateNameText,cfilterStateName,emptyTxt,cpushPanel};
    codeTab.LayoutGrid=[5,10];
    codeTab.RowStretch=[0,1,1,1,0];
    codeTab.Tag=[tag,'codeTab'];
    codeTab.WidgetId=[widgetId,'codeTab'];


    ruleTab.Type='tab';
    ruleTab.Tabs={codeTab};
    ruleTab.Tag=[tag,'rulesTab'];
    ruleTab.WidgetId=[widgetId,'rulesTab'];

    groupFilterState=ruleTab;


...
...
...
...
...
...
...
...
...


    function eventTableSelectionChanged(dlg,widgetTag)
        idx=dlg.getSelectedTableRows(widgetTag);
        if numel(idx)>1
            dlg.selectTableRow(widgetTag,idx(1));
        end

        SlCov.FilterEditor.updateFilterNameWidget(dlg,true);


        function tableChanged(dlg,ridx,cidx,value)
            obj=dlg.getSource;

            if(cidx==3)
                addRationaleCallback(obj,dlg,ridx+1,cidx+1,value,true)
            else
                changeFilterModeCallback(obj,dlg,ridx+1,value,true);
            end


