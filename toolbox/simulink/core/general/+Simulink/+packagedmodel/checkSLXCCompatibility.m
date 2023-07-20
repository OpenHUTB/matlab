function checkSLXCCompatibility(pkgFile)






    [isCompatible,relCreated]=slInternal('isSLXCCompatible',pkgFile);
    if~isCompatible
        relCurrent=Simulink.packagedmodel.getRelease();
        DAStudio.error('Simulink:cache:incompatibleWithCurrentRelease',...
        pkgFile,relCreated,relCurrent);
    end
end
