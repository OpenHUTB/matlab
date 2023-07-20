classdef IRTInfoTab<swarch.internal.spreadsheet.FunctionInfoTab





    properties(Constant,Access=protected)
        FunctionType=[systemcomposer.architecture.model.swarch.FunctionType.Initialize
        systemcomposer.architecture.model.swarch.FunctionType.Terminate
        systemcomposer.architecture.model.swarch.FunctionType.Reset];
        DefaultName='Initialize';
    end

    methods(Access=protected)
        function newFunction=createFunctionDataSource(this,functionObj)
            newFunction=swarch.internal.spreadsheet.IRTInfoDataSource(this,functionObj);
        end
    end

    methods
        function columns=getColumnNames(~)
            columns={...
            getString(message('SoftwareArchitecture:ArchEditor:FunctionNameColumn'))...
            ,getString(message('SoftwareArchitecture:ArchEditor:SoftwareComponentColumn'))...
            ,getString(message('SoftwareArchitecture:ArchEditor:FunctionTypeColumn'))};
        end

        function tabName=getTabName(~)
            tabName=getString(message('SoftwareArchitecture:ArchEditor:IRTTabName'));
        end


        function dlgStruct=getDialogSchema(this,~)

            addFunctionButton.Type='pushbutton';
            addFunctionButton.FilePath=this.getIconPath('plusIcon_16.png');
            addFunctionButton.MatlabMethod='swarch.internal.spreadsheet.addFunctionToArchitecture';
            addFunctionButton.MatlabArgs={this};
            addFunctionButton.RowSpan=[1,1];
            addFunctionButton.ColSpan=[1,1];
            addFunctionButton.Tag='addIRTButtonTag';
            addFunctionButton.ToolTip=getString(...
            message('SoftwareArchitecture:ArchEditor:addIRTToolTip'));
            addFunctionButton.Alignment=2;


            removeAllowed=all(cellfun(@(f)~f.isReadOnly(),this.getCurrentSelection()));
            removeFunctionButton.Type='pushbutton';
            removeFunctionButton.FilePath=this.getIconPath('minusIcon_16.png');
            removeFunctionButton.MatlabMethod='swarch.internal.spreadsheet.removeFunctionFromArchitecture';
            removeFunctionButton.MatlabArgs={this};
            removeFunctionButton.RowSpan=[1,1];
            removeFunctionButton.ColSpan=[2,2];
            removeFunctionButton.Tag='removeIRTButtonTag';
            if removeAllowed
                removeFunctionButton.ToolTip=getString(...
                message('SoftwareArchitecture:ArchEditor:removeIRTToolTip'));
            else
                removeFunctionButton.ToolTip=getString(...
                message('SoftwareArchitecture:ArchEditor:disabledRemoveFunctionToolTip'));
            end
            removeFunctionButton.Alignment=2;
            removeFunctionButton.Enabled=removeAllowed;


            buttonPanel.Type='panel';
            buttonPanel.Items={addFunctionButton,removeFunctionButton};
            buttonPanel.LayoutGrid=[1,3];
            buttonPanel.ColStretch=[0,0,1];
            buttonPanel.RowStretch=0;
            buttonPanel.RowSpan=[1,1];
            buttonPanel.ColSpan=[1,1];


            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.DialogMode='Slim';
            dlgStruct.Items={buttonPanel};
            dlgStruct.DialogTag='IRT_button_panel_dlg';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end
    end
end


