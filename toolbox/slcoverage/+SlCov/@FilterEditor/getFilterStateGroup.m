function groupFilterState=getFilterStateGroup(this,tag,widgetId,varargin)




    if numel(varargin)>=1
        helpText={};
    else
        helpText.Type='hyperlink';
        helpText.Name=DAStudio.message('Slvnv:simcoverage:covFilterNewRuleHelp');
        helpText.RowSpan=[1,1];
        helpText.ColSpan=[1,3];
        helpText.Tag=[tag,'helpText'];
        helpText.WidgetId=[widgetId,'helpText'];
        helpText.Name='Model highlight with coverage result';
        helpText.MatlabMethod='highliteCallback';
        helpText.MatlabArgs={this,'%dialog',[tag,'filterState']};
    end
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
    isSelected=~isempty(table.SelectedRow);
    if isSelected
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
    filterStateNameText.Name=DAStudio.message('Slvnv:simcoverage:covFilterSelectedRule');
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

    filterRemoveItem.Name=DAStudio.message('Slvnv:simcoverage:covFilterRemoveRule');
    filterRemoveItem.Type='pushbutton';
    filterRemoveItem.RowSpan=[2,2];
    filterRemoveItem.ColSpan=[1,1];
    filterRemoveItem.Enabled=~noRules;
    filterRemoveItem.DialogRefresh=true;
    filterRemoveItem.Tag=[tag,'filterRemoveItem'];
    filterRemoveItem.WidgetId=[widgetId,'filterRemoveItem'];
    filterRemoveItem.MatlabMethod='filterRemoveCallback';
    filterRemoveItem.MatlabArgs={this,'%dialog',[tag,'filterState'],false};

    highlight.Name=DAStudio.message('Slvnv:simcoverage:covFilterViewInModel');
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

    modelTab.Name=DAStudio.message('Slvnv:simcoverage:covFilterModelTab');
    if~isempty(helpText)
        modelTab.Items={helpText,filterState,emptyTxt,pushPanel};
    else
        modelTab.Items={filterState,filterStateNameText,filterStateName,emptyTxt,pushPanel};
    end
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

    if~isempty(selectedRow)
        cfilterStateName.Name=genCodeFilterDescription(this,selectedRow);
    end
    cfilterStateName.Type='text';
    cfilterStateName.WordWrap=1;
    cfilterStateName.RowSpan=[5,5];
    cfilterStateName.ColSpan=[1,9];
    cfilterStateName.Tag=[tag,'cfilterStateName'];
    cfilterStateName.WidgetId=[widgetId,'cfilterStateName'];
    cfilterStateName.Graphical=true;

    filterRemoveItem.Name=DAStudio.message('Slvnv:simcoverage:covFilterRemoveRule');
    filterRemoveItem.Type='pushbutton';
    filterRemoveItem.RowSpan=[2,2];
    filterRemoveItem.ColSpan=[1,1];
    filterRemoveItem.Enabled=~noRules;
    filterRemoveItem.DialogRefresh=true;
    filterRemoveItem.Tag=[tag,'cfilterRemoveItem'];
    filterRemoveItem.WidgetId=[widgetId,'cfilterRemoveItem'];
    filterRemoveItem.MatlabMethod='filterRemoveCallback';
    filterRemoveItem.MatlabArgs={this,'%dialog',[tag,'cfilterState'],true};

    pushPanel=[];
    pushPanel.Type='panel';
    pushPanel.Items={filterRemoveItem};
    pushPanel.RowSpan=[1,4];
    pushPanel.ColSpan=[10,10];
    pushPanel.LayoutGrid=[4,1];
    pushPanel.RowStretch=[1,0,0,1];

    codeTab.Name=DAStudio.message('Slvnv:simcoverage:covFilterCodeTab');
    codeTab.Items={emptyTxt,cfilterState,cfilterStateName,pushPanel};
    codeTab.LayoutGrid=[5,10];
    codeTab.RowStretch=[0,1,1,1,0];
    codeTab.Tag=[tag,'codeTab'];
    codeTab.WidgetId=[widgetId,'codeTab'];

    ruleTab.Type='tab';
    ruleTab.TabChangedCallback='cvi.ResultsExplorer.Tree.filterTabChangedCallback';
    ruleTab.Tabs={modelTab,codeTab};
    ruleTab.Tag=[tag,'rulesTab'];
    ruleTab.WidgetId=[widgetId,'rulesTab'];

    groupFilterState=ruleTab;


    function eventItemDoubleClicked(dlg,~,~,~)
        if~isempty(dlg)
            obj=SlCov.FilterEditor.getFilterObjFromDlg(dlg);
            obj.hasUnappliedChanges=true;
            dlg.refresh();
            dlg.enableApplyButton(true);
        end


        function eventTableSelectionChanged(dlg,widgetTag)
            idx=dlg.getSelectedTableRows(widgetTag);
            if numel(idx)>1
                dlg.selectTableRow(widgetTag,idx(1));
            end

            SlCov.FilterEditor.updateFilterNameWidget(dlg,contains(widgetTag,'_cfilterState'));


            function modelTableChanged(dlg,ridx,cidx,value)
                tableChanged(dlg,ridx,cidx,value,false)


                function codeTableChanged(dlg,ridx,cidx,value)
                    tableChanged(dlg,ridx,cidx,value,true)


                    function tableChanged(dlg,ridx,cidx,value,forCode)
                        obj=SlCov.FilterEditor.getFilterObjFromDlg(dlg);
                        if(cidx==3)
                            addRationaleCallback(obj,dlg,ridx+1,cidx+1,value,forCode)
                        else
                            changeFilterModeCallback(obj,dlg,ridx+1,value,forCode);
                        end
