classdef LibraryLinkTool<handle

    properties
        m_modelName;
        m_modelHandle;
        m_ActiveTab;
        m_link_status_change_listener;
        m_add_block_event_listener;
        m_remove_block_event_listener;
        m_parameterized_link_change_listener;
    end

    methods

        function obj=LibraryLinkTool(modelName,activeTab)
            obj.m_modelName=modelName;
            obj.m_modelHandle=get_param(modelName,'Handle');
            obj.m_ActiveTab=activeTab;

            bdCosObj=get_param(obj.m_modelHandle,'InternalObject');

            Simulink.addBlockDiagramCallback(obj.m_modelHandle,'PreClose',...
            'editedlinkstool',...
            @()editedlinkstool('Delete',obj.m_modelName),true);

            obj.m_link_status_change_listener=addlistener(bdCosObj,...
            'SLGraphicalEvent::BLOCK_LINK_STATUS_CHANGE_EVENT',...
            @(src,evnt)obj.onBlockLinkStatusChangeCallback(src,evnt,'','',''));

            obj.m_add_block_event_listener=addlistener(bdCosObj,...
            'SLGraphicalEvent::ADD_BLOCK_HIERARCHY_MODEL_EVENT',...
            @(src,evnt)obj.onAddBlockCallback(src,evnt,'',''));

            obj.m_remove_block_event_listener=addlistener(bdCosObj,...
            'SLGraphicalEvent::REMOVE_BLOCK_MODEL_EVENT',...
            @(src,evnt)obj.onRemoveBlockCallback(src,evnt,'',''));

            obj.m_parameterized_link_change_listener=addlistener(bdCosObj,...
            'SLGraphicalEvent::BLOCK_PARAMETERIZED_LINK_CHANGE_EVENT',...
            @(src,evnt)obj.onParameterizedLinkChangeCallback(src,evnt,'',''));

        end


        function dlgstruct=getDialogSchema(h)


            tabSpecificDesc.Name=DAStudio.message('Simulink:Libraries:LibraryLinkToolDisabledLinkDescriptionText');
            tabSpecificDesc.RowSpan=[2,2];
            tabSpecificDesc.Tag='LibraryLinkToolTabSpecificDescription';
            tabSpecificDesc.WordWrap=1;
            tabSpecificDesc.Type='text';


            descGroup.Type='group';
            descGroup.Name=DAStudio.message('Simulink:Libraries:LibraryLinkToolDescriptionLabel');
            descGroup.LayoutGrid=[1,1];
            descGroup.Items={tabSpecificDesc};


            pDisabledLinksTableFilter.Type='spreadsheetfilter';
            pDisabledLinksTableFilter.RowSpan=[1,1];
            pDisabledLinksTableFilter.ColSpan=[1,1];
            pDisabledLinksTableFilter.Tag='LinksToolDisabledLinksSpreadsheetFilter';
            pDisabledLinksTableFilter.TargetSpreadsheet='LinksToolSpreadsheet';
            pDisabledLinksTableFilter.PlaceholderText=DAStudio.message('Simulink:Libraries:LibraryLinkToolSpreadsheetFilterText');
            pDisabledLinksTableFilter.Clearable=true;


            bDisabledLinksTableSource=LibraryLinkToolSpreadsheet(h.m_modelName);
            bDisabledLinksTable.Type='spreadsheet';
            bDisabledLinksTable.Source=bDisabledLinksTableSource;
            bDisabledLinksTable.Columns=bDisabledLinksTableSource.m_Columns;
            bDisabledLinksTable.UserData=bDisabledLinksTableSource;
            bDisabledLinksTable.RowSpan=[2,19];
            bDisabledLinksTable.ColSpan=[1,1];
            bDisabledLinksTable.Hierarchical=true;
            bDisabledLinksTable.Enabled=true;
            bDisabledLinksTable.Editable=1;
            bDisabledLinksTable.Tag='LinksToolSpreadsheet';


            pParameterizedLinksTableFilter.Type='spreadsheetfilter';
            pParameterizedLinksTableFilter.RowSpan=[1,1];
            pParameterizedLinksTableFilter.ColSpan=[1,1];
            pParameterizedLinksTableFilter.Tag='LinksToolParameterizedLinksSpreadsheetFilter';
            pParameterizedLinksTableFilter.TargetSpreadsheet='ParameterizedLinksSpreadsheet';
            pParameterizedLinksTableFilter.PlaceholderText=DAStudio.message('Simulink:Libraries:LibraryLinkToolSpreadsheetFilterText');
            pParameterizedLinksTableFilter.Clearable=true;



            bParameterizedLinksTableSource=LibraryToolParameterizedLinksSpreadsheet(h.m_modelName);
            bParameterizedLinksTable.Type='spreadsheet';
            bParameterizedLinksTable.Source=bParameterizedLinksTableSource;
            bParameterizedLinksTable.Columns=bParameterizedLinksTableSource.m_Columns;
            bParameterizedLinksTable.UserData=bParameterizedLinksTableSource;
            bParameterizedLinksTable.Hierarchical=true;
            bParameterizedLinksTable.RowSpan=[2,19];
            bParameterizedLinksTable.ColSpan=[1,1];
            bParameterizedLinksTable.Enabled=true;
            bParameterizedLinksTable.Editable=0;
            bParameterizedLinksTable.Tag='ParameterizedLinksSpreadsheet';


            bPush.Name=DAStudio.message('Simulink:Libraries:LibraryLinkToolPushButton');
            bPush.Type='pushbutton';
            bPush.RowSpan=[1,1];
            bPush.ColSpan=[5,5];
            bPush.Enabled=false;
            bPush.ToolTip=DAStudio.message('Simulink:Libraries:LibraryLinkToolPushButtonTooltip');
            bPush.Tag='PushButton';
            bPush.MatlabMethod='LibraryLinkTool_ButtonCallbacks';
            bPush.MatlabArgs={'%dialog','doPush',bDisabledLinksTable.Tag};


            bRestore.Name=DAStudio.message('Simulink:Libraries:LibraryLinkToolRestoreButton');
            bRestore.Type='pushbutton';
            bRestore.RowSpan=[1,1];
            bRestore.ColSpan=[4,4];
            bRestore.Enabled=false;
            bRestore.ToolTip=DAStudio.message('Simulink:Libraries:LibraryLinkToolRestoreButtonTooltip');
            bRestore.Tag='RestoreButton';
            bRestore.MatlabMethod='LibraryLinkTool_ButtonCallbacks';
            bRestore.MatlabArgs={'%dialog','doRestore',bDisabledLinksTable.Tag};

            spacer1.Name='';
            spacer1.Type='text';
            spacer1.RowSpan=[1,1];
            spacer1.ColSpan=[2,3];



            bLibraryLinkHelp.Name=DAStudio.message('Simulink:Libraries:LibraryLinkToolDisabledLinkHelpButton');
            bLibraryLinkHelp.Type='pushbutton';
            bLibraryLinkHelp.RowSpan=[1,1];
            bLibraryLinkHelp.ColSpan=[1,1];
            bLibraryLinkHelp.ToolTip=DAStudio.message('Simulink:Libraries:LibraryLinkToolDisabledLinkHelpButtonTooltip');
            bLibraryLinkHelp.Tag='DisabledLinkHelpButton';
            bLibraryLinkHelp.MatlabMethod='LibraryLinkTool_ButtonCallbacks';
            bLibraryLinkHelp.MatlabArgs={'%dialog','doLibraryLinkHelp'};


            disabledButtonGroup.Type='group';
            disabledButtonGroup.LayoutGrid=[1,5];
            disabledButtonGroup.RowSpan=[20,20];
            disabledButtonGroup.ColSpan=[1,1];
            disabledButtonGroup.Items={bLibraryLinkHelp,spacer1,bPush,bRestore};



            bparameterizedPush.Name=DAStudio.message('Simulink:Libraries:LibraryLinkToolPushButton');
            bparameterizedPush.Type='pushbutton';
            bparameterizedPush.RowSpan=[1,1];
            bparameterizedPush.ColSpan=[5,5];
            bparameterizedPush.Enabled=false;
            bparameterizedPush.ToolTip=DAStudio.message('Simulink:Libraries:LibraryLinkToolPushButtonTooltip');
            bparameterizedPush.Tag='ParameterizedPushButton';
            bparameterizedPush.MatlabMethod='LibraryLinkTool_ButtonCallbacks';
            bparameterizedPush.MatlabArgs={'%dialog','doParameterizedPush',bParameterizedLinksTable.Tag};


            bparameterizedRestore.Name=DAStudio.message('Simulink:Libraries:LibraryLinkToolRestoreButton');
            bparameterizedRestore.Type='pushbutton';
            bparameterizedRestore.RowSpan=[1,1];
            bparameterizedRestore.ColSpan=[4,4];
            bparameterizedRestore.Enabled=false;
            bparameterizedRestore.ToolTip=DAStudio.message('Simulink:Libraries:LibraryLinkToolRestoreButtonTooltip');
            bparameterizedRestore.Tag='ParameterizedRestoreButton';
            bparameterizedRestore.MatlabMethod='LibraryLinkTool_ButtonCallbacks';
            bparameterizedRestore.MatlabArgs={'%dialog','doParameterizedRestore',bParameterizedLinksTable.Tag};


            parameterizedButtonGroup.Type='group';
            parameterizedButtonGroup.LayoutGrid=[1,5];
            parameterizedButtonGroup.RowSpan=[20,20];
            parameterizedButtonGroup.ColSpan=[1,1];
            parameterizedButtonGroup.Items={bLibraryLinkHelp,spacer1,bparameterizedPush,bparameterizedRestore};


            tab1.Name=DAStudio.message('Simulink:Libraries:LibraryLinkToolDisableLinkTabName');
            tab1.Items={pDisabledLinksTableFilter,bDisabledLinksTable,disabledButtonGroup};
            tab1.Tag='TabOne';



            tab2.Name=DAStudio.message('Simulink:Libraries:LibraryLinkToolParameterizedLinkTabName');
            tab2.Items={pParameterizedLinksTableFilter,bParameterizedLinksTable,parameterizedButtonGroup};
            tab2.Tag='TabTwo';


            tabcont.Type='tab';
            tabcont.Tabs={tab1,tab2};
            tabcont.Tag='LibraryLinkToolTabContainer';

            tabcont.TabChangedCallback='LibraryLinkToolTabChangedCallback';


            dlgstruct.DialogTitle=[DAStudio.message('Simulink:Libraries:LibraryLinkToolTitle'),' :  ',h.m_modelName];
            dlgstruct.CloseCallback='onLibraryLinkDialogCloseCallback';
            dlgstruct.CloseArgs={h,'%dialog',h.m_modelName};
            dlgstruct.StandaloneButtonSet={''};
            dlgstruct.Items={descGroup,tabcont};

        end

        function onLibraryLinkDialogCloseCallback(~,dialogHandle,model)
            editedlinkstool('Delete',model);
        end

        function onBlockLinkStatusChangeCallback(this,~,event,~,~,~)
            if is_simulink_handle(this.m_modelHandle)
                if isequal(event.Source.Name,get_param(this.m_modelHandle,'Name'))
                    dlgHandle=editedlinkstool('GetDialogHandle',this.m_modelHandle);
                    if ishandle(dlgHandle)
                        editedlinkstool('RefreshAllSpreadsheets',dlgHandle);
                    end
                end
            end
        end

        function onParameterizedLinkChangeCallback(this,~,event,~,~,~)
            if is_simulink_handle(this.m_modelHandle)
                if isequal(event.Source.Name,get_param(this.m_modelHandle,'Name'))
                    dlgHandle=editedlinkstool('GetDialogHandle',this.m_modelHandle);
                    if ishandle(dlgHandle)
                        this.HandleChangeInParameterizedSpreadsheet(dlgHandle,event.BlockHandle)
                    end
                end
            end
        end

        function onAddBlockCallback(this,~,event,~,~)
            modelName=get_param(this.m_modelHandle,'Name');
            if isequal(event.Source.Name,modelName)
                dlgHandle=editedlinkstool('GetDialogHandle',this.m_modelHandle);
                if isequal(get_param(event.BlockHandle,'LinkStatus'),'inactive')...
                    ||~isempty(get_param(event.BlockHandle,'LinkData'))...
                    ||isequal(get_param(modelName,'BlockDiagramType'),'subsystem')
                    if ishandle(dlgHandle)
                        editedlinkstool('RefreshAllSpreadsheets',dlgHandle);
                    end
                end
            end
        end

        function HandleChangeInParameterizedSpreadsheet(this,dlgHandle,block)
            linkdata=get_param(block,'LinkData');
            parameterizedBlockName=getfullname(block);
            spreadsheet=dlgHandle.getUserData('ParameterizedLinksSpreadsheet');
            newChildren=spreadsheet.ParameterizedSpreadsheetDeleteRow(spreadsheet,parameterizedBlockName);

            if~isempty(linkdata)
                totSize=0;
                for k=1:length(linkdata)
                    linkDataChild=linkdata(k);
                    dialogParameters=linkDataChild.DialogParameters;
                    parameterNames=fieldnames(dialogParameters);
                    totSize=totSize+length(parameterNames);
                end
                parameterizedBlockHandle=block;
                subChildren=spreadsheet.getSubChildren(parameterizedBlockHandle,linkdata,totSize);
                parameterizedBlockChild=LibraryToolParameterizedLinksSpreadsheetRow(parameterizedBlockHandle,parameterizedBlockName,'',' ',' ',subChildren,'1');
                if isempty(newChildren)
                    newChildren=repmat(LibraryToolParameterizedLinksSpreadsheetRow(),1);
                    newChildren=parameterizedBlockChild;
                else
                    newChildren(end+1)=parameterizedBlockChild;
                end

            end

            spreadsheet.m_Children=newChildren;
            dlgHandle.setUserData('ParameterizedLinksSpreadsheet',spreadsheet);
            spreadsheet.updateUI(dlgHandle,'ParameterizedLinksSpreadsheet');
        end

        function onRemoveBlockCallback(this,~,event,~,~)
            if isequal(event.Source.Name,get_param(this.m_modelHandle,'Name'))
                dlgHandle=editedlinkstool('GetDialogHandle',this.m_modelHandle);
                if ishandle(dlgHandle)
                    blockName=getfullname(event.BlockHandle);
                    if isequal(get_param(event.BlockHandle,'LinkStatus'),'inactive')
                        spreadsheet=dlgHandle.getUserData('LinksToolSpreadsheet');
                        newSpreadsheet=spreadsheet.disabledSpreadsheetDeleteRow(spreadsheet,blockName);
                        dlgHandle.setUserData('LinksToolSpreadsheet',newSpreadsheet);
                        newSpreadsheet.updateUI(dlgHandle,'LinksToolSpreadsheet');
                    elseif~isempty(get_param(event.BlockHandle,'LinkData'))
                        spreadsheet=dlgHandle.getUserData('ParameterizedLinksSpreadsheet');
                        newChildren=spreadsheet.ParameterizedSpreadsheetDeleteRow(spreadsheet,blockName);
                        spreadsheet.m_Children=newChildren;
                        dlgHandle.setUserData('ParameterizedLinksSpreadsheet',spreadsheet);
                        spreadsheet.updateUI(dlgHandle,'ParameterizedLinksSpreadsheet');
                    end
                end
            end
        end

        function onModelCloseCallback(this,~,event,~,~)
            if is_simulink_handle(this.m_modelHandle)
                if isequal(event.Source.Name,get_param(this.m_modelHandle,'Name'))
                    dlgHandle=editedlinkstool('GetDialogHandle',this.m_modelHandle);
                    if ishandle(dlgHandle)
                        dlgHandle.delete();
                    end
                end
            end
        end
    end
end
