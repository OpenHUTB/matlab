function cscdef=ec_get_cscdef(obj,packageCSCDef)





    assert(~isempty(obj));
    assert(isa(obj,'Simulink.Data')||isa(obj,'Simulink.LookupTable')||isa(obj,'Simulink.Breakpoint'));
    assert(~isempty(obj.CoderInfo.CSCPackageName));
    assert(isprop(obj,'CoderInfo'));
    assert(isprop(obj.CoderInfo,'CustomStorageClass'));

    package=obj.CoderInfo.CSCPackageName;
    csc=obj.CoderInfo.CustomStorageClass;
    if~isempty(packageCSCDef)&&~isfield(packageCSCDef,'packageNames')
        matches=strcmp(packageCSCDef.packageNames,package);
        index=find(matches);
        if~isempty(index)

            matches2=strcmp(packageCSCDef.packageCSCDefns{index}.cscName,csc);
            cscdef=packageCSCDef.packageCSCDefns{index}.packageDef(matches2);
            return;
        end
    end



    packageCSCDef=ec_record_csc_def({package});
    assert(length(packageCSCDef.packageCSCDefns)==1);
    indices=strcmp(packageCSCDef.packageCSCDefns{1}.cscName,csc);
    cscdef=packageCSCDef.packageCSCDefns{1}.packageDef(indices);


