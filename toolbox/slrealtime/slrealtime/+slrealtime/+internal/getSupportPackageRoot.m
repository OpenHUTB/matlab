function installedPath=getSupportPackageRoot()








    installedPath=[];

    if slrealtime.internal.isSpkgInstalled

        slrealtime.internal.setSupportPackageToMLPath();
        installedPath=slrealtime.internal.getSpPkgRootDir;
    end
end
