function hNewClassDefn=deep_copy(hOldClassDefn)





    hNewClassDefn=hOldClassDefn.copy;


    hOldDerivedProperties=hOldClassDefn.DerivedProperties;
    hNewDerivedProperties=[];
    for i=1:length(hOldDerivedProperties)
        hNewDerivedProperties=[hNewDerivedProperties;hOldDerivedProperties(i).copy];
    end
    hNewClassDefn.DerivedProperties=hNewDerivedProperties;


    hOldLocalProperties=hOldClassDefn.LocalProperties;
    hNewLocalProperties=[];
    for i=1:length(hOldLocalProperties)
        hNewLocalProperties=[hNewLocalProperties;hOldLocalProperties(i).copy];
    end
    hNewClassDefn.LocalProperties=hNewLocalProperties;
