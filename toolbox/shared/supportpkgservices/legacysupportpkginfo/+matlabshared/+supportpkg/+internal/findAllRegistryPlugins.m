function spPkgList=findAllRegistryPlugins()






    packageName='matlabshared.supportpkg.internal.sppkglegacy';

    superClassName='matlabshared.supportpkg.internal.sppkglegacy.SupportPackageRegistryPluginBase';


    packages=meta.package.fromName(packageName);
    spPkgList=meta.class.empty;
    classIndices=[];

    for i=1:length(packages.ClassList)
        currentClass=packages.ClassList(i);
        if isempty(currentClass.SuperclassList)

            continue;
        end
        isDerivedClass=ismember(superClassName,{currentClass.SuperclassList.Name});
        if isDerivedClass
            classIndices=[classIndices,i];%#ok<AGROW>
        end
    end
    spPkgList=packages.ClassList(classIndices);
end