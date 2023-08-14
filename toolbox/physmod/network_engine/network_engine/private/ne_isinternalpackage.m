function isInternal=ne_isinternalpackage(packageParentDir,packageName)









    topDir=strrep(pm_fullpath(packageParentDir),filesep,'/');
    libDefFcn='pm_libdef';



    libDefFcnHandle=pm_pathtofunctionhandle(topDir,libDefFcn);

    if isempty(libDefFcnHandle)
        isInternal=false;
    else
        libDef=feval(libDefFcnHandle);
        packageNameInLibDef=libDef.Object.package.name;
        isInternal=strcmp(packageName,packageNameInLibDef);
    end

end
