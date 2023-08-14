classdef cosimBlockddg_InstParamTab<handle




    properties

        expandButtonToolTip=DAStudio.message('Simulink:dialog:ExpandAllItemsTip');
        collapseButtonToolTip=DAStudio.message('Simulink:dialog:CollapseAllItemsTip');
        ddgCallbackMethod='cosimBlockddg_cb';

        spreadsheetColumnTitles={DAStudio.message('Simulink:dialog:ModelRefArgsTableSourceColumn');...
        DAStudio.message('Simulink:dialog:ModelRefArgsTableValueColumn');...
        DAStudio.message('Simulink:dialog:ModelRefArgsTableInstanceSpecificCheckBoxColumn');};
        spreadsheetDefaultSortBy=DAStudio.message('Simulink:dialog:ModelRefArgsTableSourceColumn');

        noArgsText=DAStudio.message('Simulink:dialog:ModelRefArgsTableNoData');

        source=[];
        isSlimDialog=[];
        blockHandle=[];
    end

    methods(Access=public)
        function this=cosimBlockddg_InstParamTab(source,isSlimDialog)
            this.source=source;
            this.isSlimDialog=isSlimDialog;
            this.blockHandle=this.source.getBlock().Handle;
        end

        function cosimBlkInstParamTab=getInstParamTab(this)
            cosimBlkInstParamTab=this.i_GetArgumentTreeTabs();
        end
    end

    methods(Access=private)
        function pButtonPanel=i_GetArgumentTreeTabsButtonPanel(this,widgetVisible)

            pExpandButton.Tag='cosim_ExpandAllButton';
            pExpandButton.Type='pushbutton';
            pExpandButton.RowSpan=[1,1];
            pExpandButton.ColSpan=[1,1];
            pExpandButton.Enabled=cosimBlockddg_cb('EnableParamArgValues',this.source);
            pExpandButton.ToolTip=this.expandButtonToolTip;
            pExpandButton.MatlabMethod=this.ddgCallbackMethod;
            pExpandButton.MatlabArgs={'doExpandAll','%dialog'};
            pExpandButton.Visible=widgetVisible;
            pExpandButton.FilePath=getBlockSupportResource('tree_expand_all.png');

            pCollapseButton.Tag='cosim_CollapseAllButton';
            pCollapseButton.Type='pushbutton';
            pCollapseButton.RowSpan=[2,2];
            pCollapseButton.ColSpan=[1,1];
            pCollapseButton.Enabled=cosimBlockddg_cb('EnableParamArgValues',this.source);
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

        function pSpreadsheet=i_GetArgumentTreeTabsSpreadsheet(this,widgetVisible)
            pSpreadsheet.Tag='cosim_ArgumentSpreadsheet';
            pSpreadsheet.Type='spreadsheet';
            pSpreadsheet.Columns=this.spreadsheetColumnTitles;
            pSpreadsheet.SortColumn=this.spreadsheetDefaultSortBy;
            pSpreadsheet.SortOrder=true;
            pSpreadsheet.RowSpan=[1,1];
            pSpreadsheet.ColSpan=[2,2];
            pSpreadsheet.Source=Simulink.cosimblock.internal.InstParamSpreadsheet(this.source,this.isSlimDialog);
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
            thisTab.Tag='cosim_ArgumentTab';
            thisTab.Name=DAStudio.message('Simulink:blkprm_prompts:ModelRefModelParametersToggle');

            rowIdx=1;
            try
                aInstSpecParam=get_param(this.blockHandle,'InstanceParameters');
                modelExist=strcmp(get_param(this.blockHandle,'TargetIsFound'),'on');
            catch me
                aInstSpecParam={};
                modelExist=false;
                this.noArgsText=me.message;
            end
            widgetVisible=(~isempty(aInstSpecParam))&&modelExist;

            pNoArgs.Tag='cosim_NoArgumentsText';
            pNoArgs.Type='text';
            pNoArgs.Name=this.noArgsText;
            pNoArgs.Enabled=true;
            pNoArgs.Visible=~widgetVisible;
            pNoArgs.RowSpan=[1,1];
            pNoArgs.ColSpan=[1,1];
            pNoArgs.WordWrap=true;

            pSearch.Tag='cosim_ArgumentSpreadsheetSearch';
            pSearch.Type='spreadsheetfilter';
            pSearch.RowSpan=[1,1];
            pSearch.ColSpan=[1,1];
            pSearch.TargetSpreadsheet='cosim_ArgumentSpreadsheet';
            pSearch.PlaceholderText=DAStudio.message('Simulink:dialog:ModelRefArgsTableSearchPrompt');
            pSearch.Visible=widgetVisible;
            pSearch.Clearable=true;

            pSpreadsheetButtonPanel=this.i_GetArgumentTreeTabsButtonPanel(widgetVisible);
            pSpreadsheet=this.i_GetArgumentTreeTabsSpreadsheet(widgetVisible);

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

            pPanel.Tag='cosim_ArgumentsPanel';
            pPanel.Type='panel';
            if widgetVisible
                pPanel.Items={pSearch,pSpreadsheetGrp};
            else
                pPanel.Items={pNoArgs};
            end
            pPanel.Visible=true;
            pPanel.Enabled=cosimBlockddg_cb('EnableParamArgValues',this.source);

            thisTab.Items={pPanel};
        end

        function expandCallBack(~,sels,dlg)
            ssWidget=dlg.getWidgetInterface('cosim_ArgumentSpreadsheet');
            ssWidget.expand(sels,true);
        end

        function collapseCallBack(~,sels,dlg)
            ssWidget=dlg.getWidgetInterface('cosim_ArgumentSpreadsheet');
            ssWidget.collapse(sels,true);
        end

        function menu=onContextMenuCallBack(this,sels,dlg)
            menu=DAStudio.UI.Widgets.Menu;
            if isempty(sels.m_Name)
                menuItem1=DAStudio.UI.Widgets.MenuItem;
                menuItem1.name='Expand All';
                menuItem1.enabled=true;
                menuItem1.callback=@(tag)this.expandCallBack(sels,dlg);
                menu.addMenuItem(menuItem1);

                menuItem2=DAStudio.UI.Widgets.MenuItem;
                menuItem2.name='Collapse All';
                menuItem2.enabled=true;
                menuItem2.callback=@(tag)this.collapseCallBack(sels,dlg);
                menu.addMenuItem(menuItem2);
            end
        end
    end
end

