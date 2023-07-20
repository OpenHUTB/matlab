function updateParameterValue(hObj)


    info=codertarget.utils.getParameterDialogInfo(hObj);

    fs=fields(info);
    for i=1:length(fs)
        f=fs{i};
        v=info.(f);
        params=v.Parameters;
        for j=1:length(params)
            ps=params{j};
            for k=1:length(ps)
                p=ps{k};
                loc_update(hObj,p);
            end
        end
    end

    function loc_update(hObj,p)

        if~isfield(p,'DoNotStore')||~p.DoNotStore
            tagprefix='Tag_ConfigSet_CoderTarget_';
            if~isempty(p.Storage)
                fieldName=p.Storage;
            else
                fieldName=strrep(p.Tag,tagprefix,'');
            end
            if isequal(p.ValueType,'callback')
                value=eval(p.Value);
                codertarget.data.setParameterValue(hObj,fieldName,value);
            end
        end


