classdef InternalFunctionInfoTab<swarch.internal.spreadsheet.FunctionInfoTab





    properties(Constant,Access=protected)
        FunctionType=[systemcomposer.architecture.model.swarch.FunctionType.OSFunction,...
        systemcomposer.architecture.model.swarch.FunctionType.Server,...
        systemcomposer.architecture.model.swarch.FunctionType.Message];

        DefaultName='Function';
    end

    properties
        RootFunctionsDirtyListener;
    end

    methods(Access=protected)
        function newFunction=createFunctionDataSource(this,functionObj)
            newFunction=swarch.internal.spreadsheet.InternalFunctionDataSource(this,functionObj);
        end
    end

    methods
        function initForCurrentEditor(this)
            if~isempty(this.RootFunctionsDirtyListener)
                delete(this.RootFunctionsDirtyListener);
            end

            slObj=get_param(this.getSpreadsheet().getBdHandle(),'InternalObject');
            this.RootFunctionsDirtyListener=addlistener(...
            slObj,'SLGraphicalEvent::MODEL_PARAMETER_CHANGE_EVENT',@this.updateButtonColor);
        end

        function delete(this)
            delete(this.RootFunctionsDirtyListener);
        end

        function refresh=refreshButtonsOnSelectionChange(~)
            refresh=true;
        end

        function updateButtonColor(this,~,evt)
            if strcmpi(evt.ParameterName,'OrderFunctionsByDependency')

                this.getSpreadsheet().getComponent().update();
                this.getSpreadsheet().getComponent().updateTitleView();
            elseif strcmpi(evt.ParameterName,'RootFunctionsDirty')

                this.getSpreadsheet().getComponent().updateTitleView();
            end
        end

        function columns=getColumnNames(~)
            columns={...
            getString(message('SoftwareArchitecture:ArchEditor:ExecutionOrderColumn'))...
            ,getString(message('SoftwareArchitecture:ArchEditor:FunctionNameColumn'))...
            ,getString(message('SoftwareArchitecture:ArchEditor:SoftwareComponentColumn'))...
            ,getString(message('SoftwareArchitecture:ArchEditor:PeriodColumn'))};

            if slfeature('SoftwareModeling')>0
                columns{end+1}=getString(message('SoftwareArchitecture:ArchEditor:MappedToColumn'));
            end
        end

        function tabName=getTabName(~)
            tabName=getString(message('SoftwareArchitecture:ArchEditor:InternalFunctionTabName'));
        end

        function[cols,sortCol,groupCol,ascending]=getColumnInfo(this)

            cols=this.getColumnNames();
            sortCol=getString(message('SoftwareArchitecture:ArchEditor:ExecutionOrderColumn'));
            groupCol='';
            ascending=true;
        end


        function dlgStruct=getDialogSchema(this,~)





            colSpanIdx=1;
            addFunctionButton.Type='pushbutton';
            addFunctionButton.FilePath=this.getIconPath('plusIcon_16.png');
            addFunctionButton.MatlabMethod='swarch.internal.spreadsheet.addFunctionToArchitecture';
            addFunctionButton.MatlabArgs={this};
            addFunctionButton.RowSpan=[1,1];
            addFunctionButton.ColSpan=[colSpanIdx,colSpanIdx];
            addFunctionButton.Tag='addFunctionButtonTag';
            addFunctionButton.ToolTip=getString(...
            message('SoftwareArchitecture:ArchEditor:addFunctionToolTip'));
            addFunctionButton.Alignment=2;


            currSel=this.getCurrentSelection();
            removeAllowed=~isempty(currSel)&&all(cellfun(@(f)~f.isReadOnly(),currSel));
            removeFunctionButton.Type='pushbutton';
            removeFunctionButton.FilePath=this.getIconPath('minusIcon_16.png');
            removeFunctionButton.MatlabMethod='swarch.internal.spreadsheet.removeFunctionFromArchitecture';
            removeFunctionButton.MatlabArgs={this};
            removeFunctionButton.RowSpan=[1,1];
            removeFunctionButton.ColSpan=[2,2];
            removeFunctionButton.Tag='removeFunctionButtonTag';
            if removeAllowed
                removeFunctionButton.ToolTip=getString(...
                message('SoftwareArchitecture:ArchEditor:removeFunctionToolTip'));
            else
                removeFunctionButton.ToolTip=getString(...
                message('SoftwareArchitecture:ArchEditor:disabledRemoveFunctionToolTip'));
            end
            removeFunctionButton.Alignment=2;
            removeFunctionButton.Enabled=removeAllowed;

            colSpanIdx=3;








            moveUpAllowed=true;
            moveDownAllowed=true;
            osFunctions=this.getRootArchitecture().getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).getFunctionsOfType(...
            this.FunctionType);
            currentSel=this.getCurrentSelection();
            if strcmp(get_param(this.getBdHandle(),'OrderFunctionsByDependency'),'on')
                moveUpAllowed=false;
                moveDownAllowed=false;
            elseif~isempty(osFunctions)&&~isempty(currentSel)

                moveUpAllowed=currentSel{1}.get().executionOrder~=1;
                moveDownAllowed=currentSel{1}.get().executionOrder~=numel(osFunctions);
            end


            moveFunctionUpButton.Type='pushbutton';
            moveFunctionUpButton.FilePath=this.getIconPath('sortUpIcon_16.png');
            moveFunctionUpButton.MatlabMethod='swarch.internal.spreadsheet.modifyFunctionOrder';
            moveFunctionUpButton.MatlabArgs={this,-1};
            moveFunctionUpButton.RowSpan=[1,1];
            moveFunctionUpButton.ColSpan=[colSpanIdx,colSpanIdx];
            moveFunctionUpButton.Tag='moveFunctionUpButtonTag';
            moveFunctionUpButton.ToolTip=getString(...
            message('SoftwareArchitecture:ArchEditor:moveFunctionUpToolTip'));
            moveFunctionUpButton.Enabled=moveUpAllowed;
            moveFunctionUpButton.DialogRefresh=1;
            moveFunctionUpButton.Alignment=2;
            colSpanIdx=colSpanIdx+1;


            moveFunctionDownButton.Type='pushbutton';
            moveFunctionDownButton.FilePath=this.getIconPath('sortDownIcon_16.png');
            moveFunctionDownButton.MatlabMethod='swarch.internal.spreadsheet.modifyFunctionOrder';
            moveFunctionDownButton.MatlabArgs={this,1};
            moveFunctionDownButton.RowSpan=[1,1];
            moveFunctionDownButton.ColSpan=[colSpanIdx,colSpanIdx];
            moveFunctionDownButton.Tag='moveFunctionDownButtonTag';
            moveFunctionDownButton.ToolTip=getString(...
            message('SoftwareArchitecture:ArchEditor:moveFunctionDownToolTip'));
            moveFunctionDownButton.Enabled=moveDownAllowed;
            moveFunctionDownButton.DialogRefresh=1;
            moveFunctionDownButton.Alignment=2;
            colSpanIdx=colSpanIdx+1;


            updateDiagramIcon=...
            fullfile(matlabroot,'toolbox','simulink','ui','studio','config','icons',...
            'Simulink_UpdateDiagram_16.png');
            if strcmpi(get_param(this.getBdHandle(),'RootFunctionsDirty'),'on')

                updateDiagramIcon=this.getIconPath('Simulink_UpdateDiagram_Glowing_16.png');
            end
            updateDiagramButton.FilePath=updateDiagramIcon;

            updateDiagramButton.Type='pushbutton';
            updateDiagramButton.MatlabMethod='swarch.internal.spreadsheet.updateDiagram';
            updateDiagramButton.MatlabArgs={this.getBdHandle()};
            updateDiagramButton.RowSpan=[1,1];
            updateDiagramButton.ColSpan=[colSpanIdx,colSpanIdx];
            updateDiagramButton.Tag='updateDiagramButtonTag';
            updateDiagramButton.ToolTip=...
            DAStudio.message('SoftwareArchitecture:ArchEditor:UpdateDiagramToolTip');
            updateDiagramButton.Alignment=2;

            colSpanIdx=colSpanIdx+1;


            dataDepOrderCheckbox.Type='checkbox';
            dataDepOrderCheckbox.Name=...
            DAStudio.message('SoftwareArchitecture:ArchEditor:SortFunctionsByDataDepToolTip');
            dataDepOrderCheckbox.MatlabMethod='swarch.internal.spreadsheet.setOrderFunctionsByDependency';
            dataDepOrderCheckbox.MatlabArgs={this.getBdHandle(),'%value'};
            dataDepOrderCheckbox.RowSpan=[1,1];
            dataDepOrderCheckbox.ColSpan=[colSpanIdx,colSpanIdx];
            dataDepOrderCheckbox.Value=...
            strcmp(get_param(this.getBdHandle(),'OrderFunctionsByDependency'),'on');
            dataDepOrderCheckbox.Tag='SortFunctionsByDataDepCheckBoxTag';
            dataDepOrderCheckbox.ToolTip=...
            DAStudio.message('SoftwareArchitecture:ArchEditor:SortFunctionsByDataDepToolTip');
            dataDepOrderCheckbox.DialogRefresh=1;
            dataDepOrderCheckbox.Mode=true;
            dataDepOrderCheckbox.Graphical=true;
            dataDepOrderCheckbox.Alignment=2;
            colSpanIdx=colSpanIdx+1;


            helpButton.FilePath=this.getIconPath('help_16.png');
            helpButton.Type='pushbutton';
            helpButton.MatlabMethod='swarch.internal.spreadsheet.launchHelp';
            helpButton.Tag='functionsEditorHelpButtonTag';
            helpButton.ToolTip=DAStudio.message('SoftwareArchitecture:ArchEditor:HelpButtonToolTip');
            helpButton.Alignment=7;


            buttonPanel.Type='panel';
            buttonPanel.Items={addFunctionButton,removeFunctionButton,...
            moveFunctionUpButton,moveFunctionDownButton,...
            updateDiagramButton,dataDepOrderCheckbox,...
            helpButton};
            buttonPanel.LayoutGrid=[1,colSpanIdx];
            buttonPanel.ColStretch=[zeros(1,colSpanIdx-1),1];
            buttonPanel.RowStretch=0;
            buttonPanel.RowSpan=[1,1];
            buttonPanel.ColSpan=[1,1];


            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.DialogMode='Slim';
            dlgStruct.Items={buttonPanel};
            dlgStruct.DialogTag='functions_button_panel_dlg';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end
    end
end


