function addSpkgRootPath(target)




    assert(ispc);
    spPath=dltargets.internal.utils.getSpkgRootPath(target);
    if~isempty(spPath)
        dllPath=fullfile(spPath,'bin',computer('arch'));
        sysPath=getenv('PATH');
        if~contains(sysPath,dllPath)
            setenv('PATH',[sysPath,';',dllPath]);
        end
    end
end
