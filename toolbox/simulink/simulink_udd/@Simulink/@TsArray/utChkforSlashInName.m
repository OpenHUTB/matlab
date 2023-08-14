function[boo,offending_name]=utChkforSlashInName(h)





    boo=false;
    offending_name='';
    if~isempty(strfind(h.Name,'/'))
        boo=true;
        offending_name=h.Name;
        return;
    end

    try
        members=struct2cell(get(h));
    catch
        return;
    end

    for k=1:length(members)
        if isa(members{k},'Simulink.Timeseries')
            if~isempty(strfind(members{k}.Name,'/'))
                boo=true;
                offending_name=members{k}.Name;
                return;
            end
        elseif any(ismember(class(members{k}),{'Simulink.ModelDataLogs','Simulink.SubsysDataLogs',...
            'Simulink.StateflowDataLogs','Simulink.ScopeDataLogs','Simulink.TsArray'}))
            [boo,offending_name]=utChkforSlashInName(members{k});
            if boo
                return
            end
        end
    end
