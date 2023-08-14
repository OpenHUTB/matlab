function tablesetting=interfaceTableInitFormat()







    tablesetting.Data=0;
    tablesetting.Size=[0,6];


    tablesetting.ColHeader={...
    'Port Name',...
    'Port Type',...
    'Data Type',...
    'Target Platform Interfaces',...
    'Interface Mapping',...
'Interface Options'
    };


    tablesetting.ColumnCharacterWidth=[12,6,6,18,14,14];


    tablesetting.ColumnHeaderHeight=2;
    tablesetting.HeaderVisibility=[0,1];
    tablesetting.ReadOnlyColumns=[0,1,2];
    tablesetting.MinimumSize=[300,300];

end
