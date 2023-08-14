function loadCurrPackage(hUI,newPackageName)



    oldPackage=hUI.CurrPackage;


    if isequal(oldPackage,newPackageName)
        return;
    end

    if isempty(oldPackage)
        oldPackage='Simulink';
    end


    errs='';

    try

        before_cscIndex=hUI.Index(1);
        before_msIndex=hUI.Index(2);
        before_CSCActiveSubTab=hUI.CSCActiveSubTab;


        try_prior_csc=false;
        try_prior_ms=false;




        if((length(hUI.AllDefns{1})>=before_cscIndex+1)&&...
            (length(hUI.AllDefns{2})>=before_msIndex+1))

            before_cscName=hUI.AllDefns{1}(before_cscIndex+1).get('Name');
            before_msName=hUI.AllDefns{2}(before_msIndex+1).get('Name');


            try_prior_csc=true;
            try_prior_ms=true;
        end


        hUI.Index(1)=0;
        hUI.Index(2)=0;




        hUI.CSCActiveSubTab=before_CSCActiveSubTab;

        loadDefnsPkgs=DAStudio.message('Simulink:dialog:CSCUILoadDefnsPkg',newPackageName);
        waitBarPlsWait=DAStudio.message('Simulink:dialog:CSCUIFindPkgsPlsWait');
        hw=waitbar(0,...
        loadDefnsPkgs,...
        'Name',waitBarPlsWait);

        cscRegFile=processcsc('GetCSCRegFile',newPackageName);

        if isempty(cscRegFile)

            [~,packageInfo]=slprivate('find_valid_packages');


            assert(length(packageInfo.(newPackageName).DirectoryNames)==1);

            newPackageDir=packageInfo.(newPackageName).DirectoryNames{1};
            newRegFile=[newPackageDir,filesep,'csc_registration.m'];
            hUI.RegFilePath=newRegFile;

            if hUI.isCSCRegFileReadOnly
                DAStudio.error('Simulink:dialog:DCDUnableToOpenFileForWrite',newRegFile);
            end
            if ishghandle(hw);waitbar(1/2,hw);end

            hUI.AllDefns=processcsc('GetCopyOfSimulinkDefns',newPackageName);
        else

            hUI.RegFilePath=cscRegFile;


            tmpstr='processcsc(''GetAllDefnsFromCSCRegFile'', newPackageName)';
            [errs,hUI.AllDefns]=evalc(tmpstr);
            if~isempty(errs)
                errs=lastwarn;
            end
        end
        if ishghandle(hw);waitbar(1,hw);end


        hUI.CurrPackage=newPackageName;



        if(try_prior_csc)
            matchidx=find(strcmp(before_cscName,hUI.Alldefns{1}.get('Name')));
            if(~isempty(matchidx))
                hUI.Index(1)=matchidx-1;
            end
        end



        if(try_prior_ms)
            matchidx=find(strcmp(before_msName,hUI.Alldefns{2}.get('Name')));
            if(~isempty(matchidx))
                hUI.Index(2)=matchidx-1;
            end
        end

        if ishghandle(hw);close(hw);end
        hUI.show();

        hUI.PreviewDefnBak={[],[]};

        validateAll(hUI);

        if isempty(cscRegFile)

            hUI.IsDirty=true;
        end

    catch err
        if ishghandle(hw);close(hw);end
        hUI.show();
        errs=err.message;
        loadCurrPackage(hUI,oldPackage);
    end

    if~isempty(errs)
        warnMsg=DAStudio.message('Simulink:dialog:CSCUILoadPackageWarnings',newPackageName,errs);
        warndlg(warnMsg,DAStudio.message('Simulink:dialog:CSCDesignerTitle'),'non-modal');
    end

end


