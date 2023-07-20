classdef mdlrefddg_InstParamTab<handle




    properties

        expandButtonToolTip=DAStudio.message('Simulink:dialog:ExpandAllItemsTip');
        collapseButtonToolTip=DAStudio.message('Simulink:dialog:CollapseAllItemsTip');
        ddgCallbackMethod='mdlrefddg_cb';

        hierarchySpreadsheetColmnTitles={DAStudio.message('Simulink:dialog:ModelRefArgsTableSourceColumn');...
        DAStudio.message('Simulink:dialog:ModelRefArgsTableValueColumn');...
        DAStudio.message('Simulink:dialog:ModelRefArgsTableInstanceSpecificCheckBoxColumn');};
        hierarchySpreadsheetDefaultSortBy=DAStudio.message('Simulink:dialog:ModelRefArgsTableSourceColumn');


        boschSpreadsheetColmnTitles={DAStudio.message('Simulink:dialog:ModelRefArgsTableNameColumn');...
        DAStudio.message('Simulink:dialog:ModelRefArgsTableValueColumn');...
        DAStudio.message('Simulink:dialog:ModelRefArgsTableOwnerColumn');...
        [DAStudio.message('Simulink:dialog:ModelRefArgsTableFullPathColumn'),' ']};
        blockParameterColmnTitles={DAStudio.message('Simulink:dialog:ModelRefArgsTableNameColumn');...
        DAStudio.message('Simulink:dialog:ModelRefArgsTableValueColumn');...
        [DAStudio.message('Simulink:dialog:ModelRefArgsTableFullPathColumn'),' ']};

        legacySpreadsheetColmnTitles={DAStudio.message('Simulink:dialog:ModelRefArgsTableNameColumn');...
        DAStudio.message('Simulink:dialog:ModelRefArgsTableValueColumn')};


        noArgsText=DAStudio.message('Simulink:dialog:ModelRefArgsTableNoData');

        source=[];
        isSlimDialog=[];
        blockHandle=[];

    end
    methods(Access=public)
        function this=mdlrefddg_InstParamTab(source,isSlimDialog)
            this.source=source;
            this.isSlimDialog=isSlimDialog;
            this.blockHandle=this.source.getBlock().Handle;
        end

        function mdlBlkInstParamTab=getInstParamTab(this)
            mdlBlkInstParamTab=this.i_GetArgumentTreeTabs();
        end
    end

    methods(Access=private)
        function pButtonPanel=i_GetArgumentTreeTabsButtonPanel(this,widgetVisible)

            pExpandButton.Tag='ExpandAllButton';
            pExpandButton.Type='pushbutton';
            pExpandButton.RowSpan=[1,1];
            pExpandButton.ColSpan=[1,1];
            pExpandButton.Enabled=mdlrefddg_cb('EnableParamArgValues',this.source);
            pExpandButton.ToolTip=this.expandButtonToolTip;
            pExpandButton.MatlabMethod=this.ddgCallbackMethod;
            pExpandButton.MatlabArgs={'doExpandAll','%dialog'};
            pExpandButton.Visible=widgetVisible;
            pExpandButton.FilePath=getBlockSupportResource('tree_expand_all.png');


            pCollapseButton.Tag='CollapseAllButton';
            pCollapseButton.Type='pushbutton';
            pCollapseButton.RowSpan=[2,2];
            pCollapseButton.ColSpan=[1,1];
            pCollapseButton.Enabled=mdlrefddg_cb('EnableParamArgValues',this.source);
            pCollapseButton.ToolTip=this.collapseButtonToolTip;
            pCollapseButton.MatlabMethod=this.ddgCallbackMethod;
            pCollapseButton.MatlabArgs={'doCollapseAll','%dialog'};
            pCollapseButton.Visible=widgetVisible;
            pCollapseButton.FilePath=getBlockSupportResource('tree_collapse_all.png');

            pButtonPanel.Type='panel';
            pButtonPanel.Items={pExpandButton,pCollapseButton};
            pButtonPanel.RowSpan=[1,1];
            pButtonPanel.ColSpan=[1,1];
        end

        function pSpreadsheet=i_GetArgumentTreeTabsHierarchySpreadsheet(this,widgetVisible)
            pSpreadsheet.Tag='ModelRefArgumentsDDGTreeSpreadsheet';
            pSpreadsheet.Type='spreadsheet';
            pSpreadsheet.Columns=this.hierarchySpreadsheetColmnTitles;
            pSpreadsheet.SortColumn=this.hierarchySpreadsheetDefaultSortBy;
            pSpreadsheet.SortOrder=true;
            pSpreadsheet.RowSpan=[1,1];
            pSpreadsheet.ColSpan=[2,2];
            pSpreadsheet.Source=Simulink.ModelReference.internal.HierarchySpreadsheet(this.source,this.isSlimDialog);
            pSpreadsheet.Hierarchical=true;
            pSpreadsheet.Visible=widgetVisible;
            pSpreadsheet.DialogRefresh=true;
            pSpreadsheet.Config='{"expandall": true, "enablemultiselect" : true, "emptyparentinfiltermode" : false}';
            pSpreadsheet.ContextMenuCallback=@(tag,sels,dlg)this.onContextMenuCallBack(sels,dlg);
            pSpreadsheet.ValueChangedCallback=@(hss,r,n,v,d)onSpreadsheetChanged(r,n,v,d,pSpreadsheet.Source);
            function onSpreadsheetChanged(row,name,value,dlg,hss)
                hss.onSpreadsheetChanged(row,name,value,dlg);
            end
        end

        function[thisTab]=i_GetArgumentTreeTabs(this)
            thisTab.Tag='TabOfParameterArgumentValues';
            thisTab.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefModelParametersToggle');

            rowIdx=1;
            try
                aInstSpecParam=get_param(this.blockHandle,'InstanceParameters');
                modelExist=strcmp(get_param(this.blockHandle,'MdlRefModelIsFound'),'on');
            catch me
                aInstSpecParam={};
                modelExist=false;
                this.noArgsText=me.message;
            end
            widgetVisible=(~isempty(aInstSpecParam))&&modelExist;

            pNoArgs.Tag='ModelRefArgumentsNoArgumentsText';
            pNoArgs.Type='text';
            pNoArgs.Name=this.noArgsText;
            pNoArgs.Enabled=true;
            pNoArgs.Visible=~widgetVisible;
            pNoArgs.RowSpan=[1,1];
            pNoArgs.ColSpan=[1,1];
            pNoArgs.WordWrap=true;

            pSearch.Tag='ModelRefArgumentsDDGTreeSpreadsheetSearch';
            pSearch.Type='spreadsheetfilter';
            pSearch.RowSpan=[1,1];
            pSearch.ColSpan=[1,1];
            pSearch.TargetSpreadsheet='ModelRefArgumentsDDGTreeSpreadsheet';
            pSearch.PlaceholderText=DAStudio.message('Simulink:dialog:ModelRefArgsTableSearchPrompt');
            pSearch.Visible=widgetVisible;
            pSearch.Clearable=true;

            pSpreadsheetButtonPanel=this.i_GetArgumentTreeTabsButtonPanel(widgetVisible);
            pSpreadsheet=this.i_GetArgumentTreeTabsHierarchySpreadsheet(widgetVisible);

            rowIdx=rowIdx+1;

            pSpreadsheetGrp.Type='panel';
            pSpreadsheetGrp.LayoutGrid=[1,2];
            pSpreadsheetGrp.RowSpan=[rowIdx,rowIdx];
            pSpreadsheetGrp.Items={pSpreadsheetButtonPanel,pSpreadsheet};
            pSpreadsheetGrp.Enabled=widgetVisible;




            aDlgs=DAStudio.ToolRoot.getOpenDialogs(this.source);
            for i=1:length(aDlgs)
                aDlg=aDlgs(i);
                aDlg.refreshWidget(pSpreadsheet.Tag);
            end

            pPanel.Tag='ModelRefArgumentsDDGTreePanel';
            pPanel.Type='panel';
            if widgetVisible
                pPanel.Items={pSearch,pSpreadsheetGrp};
            else
                pPanel.Items={pNoArgs};
            end
            pPanel.Visible=true;
            pPanel.Enabled=mdlrefddg_cb('EnableParamArgValues',this.source);

            thisTab.Items={pPanel};
        end

        function expandCallBack(~,sels,dlg)
            ssWidget=dlg.getWidgetInterface('ModelRefArgumentsDDGTreeSpreadsheet');
            ssWidget.expand(sels,true);
        end

        function collapseCallBack(~,sels,dlg)
            ssWidget=dlg.getWidgetInterface('ModelRefArgumentsDDGTreeSpreadsheet');
            ssWidget.collapse(sels,true);
        end

        function actionStructs=onContextMenuCallBack(this,sels,dlg)
            if isempty(sels.m_Name)
                callback1=@(tag)this.expandCallBack(sels,dlg);
                actionStructs=struct('label','Expand All','enabled',true,'command',callback1);

                callback2=@(tag)this.collapseCallBack(sels,dlg);
                actionStructs(end+1)=struct('label','Collapse All','enabled',true,'command',callback2);
            end
        end
    end
end

