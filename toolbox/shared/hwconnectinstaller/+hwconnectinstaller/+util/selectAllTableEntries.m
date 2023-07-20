function result=selectAllTableEntries(hSetup)







    [~,hardwareIndexList,~]=hwconnectinstaller.internal.getHardwareList(hSetup.PackageInfo,0);
    hSetup.SelectedPackage=hardwareIndexList{hSetup.SelectedHardware+1};
    result=hardwareIndexList{hSetup.SelectedHardware+1};


