function[out,dscr]=msList(cs,name,type)


    dscr=[name,'''s enum options depend on MemSecPackage'];
    out=[];

    try
        package=cs.getProp('MemSecPackage');
        packageEnabled=~strcmp(package,'--- None ---');
        list=configset.internal.custom.MemSecOptions(package,packageEnabled,type);
        value=cs.getProp(name);
        if~ismember(value,list)
            list=[value,list];
        end

        out=configset.internal.util.getAvailableValuesFromCellArray(list,[],list);
    catch
    end

