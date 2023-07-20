function selectPackage(hUI,packageNameOrIdx)





    if isempty(packageNameOrIdx)
        return;
    end

    if~hUI.TESTING_DONT_ASK_DONT_SAVE
        if~hUI.promptSave('SelectPackage');
            return;
        end
    end

    switch class(packageNameOrIdx)
    case 'char'
        packageName=packageNameOrIdx;
    case 'double'
        packageName=hUI.PackageNames{packageNameOrIdx+1};
    end

    if~ismember(packageName,hUI.PackageNames)&&...
        ~strcmp(packageName,'Simulink')
        tmpstr=['@',packageName,filesep,'schema'];
        if isempty(which(tmpstr))
            errmsg=DAStudio.message('Simulink:dialog:CSCDefnPackageNotFoundInPath',packageName);
            errordlg(errmsg,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
            return;
        end

        hUI.PackageNames=union(hUI.PackageNames,packageName);
    end

    loadCurrPackage(hUI,packageName);



