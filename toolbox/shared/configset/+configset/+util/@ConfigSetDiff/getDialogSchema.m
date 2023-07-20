function schema=getDialogSchema(obj)

    title.Type='text';
    title.Name=DAStudio.message('configset:util:Diff_Title',obj.Number);
    title.ForegroundColor=[0,0,255];
    title.WordWrap=true;

    table.Type='table';
    table.Size=[obj.Number,3];
    table.Data=obj.Diff;
    table.ColHeader={DAStudio.message('configset:util:Diff_ParameterName'),...
    DAStudio.message('configset:util:Diff_CurrentValue'),...
    DAStudio.message('configset:util:Diff_PreviousValue')};
    table.HeaderVisibility=[0,1];
    table.Grid=true;

    schema.DialogTitle=DAStudio.message('configset:util:Diff_Dialog',obj.ModelName);
    schema.Items={title,table};
    schema.StandaloneButtonSet={''};

