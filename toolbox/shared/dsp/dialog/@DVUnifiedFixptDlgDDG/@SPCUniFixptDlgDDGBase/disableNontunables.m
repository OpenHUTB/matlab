function dlgStruct=disableNontunables(this,dlgStruct)



    if isfield(dlgStruct,'Items')
        for ind=1:length(dlgStruct.Items)
            dlgStruct.Items{ind}=this.disableNontunables(dlgStruct.Items{ind});
        end
    elseif isfield(dlgStruct,'Tabs')
        for ind=1:length(dlgStruct.Tabs)
            dlgStruct.Tabs{ind}=this.disableNontunables(dlgStruct.Tabs{ind});
        end
    elseif isfield(dlgStruct,'Tunable')
        if~dlgStruct.Tunable
            dlgStruct.Enabled=0;
        end
    end
