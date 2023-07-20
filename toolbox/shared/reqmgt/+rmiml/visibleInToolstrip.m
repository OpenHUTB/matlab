function yesno=visibleInToolstrip(sourceKey)









    [rmiInstalled,rmiLicenseAvailable]=rmi.isInstalled();
    if rmiInstalled&&rmiLicenseAvailable
        yesno=java.lang.Boolean.valueOf(true);
    elseif rmiml.hasReqDataFile(sourceKey)








        yesno=java.lang.Boolean.valueOf(true);
    else
        yesno=java.lang.Boolean.valueOf(false);
    end
end


