classdef BreakpointListSpreadsheet<handle





    properties
        data_;
        mdl_;
        columns_;
        component_;
        studio_;
        globalBpList_;
        hitCountMap_;
        msgCatalogCache_;
        currHitIdx_;
        refreshBPListenerHandle_=[];
        srcToBeHighlighted_=[];
    end

    properties(Constant)
        name_='Global Breakpoints Spreadsheet';
    end

    methods(Static,Access=public)
        function ssComp=createSpreadSheetComponent(studio,bpListInstance,toggleClosedIfAlreadyOpen)
            if nargin<3
                toggleClosedIfAlreadyOpen=true;
            end
            ssComp=studio.getComponent('GLUE2:SpreadSheet',SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.name_);
            if isempty(ssComp)
                ssComp=GLUE2.SpreadSheetComponent(studio,SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.name_);
                studio.registerComponent(ssComp);
                bdHandle=studio.App.blockDiagramHandle;
                mdlName=get_param(bdHandle,'Name');
                obj=SimulinkDebugger.breakpoints.BreakpointListSpreadsheet(mdlName,ssComp,studio,bpListInstance);
                ssComp.setTitleViewSource(obj);
                ssComp.setConfig('{"updateoneditorchanges":true}');
            else
                if~ssComp.isVisible
                    studio.showComponent(ssComp);
                    studio.focusComponent(ssComp);
                elseif toggleClosedIfAlreadyOpen
                    studio.hideComponent(ssComp);
                else
                    studio.focusComponent(ssComp);
                end
            end
        end

        function moveComponentToDock(ssComp,studio)
            compTitle=DAStudio.message(...
            'Simulink:Debugger:BreakpointList');
            studio.moveComponentToDock(ssComp,compTitle,'Bottom','Tabbed');
        end

        function deleteButtonCB(src)



            currSelected=src.component_.imSpreadSheetComponent.getSelection();
            for idx=1:numel(currSelected)
                currSelected{idx}.deleteButtonCBImpl(src);
            end
            src.refreshBpUI();
        end

        function enableDisableAllButtonCB(src)


            allRows=src.data_;
            allEnabled=true;

            propValueName=DAStudio.message('Simulink:Debugger:SSColumn_Enabled');
            for idx=1:numel(allRows)
                if~isequal(allRows(idx).getPropValue(propValueName),'1')
                    allEnabled=false;
                    break;
                end
            end

            if allEnabled
                setToEnabled=false;
            else
                setToEnabled=true;
            end
            for idx=1:numel(allRows)
                allRows(idx).setPropValue(propValueName,setToEnabled)
            end

            src.refreshBpUI();
        end

        function openSfListButtonCB(~)
            Stateflow.Debug.SFDebuggerGUI.showDebugger();
        end

    end

    methods
        function this=BreakpointListSpreadsheet(modelname,comp,studio,bpListInstance)
            this.globalBpList_=bpListInstance;
            this.msgCatalogCache_=SimulinkDebugger.CachedMessageAccessor.getInstance();
            enabledName=this.msgCatalogCache_.enabledName_;
            sourceName=this.msgCatalogCache_.sourceName_;
            typeName=this.msgCatalogCache_.typeName_;
            conditionName=this.msgCatalogCache_.conditionName_;
            hitsName=this.msgCatalogCache_.hitsName_;
            this.columns_={enabledName,sourceName,typeName,conditionName,hitsName};
            this.mdl_=modelname;
            this.component_=comp;
            this.studio_=studio;
            this.component_.setColumns(this.columns_,enabledName,'',false);
            this.component_.setSource(this);
            this.component_.setEmptyListMessage(DAStudio.message(...
            'Simulink:Debugger:BreakpointListEmpty'));
            this.hitCountMap_=containers.Map;
            this.currHitIdx_=1;


            if isempty(this.refreshBPListenerHandle_)
                this.refreshBPListenerHandle_=addlistener(bpListInstance,...
                'RefreshBreakpointUI',...
                @(src,event)this.refreshBpUI(src,event));
            end

        end

        function refreshBpUI(this,~,~)
            if~isvalid(this.studio_)
                return;
            end
            ssComp=this.studio_.getComponent('GLUE2:SpreadSheet',...
            SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.name_);
            if~isempty(ssComp)
                ssComp.update();
            end
        end

        function addSrcToBeRefreshed(this,portH)
            this.srcToBeHighlighted_=portH;


            this.refreshBpUI();
        end

        function children=getChildren(this,~)




            breakpointIdx=1;
            [children,breakpointIdx]=SimulinkDebugger.breakpoints.getSignalBreakpointRows(...
            this,breakpointIdx,this.srcToBeHighlighted_);


            globalBreakpoints=this.globalBpList_.getBreakpoints();
            [blockBreakpoints,breakpointIdx]=SimulinkDebugger.breakpoints.getBlockBreakpointRows(...
            globalBreakpoints,this.studio_,this.hitCountMap_,children,breakpointIdx);
            children=[children,blockBreakpoints];


            [modelBreakpoints,breakpointIdx]=SimulinkDebugger.breakpoints.getModelBreakpointRows(...
            globalBreakpoints,this.studio_,children,breakpointIdx);
            children=[children,modelBreakpoints];

            [sfBreakPoints,~]=SimulinkDebugger.breakpoints.getSFBreakpointRows(...
            this.mdl_,breakpointIdx,this.srcToBeHighlighted_);
            children=[children,sfBreakPoints];
            this.data_=children;



            this.srcToBeHighlighted_=[];
        end

        function incrementHitCount(this,bpid)
            if this.hitCountMap_.isKey(bpid)
                this.hitCountMap_(bpid)=this.hitCountMap_(bpid)+1;
            else
                this.hitCountMap_(bpid)=1;
            end
        end

        function resetHitCount(this)
            this.hitCountMap_.remove(this.hitCountMap_.keys)
        end

        function dlgStruct=getDialogSchema(~,~)
            enableDisableAllButton.Type='splitbutton';
            enableDisableAllButton.Tag='bplist_enable_disable_all_bp';
            enableDisableAllButton.ToolTip=DAStudio.message('Simulink:Debugger:EnableDisableAll');
            enableDisableAllButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','enableDisable_16.png');
            enableDisableAllButton.RowSpan=[1,1];
            enableDisableAllButton.ColSpan=[1,1];
            enableDisableAllButton.ObjectMethod='';
            enableDisableAllButton.MethodArgs={'%dialog'};
            enableDisableAllButton.ArgDataTypes={'handle'};
            enableDisableAllButton.Enabled=true;
            enableDisableAllButton.MatlabMethod='SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.enableDisableAllButtonCB';
            enableDisableAllButton.MatlabArgs={'%source'};

            deleteButton.Type='splitbutton';
            deleteButton.Tag='bplist_delete_bp';
            deleteButton.ToolTip=DAStudio.message('Simulink:Debugger:ClearButtonToolTip');
            deleteButton.FilePath=fullfile(matlabroot,'toolbox',...
            'shared','dastudio','resources','removeBP_16.png');
            deleteSelectionAction=SimulinkDebugger.breakpoints.DeleteSplitButtonActionBuilder(DAStudio.message('Simulink:Debugger:ClearButtonToolTip'),'','deleteSelectionAction');
            deleteAllAction=SimulinkDebugger.breakpoints.DeleteSplitButtonActionBuilder(DAStudio.message('Simulink:Debugger:ClearAllInList'),'','deleteAllAction');
            deleteButton.ActionEntries={deleteSelectionAction,deleteAllAction};
            deleteButton.ActionCallback=@actionCallback;
            deleteButton.DefaultAction='deleteSelectionAction';
            deleteButton.UseButtonStyleForDefaultAction=true;
            deleteButton.RowSpan=[1,1];
            deleteButton.ColSpan=[2,2];
            deleteButton.ObjectMethod='';
            deleteButton.MethodArgs={'%dialog'};
            deleteButton.ArgDataTypes={'handle'};
            deleteButton.Enabled=true;
            deleteButton.MatlabMethod='SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.deleteButtonCB';
            deleteButton.MatlabArgs={'%source'};
            deleteButton.PreferredSize=[40,27];
            OpenSfBpListButton.Type='splitbutton';
            OpenSfBpListButton.Tag='open_sf_list_bp';
            OpenSfBpListButton.ToolTip=DAStudio.message('Simulink:Debugger:OpenSFButtonToolTip');
            OpenSfBpListButton.FilePath=fullfile(matlabroot,'toolbox',...
            'stateflow','ui','studio','config','icons','breakpointListStateflowChart_16.png');
            OpenSfBpListButton.RowSpan=[1,1];
            OpenSfBpListButton.ColSpan=[3,3];
            OpenSfBpListButton.ObjectMethod='';
            OpenSfBpListButton.MethodArgs={'%dialog'};
            OpenSfBpListButton.ArgDataTypes={'handle'};
            OpenSfBpListButton.Enabled=true;
            OpenSfBpListButton.MatlabMethod='SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.openSfListButtonCB';
            OpenSfBpListButton.MatlabArgs={'%source'};

            filterWidget.Type='spreadsheetfilter';
            filterWidget.Tag='spreadsheetfilterWidget';
            filterWidget.PlaceholderText=DAStudio.message('Simulink:Debugger:FilterSpreadsheet');
            filterWidget.TargetSpreadsheet=SimulinkDebugger.breakpoints.BreakpointListSpreadsheet.name_;
            filterWidget.Clearable=true;
            filterWidget.RowSpan=[1,1];
            filterWidget.ColSpan=[7,7];
            filterWidget.Alignment=4;

            titlePanel.Type='panel';
            titlePanel.Items={enableDisableAllButton,deleteButton,OpenSfBpListButton,filterWidget};
            titlePanel.LayoutGrid=[1,7];
            titlePanel.ColStretch=[0,0,0,0,0,1,0];

            dlgStruct.LayoutGrid=[1,1];
            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.Items={titlePanel};
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};

            function actionCallback(dlg,~,actiontag)
                src=dlg.getDialogSource();
                if isequal(actiontag,'deleteSelectionAction')

                    currSelected=src.component_.imSpreadSheetComponent.getSelection();
                    for idx=1:numel(currSelected)
                        currSelected{idx}.deleteButtonCBImpl(src);
                    end
                elseif isequal(actiontag,'deleteAllAction')

                    allRows=src.data_;
                    for idx=1:numel(allRows)
                        allRows(idx).deleteButtonCBImpl(src);
                    end
                end
                dlg.getDialogSource().refreshBpUI();
            end
        end
    end

end


