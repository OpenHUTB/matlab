function[err,configs]=checkVectorOfConfigsAndTrimValues(configs)




    err=[];
    [terrs,configs]=arrayfun(@slvariants.internal.config.utils.checkConfigAndTrimValues,configs,'UniformOutput',false);

    erridxes=find(~cellfun('isempty',terrs));

    if isempty(erridxes)
        configs=cell2mat(configs);
        terr=slvariants.internal.config.utils.checkUniqueValuesOfFieldInStructVector(configs,'Name');
        if~isempty(terr)
            err=MException(message('Simulink:Variants:VariantConfigMustBeUnique'));
        end
        return;
    end
    err=MException(message('Simulink:Variants:InvalidVectorOfConfigs'));
    terrs=terrs(erridxes);
    numerrs=length(erridxes);
    for i=1:numerrs
        idx=erridxes(i);
        tterr=terrs{i};
        terrid='Simulink:Variants:InvalidElement';
        terr=MException(message(terrid,idx));
        terr=arrayfun(@(x)(terr.addCause(x)),tterr);
        err=arrayfun(@(x)(err.addCause(x)),terr);
    end
end
