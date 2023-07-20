function pvs=UpdateConverterToSlUnitPVs(block)






    pvs={};
    pmUnit=get_param(block,'Unit');
    slUnit=pm_remapunits(pmUnit,pm_unitreplacement());
    if~strcmp(slUnit,strrep(pmUnit,' ',''))
        pvs={'Unit',slUnit};
    end

end
