function installed=autosarinstalled()







    mlock;
    persistent pathExist;

    if isempty(pathExist)
        pathExist=exist('autosar.ui.configuration.PackageString','class')==8;
    end

    installed=pathExist&&license('test','AUTOSAR_Blockset');


