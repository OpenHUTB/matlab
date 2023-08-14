function dlgStruct=disableNonTunables(obj,dlgStruct)








    if isfield(dlgStruct,'Items')
        for ind=1:length(dlgStruct.Items)
            dlgStruct.Items{ind}=obj.disableNonTunables(dlgStruct.Items{ind});
        end
    elseif isfield(dlgStruct,'Tabs')
        for ind=1:length(dlgStruct.Tabs)
            dlgStruct.Tabs{ind}=obj.disableNonTunables(dlgStruct.Tabs{ind});
        end
    elseif isfield(dlgStruct,'Tunable')
        if~dlgStruct.Tunable
            dlgStruct.Enabled=0;
        end
    end
