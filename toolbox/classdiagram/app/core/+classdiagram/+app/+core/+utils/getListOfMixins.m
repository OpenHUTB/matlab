function[mixinList,sz]=getListOfMixins()

    fullPkgList=getPkgsClassesRecursively("matlab");

    topLevelMixins=["dynamicprops","JavaVisible"];
    mixinList=strjoin([topLevelMixins,fullPkgList(contains(fullPkgList,"mixin"))],...
    """"+", ..."+newline+"""");
    sz=length([topLevelMixins,fullPkgList(contains(fullPkgList,"mixin"))]);
end
function results=getPkgsClassesRecursively(pkgList)
    results=[];
    for numPkgs=1:length(pkgList)
        classList=string({meta.package.fromName(pkgList{numPkgs}).ClassList.Name});
        subPkgList=string({meta.package.fromName(pkgList{numPkgs}).PackageList.Name});
        subPkgClassList=getPkgsClassesRecursively(subPkgList);

        results=[results,classList,subPkgClassList];
    end
end