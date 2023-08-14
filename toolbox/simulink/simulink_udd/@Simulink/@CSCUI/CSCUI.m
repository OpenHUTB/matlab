function hUI=CSCUI(packageName,isAdvanced)





    narginchk(2,2)

    if isstring(packageName)
        packageName=convertStringsToChars(packageName);
    end

    if(ischar(packageName)&&isrow(packageName)&&...
        islogical(isAdvanced)&&isscalar(isAdvanced))

    else
        DAStudio.error('Simulink:dialog:CSCUIInvalidInpArg');
    end

    if isempty(meta.package.fromName(packageName))
        DAStudio.error('Simulink:dialog:CSCUIPackageExist',packageName);
    end




    hUI=Simulink.CSCUI;
    hUI.IsAdvanceMode=isAdvanced;




    waitBarFindpkgs=DAStudio.message('Simulink:dialog:CSCUIFindPkgs');
    waitBarPlsWait=DAStudio.message('Simulink:dialog:CSCUIFindPkgsPlsWait');
    hw=waitbar(0,waitBarFindpkgs,'Name',waitBarPlsWait);

    hUI.PackageNames={'Simulink'};

    [packageList,packageInfo]=slprivate('find_valid_packages');
    for i=1:length(packageList)
        thisName=packageList{i};
        try
            if((~strcmp(thisName,'Simulink'))&&...
                (~isempty(processcsc('GetCSCRegFile',thisName))))
                hUI.PackageNames{end+1}=thisName;
            end
        catch err
            warndlg(err.message,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
        end
        if ishghandle(hw);waitbar(i/length(packageList),hw);end
    end

    if ishghandle(hw);close(hw);end

    if~ismember(packageName,hUI.PackageNames)

        if ismember(packageName,packageList)
            if(length(packageInfo.(packageName).DirectoryNames)==1)

                hUI.PackageNames=[{packageName};hUI.PackageNames];
            else
                DAStudio.error('Simulink:dialog:CSCUIMultiplePackageDirsFound',packageName,packageName);
            end
        else
            DAStudio.error('Simulink:dialog:CSCUIPackageIsInvalidForCSCReg',packageName);
        end
    end




    loadCurrPackage(hUI,packageName);




