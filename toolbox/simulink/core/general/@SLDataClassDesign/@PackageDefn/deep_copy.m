function hNewPackageDefn=deep_copy(hOrigPackageDefn)





    hNewPackageDefn=hOrigPackageDefn.copy;


    hOrigClasses=hOrigPackageDefn.Classes;
    hNewClasses=[];
    for i=1:length(hOrigClasses)
        hNewClasses=[hNewClasses;hOrigClasses(i).deep_copy];
    end
    hNewPackageDefn.Classes=hNewClasses;


    hOrigClasses=hOrigPackageDefn.OldRTWInfoClasses;
    hNewClasses=[];
    for i=1:length(hOrigClasses)
        hNewClasses=[hNewClasses;hOrigClasses(i).deep_copy];
    end
    hNewPackageDefn.OldRTWInfoClasses=hNewClasses;


    hOrigEnumTypes=hOrigPackageDefn.EnumTypes;
    hNewEnumTypes=[];
    for i=1:length(hOrigEnumTypes)
        hNewEnumTypes=[hNewEnumTypes;hOrigEnumTypes(i).copy];
    end
    hNewPackageDefn.EnumTypes=hNewEnumTypes;


    hOrigEnumTypes=hOrigPackageDefn.OldEnumTypes;
    hNewEnumTypes=[];
    for i=1:length(hOrigEnumTypes)
        hNewEnumTypes=[hNewEnumTypes;hOrigEnumTypes(i).copy];
    end
    hNewPackageDefn.OldEnumTypes=hNewEnumTypes;


    hOrigCSCs=hOrigPackageDefn.CustomStorageClasses;
    hNewCSCs=[];
    for i=1:length(hOrigCSCs)
        hNewCSCs=[hNewCSCs;hOrigCSCs(i).copy];
    end
    hNewPackageDefn.CustomStorageClasses=hNewCSCs;
