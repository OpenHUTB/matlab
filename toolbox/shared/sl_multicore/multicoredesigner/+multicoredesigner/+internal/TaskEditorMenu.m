classdef TaskEditorMenu<handle





    properties
MulticoreUI
    end

    methods

        function obj=TaskEditorMenu(uiObj)
            obj.MulticoreUI=uiObj;
        end


        function dlgStruct=getDialogSchema(obj,~)

            viewOptionCombobox=struct('Type','combobox','Tag','viewOptionCombobox','Name',getString(message('dataflow:Spreadsheet:ViewColon')),'Graphical',true);
            viewOptionCombobox.Entries={getString(message('dataflow:Spreadsheet:Tasks')),...
            getString(message('dataflow:Spreadsheet:Blocks'))};
            if obj.MulticoreUI.TaskView
                viewOptionCombobox.Value=0;
            else
                viewOptionCombobox.Value=1;
            end
            viewOptionCombobox.DialogRefresh=0;
            viewOptionCombobox.SaveState=0;
            viewOptionCombobox.ObjectMethod='onViewOptionChanged';
            viewOptionCombobox.MethodArgs={'%value'};
            viewOptionCombobox.ArgDataTypes={'mxArray'};


            titlePanel.Type='panel';
            titlePanel.Items={viewOptionCombobox};
            titlePanel.LayoutGrid=[1,5];
            titlePanel.ColStretch=[0,0,0,0,1];
            titlePanel.RowSpan=[1,1];
            titlePanel.ColSpan=[1,1];



            dlgStruct.DialogTitle='';
            dlgStruct.IsScrollable=false;
            dlgStruct.DialogMode='Slim';
            dlgStruct.Items={titlePanel};
            dlgStruct.DialogTag='multicore_spreadsheet_task_dlg';
            dlgStruct.StandaloneButtonSet={''};
            dlgStruct.EmbeddedButtonSet={''};
        end
        function onViewOptionChanged(obj,val)
            if~isempty(obj.MulticoreUI)&&isvalid(obj.MulticoreUI)
                if val==0
                    taskView=true;
                else
                    taskView=false;
                end
                changeView(obj.MulticoreUI,taskView);
            end
        end
    end
end


