function setSupportPackageToMLPath()







    if slrealtime.internal.isSpkgInstalled

        if isempty(which('slrealtime.internal.getSpPkgRootDir'))



            spPathToaddd=fullfile(matlabshared.supportpkg.getSupportPackageRoot,...
            'toolbox','slrealtime','target','supportpackage');
            addpath(spPathToaddd,'-end');
            spPathToaddd=fullfile(matlabshared.supportpkg.getSupportPackageRoot,...
            'toolbox','slrealtime','target','supportpackage','registry');
            addpath(spPathToaddd,'-end');
        end
    end
end

