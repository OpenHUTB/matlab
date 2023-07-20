function show(varargin)







    p=inputParser;
    p.CaseSensitive=false;
    p.KeepUnmatched=false;
    p.FunctionName='Support Package Installer';
    p.addParamValue('EntryPoint',[],@ischar);
    p.addParamValue('Signpost',[],@ischar);
    p.addParamValue('StartAtStep','Install',@validateStartAtStep);
    p.addParamValue('BaseProduct',[],@validateBaseProduct);
    p.addParamValue('SupportPackageFor',[],@validateSupportPackageFor);
    p.addParamValue('Platform',[],@validatePlatform);
    p.addParamValue('SupportCategory','hardware',@validateSupportCategory);
    p.addParamValue('Workflow','InstallFromInternet',@validateWorkflow);
    p.addParamValue('BaseCode',[],@validateBaseCodes);

    p.parse(varargin{:});
    inputParams=p.Results;

    if isUserSpecified(p,'SupportPackageFor')&&isUserSpecified(p,'BaseCode')
        error('Cannot specify both "SupportPackageFor" and "BaseCode" as filtering arguments');
    end

    if(isUserSpecified(p,'StartAtStep')...
        ||isUserSpecified(p,'BaseProduct')...
        ||isUserSpecified(p,'SupportPackageFor')...
        ||isUserSpecified(p,'BaseCode')...
        ||isUserSpecified(p,'Platform')...
        ||isUserSpecified(p,'SupportCategory')...
        ||isUserSpecified(p,'Workflow'))...
        &&isUserSpecified(p,'Signpost')
        error(message('hwconnectinstaller:setup:CmdLine_StartAtStepCannotbeUsedWithSignpost'));
    end




    hSetup=hwconnectinstaller.Setup.get();

    if isUserSpecified(p,'Signpost')
        hSetup.SPIEntryPoint='mlpkginstall';
    elseif(isUserSpecified(p,'BaseProduct')||isUserSpecified(p,'SupportPackageFor')||isUserSpecified(p,'BaseCode')||isUserSpecified(p,'SupportCategory'))&&~isUserSpecified(p,'EntryPoint')
        hSetup.SPIEntryPoint='tripwire';
    else
        hSetup.SPIEntryPoint=char(inputParams.EntryPoint);
    end
    addOnsInvoked=hwconnectinstaller.internal.invokeAddOnsIfApplicable(p,hSetup.SPIEntryPoint);
    if addOnsInvoked
        return;
    end

    modelExplorerAlreadyOpen=~isempty(hSetup.Explorer);
    needToProcessInputParams=isUserSpecified(p,'StartAtStep')...
    ||isUserSpecified(p,'Signpost')...
    ||isUserSpecified(p,'BaseProduct')...
    ||isUserSpecified(p,'SupportPackageFor')...
    ||isUserSpecified(p,'BaseCode')...
    ||isUserSpecified(p,'Platform')...
    ||isUserSpecified(p,'SupportCategory');
    needUIReset=modelExplorerAlreadyOpen&&needToProcessInputParams;

    if modelExplorerAlreadyOpen&&(~needToProcessInputParams||strcmpi(hSetup.SPIEntryPoint,'AddOns'))






        hSetup.Explorer.show;
        return;
    end

    if needUIReset
        if canCloseExistingUI(hSetup)
            closeExistingUI(hSetup);
        else


            hSetup.Explorer.show;
            return;
        end



        hSetup=hwconnectinstaller.Setup.get();
    end








    hInstaller=hSetup.getInstaller();


    workflow='default';
    if isequal(lower(inputParams.StartAtStep),'selectpackage')
        jumpto={'Install','SelectPackage'};
    else
        jumpto=cellstr(inputParams.StartAtStep);
    end

    [~,availableWorkflows]=enumeration('hwconnectinstaller.internal.InstallerWorkflow');
    requestedWorkflow=availableWorkflows(strcmpi(inputParams.Workflow,availableWorkflows));
    hSetup.InstallerWorkflow=hwconnectinstaller.internal.InstallerWorkflow.(char(requestedWorkflow));


    hwconnectinstaller.SupportTypeQualifierEnum.setType('Standard');



    hSetup.getMessages();
    filterCriteria=[];




    if~strcmp(jumpto,'update')
        hSetup.InstSpPkg=hInstaller.getInstalledPackages(false);
    end
    autoloadManifest=false;

    if~isempty(inputParams.Signpost)
        [signpostStatus,signpostObj]=processSignpostFile(hSetup,inputParams.Signpost);

        switch signpostStatus
        case 'Success'
            workflow='signpost';
            jumpto={'Install','SelectPackage'};
            filterCriteria=struct('Name',signpostObj.PackageName);
            autoloadManifest=true;

        case 'SignpostErrorGoToDoc'
            hwconnectinstaller.helpView('abouttargetinstaller');
            return;

        otherwise
            return;
        end
    else


        if~isequal(lower(p.Results.StartAtStep),'install')&&~isequal(lower(p.Results.StartAtStep),'update')
            autoloadManifest=true;
        end

        if isUserSpecified(p,'BaseProduct')
            filterCriteria.BaseProduct=p.Results.BaseProduct;
        end
        if isUserSpecified(p,'SupportPackageFor')
            filterCriteria.Name=p.Results.SupportPackageFor;
        end
        if isUserSpecified(p,'BaseCode')
            filterCriteria.BaseCode=p.Results.BaseCode;
        end
        if isUserSpecified(p,'Platform')
            filterCriteria.Platform=p.Results.Platform;
        end
        filterCriteria.SupportCategory=p.Results.SupportCategory;

    end

    if autoloadManifest








        if(hSetup.InstallerWorkflow.isUninstall)




            if hSetup.canAccessInternet()
                hSetup.WebSpPkg=hInstaller.getPackageListFromWeb();
            end


            if isempty(hSetup.InstSpPkg)
                error(message('hwconnectinstaller:setup:Install_NoInstalledPkgFound'));
            end
            hSetup.FilteredSpPkg=hwconnectinstaller.internal.filterSpPkgList(hSetup.InstSpPkg,filterCriteria);




            if isfield(filterCriteria,'Name')&&~isempty(filterCriteria.Name)



                assert(numel(hSetup.FilteredSpPkg)==1);





                hwconnectinstaller.SupportTypeQualifierEnum.setType(hSetup.FilteredSpPkg.SupportTypeQualifier);



                hSetup.getMessages();
                if~hSetup.FilteredSpPkg.Visible
                    error(message(hwconnectinstaller.internal.getAdjustedMessageID(...
                    'hwconnectinstaller:setup:CannotUninstallHiddenPkg'),hSetup.FilteredSpPkg.Name));
                end
            end
        else






            if isempty(hSetup.WebSpPkg)
                hSetup.WebSpPkg=hInstaller.getPackageListFromWeb();
            end
            hSetup.FilteredSpPkg=hwconnectinstaller.internal.filterSpPkgList(hSetup.WebSpPkg,filterCriteria);
        end

        if isempty(hSetup.FilteredSpPkg)
            error(message(hwconnectinstaller.internal.getAdjustedMessageID(...
            'hwconnectinstaller:setup:Install_NoFilteredPkgFound')));
        end





        hSetup.PackageInfo=...
        hwconnectinstaller.internal.getPackageDisplayInfo(...
        hSetup.FilteredSpPkg,...
        hSetup.WebSpPkg,...
        hSetup.InstSpPkg,...
        hSetup.InstallerWorkflow);

        if isempty(hSetup.PackageInfo)











            error(message('hwconnectinstaller:setup:Install_NoFilteredPkgFound'));
        end




        hSetup.MWALogin.initiateLoginCheck();
    end





    assert(isempty(hSetup.Explorer));

    try
        hSetup.showProgressBar(DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:waitbarTitle')),[],0.2);


        disableBackButton=~(length(jumpto)==1&&isequal(jumpto{1},'Install'));

        hwconnectinstaller.internal.createDefaultSteps(hSetup,workflow,filterCriteria,disableBackButton);
        hSetup.setProgressBarValue([],0.6);
        hSetup.closeProgressBar();
    catch ME
        hSetup.closeProgressBar();
        rethrow(ME);
    end

    assert(~isempty(hSetup.Explorer));

    hSetup.jumpToStep(cellstr(jumpto));
    hSetup.Explorer.setTreeTitle(hSetup.getTreeTitle());

    hSetup.Explorer.show;


end






function[status,signpostObj]=processSignpostFile(hSetup,signpostFileName)
    status='';%#ok<NASGU>
    signpostObj=[];
    signpostException=[];

    try
        signpostObj=hwconnectinstaller.SignpostReader(signpostFileName);




        if strcmp(signpostObj.BaseCode,'%%LEGACYSIGNPOST%%')
            filterCriteria=struct('Name',signpostObj.PackageName,'Visible',1,'Enable',1);
        else
            filterCriteria=struct('BaseCode',signpostObj.BaseCode,'Visible',1,'Enable',1);
        end
        if isempty(hSetup.WebSpPkg)
            hSetup.WebSpPkg=hSetup.getInstaller().getPackageListFromWeb();
        end
        signpostSpPkg=hwconnectinstaller.internal.filterSpPkgList(hSetup.WebSpPkg,filterCriteria);
        if numel(signpostSpPkg)==1




            hwconnectinstaller.SupportTypeQualifierEnum.setType(signpostSpPkg.SupportTypeQualifier);



            hSetup.getMessages();
            [isInstallable,~,installabilityErrMsg]=hwconnectinstaller.internal.isSupportPkgInstallable(signpostSpPkg);
            if isInstallable
                status='Success';
            else
                status='SignpostIsNotInstallable';
            end
        else
            status='SignpostManifestLookupFailure';
        end
    catch signpostException

        hwconnectinstaller.SupportTypeQualifierEnum.setType('Standard')
        status=signpostException.identifier;
    end

    if~strcmp(status,'Success')
        signpostGoToDoc=false;
        [~,fname,ext]=fileparts(signpostFileName);
        shortFileName=[fname,ext];

        switch status
        case 'hwconnectinstaller:setup:Signpost_NonExistentFile'
            msg.Text=DAStudio.message('hwconnectinstaller:setup:Signpost_UI_NonExistentFile',shortFileName);

        case{'hwconnectinstaller:setup:Signpost_Unreadable',...
            'hwconnectinstaller:setup:Signpost_MissingXMLElement',...
            'hwconnectinstaller:setup:Signpost_Tampered'}
            msg.Text=DAStudio.message('hwconnectinstaller:setup:Signpost_UI_InvalidFile',shortFileName);

        case 'hwconnectinstaller:setup:Signpost_VersionNotFound'
            msg.Text=DAStudio.message('hwconnectinstaller:setup:Signpost_UI_VersionMismatch',shortFileName);

        case{'SignpostManifestLookupFailure','hwconnectinstaller:setup:UnsupportedRelease'}
            msg.Text=DAStudio.message('hwconnectinstaller:setup:Signpost_UI_ManifestLookupFailure',signpostObj.FullName);

        case 'SignpostIsNotInstallable'
            msg.Text=installabilityErrMsg;

        otherwise
            if isa(signpostException,'MException')
                msg.Text=signpostException.message;
            else
                msg.Text=DAStudio.message('hwconnectinstaller:setup:Signpost_UI_InvalidFile',shortFileName);
            end
        end

        msg.Title=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:Signpost_UI_Name'));
        dlg=DAStudio.DialogProvider;
        dlg.errordlg(msg.Text,msg.Title);

        if signpostGoToDoc
            status='SignpostErrorGoToDoc';%#ok<UNRCH>
        end
    end

end




function doCloseUI=canCloseExistingUI(hSetup)
    doCloseUI=false;

    dialogTitle=DAStudio.message(hwconnectinstaller.internal.getAdjustedMessageID('hwconnectinstaller:setup:CmdLine_UIName'));
    msg=hwconnectinstaller.internal.getXlateEntries('hwconnectinstaller','setup','UIAlreadyOpen',...
    {'Question','Continue','StartOver','NotAllowed','OK'});




    if hSetup.isUIResetAllowed()

        result=questdlg(msg.Question,dialogTitle,...
        msg.Continue,msg.StartOver,msg.Continue);
        if isempty(result)

            result=msg.Continue;
        end
        if strcmp(result,msg.Continue)
            return;
        end
    else





        questdlg(msg.NotAllowed,dialogTitle,msg.OK,msg.OK);
        return;
    end

    doCloseUI=true;
end


function closeExistingUI(hSetup)







    assert(~isempty(hSetup.Explorer));
    hSetup.finish;
    hSetup.delete();
end


function out=isUserSpecified(inputParserObj,param)
    out=~any(strcmpi(param,inputParserObj.UsingDefaults));
end


function validatePlatform(platform)
    allPlatforms={'PCWIN','GLNX86','PCWIN64','GLNXA64','MACI64'};
    p=upper(platform);
    if~all(ismember(p,allPlatforms))
        error(message('hwconnectinstaller:setup:CmdLine_WrongPlatformValue'));
    end
end

function validateBaseCodes(baseCodes)
    if~ischar(baseCodes)&&~iscellstr(baseCodes)
        error(message('hwconnectinstaller:setup:CmdLine_WrongBaseCodesValue'));
    end
end


function validateBaseProduct(product)
    if iscell(product)
        for i=1:length(product)
            if~ischar(product{i})
                error(message('hwconnectinstaller:setup:CmdLine_WrongBaseProductValue'));
            end
        end
    else
        if~ischar(product)
            error(message('hwconnectinstaller:setup:CmdLine_WrongBaseProductValue'));
        end
    end
end


function validateSupportPackageFor(product)
    if iscell(product)
        for i=1:length(product)
            if~ischar(product{i})
                error(message('hwconnectinstaller:setup:CmdLine_WrongSupportPackageForValue'));
            end
        end
    else
        if~ischar(product)
            error(message('hwconnectinstaller:setup:CmdLine_WrongSupportPackageForValue'));
        end
    end
end


function validateStartAtStep(step)
    if~ischar(step)
        error(message('hwconnectinstaller:setup:CmdLine_WrongStartAtStepValue'));
    end

    allowedSteps={'install','update','selectpackage'};
    if~ismember(lower(step),allowedSteps)
        error(message('hwconnectinstaller:setup:CmdLine_WrongStartAtStepValue'));
    end
end


function validateSupportCategory(category)
    categoryStr=cellstr(category);
    for i=1:length(categoryStr)
        if~ischar(categoryStr{i})...
            ||~ismember(lower(categoryStr{i}),{'hardware','software','feature'})
            error(message('hwconnectinstaller:setup:CmdLine_WrongCategoryValue'));
        end
    end
end

function validateWorkflow(workflow)
    [~,validWorkflows]=enumeration('hwconnectinstaller.internal.InstallerWorkflow');

    validWorkflows(strcmpi(validWorkflows,'InstallFromFolder'))=[];
    if~ismember(lower(workflow),lower(validWorkflows))
        error(message('hwconnectinstaller:setup:CmdLine_UnsupportedWorkflow',workflow));
    end
end

