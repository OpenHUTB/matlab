function actualClass=getClassNameForWrappedSystemObject(wrappedClass)











    actualClass=wrappedClass;

    sysObjPath=which(wrappedClass);
    toolboxPath=fullfile(matlabroot,'toolbox');
    if isempty(strfind(sysObjPath,toolboxPath))

        return;
    end

    idx=strfind(wrappedClass,'.');
    if~isempty(wrappedClass)
        pkgName=wrappedClass(1:idx-1);
        if strcmp(pkgName,'dspcodegen')||strcmp(pkgName,'visioncodegen')||...
            strcmp(pkgName,'commcodegen')
            actualClass=[strrep(pkgName,'codegen',''),wrappedClass(idx:end)];
        end
    end
