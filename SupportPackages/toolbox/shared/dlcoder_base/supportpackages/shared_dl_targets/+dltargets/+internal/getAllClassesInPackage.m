function classList=getAllClassesInPackage(fullPackageName)





    packageObject=meta.package.fromName(fullPackageName);
    if~isempty(packageObject)
        classList=packageObject.ClassList;
        classList=getClassesFromSubpackages(classList,packageObject);
    else
        classList=[];
    end

end

function classList=getClassesFromSubpackages(classList,packageObject)
    if isa(packageObject,'meta.package')
        classList=[classList;packageObject.ClassList];
        for ii=1:numel(packageObject.PackageList)
            classList=getClassesFromSubpackages(classList,packageObject.PackageList(ii));
        end
    end
end