function entries=getBuildOptionsEntries(hObj)





    entries=[];
    if isa(hObj,'Simulink.ConfigSet')||...
        isa(hObj,'Simulink.ConfigSetRef')
        hCS=hObj;
    else

        hCS=getActiveConfigSet(hObj);
    end
    info=codertarget.parameter.getParameterDialogInfo(hCS,1);
    for i=1:length(info.Parameters)
        param=info.Parameters{i}{1};
        if isfield(param,'Name')&&isequal(param.Name,'Build action:')
            if isfield(param,'Entries')
                entries=param.Entries;
                return;
            end
        end
    end
end