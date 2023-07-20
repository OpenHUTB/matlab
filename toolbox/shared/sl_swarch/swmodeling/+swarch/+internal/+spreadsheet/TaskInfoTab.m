classdef TaskInfoTab<swarch.internal.spreadsheet.AbstractSoftwareModelingTab




    methods
        function this=TaskInfoTab(spreadSheetObj)
            this=this@swarch.internal.spreadsheet.AbstractSoftwareModelingTab(spreadSheetObj);
        end

        function columns=getColumnNames(~)
            columns={...
            getString(message('SoftwareArchitecture:ArchEditor:TaskNameColumn'))...
            ,getString(message('SoftwareArchitecture:ArchEditor:PeriodColumn'))...
            ,getString(message('SoftwareArchitecture:ArchEditor:NumFunctionsColumn'))};
        end

        function tabName=getTabName(~)
            tabName=getString(message('SoftwareArchitecture:ArchEditor:TaskTabName'));
        end

        function refreshChildren(this)
            tasks=this.getRootArchitecture().getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).p_Tasks.toArray;
            children=[];
            for idx=1:length(tasks)
                currTask=tasks(idx);
                children=[children,swarch.internal.spreadsheet.TaskInfoDataSource(this,currTask)];%#ok<AGROW>
            end
            this.pChildren=children;
        end

        function addChildToArchitecture(this)
            this.getRootArchitecture().getTrait(systemcomposer.architecture.model.swarch.PartitioningTrait.StaticMetaClass).createTask('Task');
        end

        function removeChildFromArchitecture(this,~)
            cellfun(@(s)s.get().destroy(),this.getCurrentSelection());
        end


        function dlgStruct=getDialogSchema(this,~)


            addTaskButton.Type='pushbutton';
            addTaskButton.FilePath=this.getIconPath('plusIcon_16.png');
            addTaskButton.MatlabMethod='swarch.internal.spreadsheet.addTaskToArchitecture';
            addTaskButton.MatlabArgs={this};
            addTaskButton.RowSpan=[1,1];
            addTaskButton.ColSpan=[1,1];
            addTaskButton.Tag='addTaskButtonTag';
            addTaskButton.ToolTip=getString(message('SoftwareArchitecture:ArchEditor:addTaskToolTip'));
            addTaskButton.Alignment=2;



            removeTaskButton.Type='pushbutton';
            removeTaskButton.FilePath=this.getIconPath('minusIcon_16.png');
            removeTaskButton.MatlabMethod='swarch.internal.spreadsheet.removeTaskFromArchitecture';
            removeTaskButton.MatlabArgs={this};
            removeTaskButton.RowSpan=[1,1];
            removeTaskButton.ColSpan=[2,2];
            removeTaskButton.Tag='removeTaskButtonTag';
            removeTaskButton.ToolTip=getString(message('SoftwareArchitecture:ArchEditor:removeTaskToolTip'));
            removeTaskButton.Alignment=2;


            buttonPanel.Type='panel';
            buttonPanel.Items={addTaskButton,removeTaskButton};
            buttonPanel.LayoutGrid=[1,3];
            buttonPanel.ColStretch=[0,0,1];
            buttonPanel.RowStretch=0;
            buttonPanel.RowSpan=[1,1];
            buttonPanel.ColSpan=[1,1];


            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.DialogMode='Slim';
            dlgStruct.Items={buttonPanel};
            dlgStruct.DialogTag='tasks_button_panel_dlg';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end
    end
end

