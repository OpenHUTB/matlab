function out=settings_mgr(method,variable,value)





    persistent regTargets wordSelHist excelSelHist doorsSelHist...
    linkSettings miscSettings selectIdx selectTag reportSettings...
    filterSettings settingsTab protectSurrogateLinks isDoorsSetup...
    storageSettings coverageSettings oslcSettings polarionSettings...
    pathSettings httpPortEnabled doorsSettings;%#ok

    switch lower(method)

    case 'get'

        if(~exist(variable,'var'))
            error(message('Slvnv:rmi:settings_mgr:UnrecognizedVar',variable));
        end


        memValue=eval(variable);
        if~isempty(memValue)
            out=memValue;

        else

            if exist(settings_file_name(),'file')

                s=loadFromFile();

                if isfield(s,variable)
                    out=s.(variable);



                    isForcedUpgrade=(nargin==3&&islogical(value)&&value);
                    isForcedUpgrade=isForcedUpgrade|(nargin==3&&strcmp(value,'externalLinksHtml'));
                    out=upgradeLoadedSettingsIfNeeded(out,variable,isForcedUpgrade);

                else
                    out=defaults(variable);
                end

            else
                out=defaults(variable);
            end


            eval([variable,'=out;']);
        end

        if nargin==3&&ischar(value)


            settings=out;
            if~isfield(settings,value)



                settings=upgradeSettings(settings,variable);
                eval([variable,'=settings;']);
            end
            out=settings.(value);



            if islogical(out)

                if strcmp(value,'duplicateOnCopy')




                    syncSlFeatureValue('MdlDuplicateRequirementsOnCopy',out);

                elseif out

                    switch value
                    case 'twoWayLink'


                        out=rmiAvailable();

                    case 'navUseMatlab'


                        out=connector.internal.isRestMatlabRunning();

                    case 'external'

                        out=rmiAvailable();
                    otherwise
                    end
                end
            end
        end

    case 'set'

        if strcmp(variable,'DEFAULTS')


            out=defaults('SAVE');
            return;

        elseif~exist(variable,'var')
            error(message('Slvnv:rmi:settings_mgr:UnrecognizedVar',variable));
        end



        [wasTwoWay,wasActX,wasMC]=mcDependentSettings(linkSettings,reportSettings);


        eval([variable,'=value;']);



        if~isParallel()
            if exist(settings_file_name(),'file')
                save(settings_file_name(),'-append',variable);
            else
                save(settings_file_name(),variable);
            end
        end



        switch variable

        case{'selectTag','selectIdx'}


            if rmi.isInstalled()
                rmi.menus_selection_links([]);
                rmiml.selectionLink([]);
            end

        case 'storageSettings'

            syncSlFeatureValue('MdlDuplicateRequirementsOnCopy',value.duplicateOnCopy);

        case 'httpPortEnabled'

            if value
                connector.internal.ensureRestMatlabOn;

                if~isempty(rmipref('OslcServerAddress'))
                    slreq.connector.Oslc.unregister();
                    slreq.connector.Oslc.register();
                end
            elseif connector.internal.isRestMatlabRunning()



                oslcServiceOn=rmi.isInstalled()&&slreq.connector.Oslc.isRegistered();
                if oslcServiceOn
                    slreq.connector.Oslc.unregister();
                end
                connector.internal.stopRestMatlab()
                if oslcServiceOn
                    pause(0.5);
                    slreq.connector.Oslc.register();
                end
            end

        case 'linkSettings'

            if value.twoWayLink&&~wasTwoWay
                if value.useActiveX
                    if ispc
                        rmicom.actxinit();
                    end
                else
                    warnIfConnectorNotRunning();
                end
            elseif value.useActiveX&&~wasActX
                if ispc
                    rmicom.actxinit();
                end
            end

        case 'reportSettings'

            if value.navUseMatlab&&~wasMC
                warnIfConnectorNotRunning();
            end

        otherwise
        end

    case 'default'
        out=defaults(variable);

    otherwise
        error(message('Slvnv:rmi:settings_mgr:UnrecognizedMethod',method));
    end
end

function s=loadFromFile()
    s=load(settings_file_name());

















end

function[isTwoWay,isActX,isMC]=mcDependentSettings(linkSettings,reportSettings)
    isTwoWay=[];
    isActX=[];
    isMC=[];
    if~isempty(linkSettings)
        isTwoWay=linkSettings.twoWayLink;
        isActX=linkSettings.useActiveX;
    end
    if~isempty(reportSettings)
        isMC=reportSettings.navUseMatlab;
    end
end

function warnIfConnectorNotRunning()
    if~connector.internal.isRestMatlabRunning()
        rmiut.warnNoBacktrace('Slvnv:rmiut:matlabConnectorOn:matlabConnectorNotRunning');
    end
end

function settingsStruct=upgradeLoadedSettingsIfNeeded(settingsStruct,varName,force)
    if any(strcmp(varName,{'storageSettings','linkSettings','doorsSettings',...
        'filterSettings','reportSettings','oslcSettings'}))
        if~isfield(settingsStruct,'version')


            settingsStruct.version='2009b';
        end
        if force||sscanf(settingsStruct.version,'%x')<sscanf(version('-release'),'%x')
            settingsStruct=upgradeSettings(settingsStruct,varName);
        end
    end
end

function out=defaults(variable)
    persistent dflts;

    if isempty(dflts)
        dflts.regTargets={'% Add MATLAB file names'};
        dflts.wordSelHist={''};


        linkSettings.modelPathStorage='none';
        linkSettings.docPathStorage='none';
        linkSettings.twoWayLink=false;
        linkSettings.slrefUserBitmap='';
        linkSettings.slrefCustomized=false;
        linkSettings.useActiveX=false;
        linkSettings.doorsLabelFormat='';
        linkSettings.version=version('-release');
        dflts.linkSettings=linkSettings;

        dflts.excelSelHist={''};
        dflts.doorsSelHist={''};

        dflts.selectIdx=true(1,3);
        dflts.selectIdx(3)=false;
        dflts.isDoorsSetup=false;

        miscSettings.inUse=false;
        dflts.miscSettings=miscSettings;

        reportSettings.highlightModel=true;
        reportSettings.includeMissingReqs=false;
        reportSettings.useDocIndex=false;
        reportSettings.toolsReqReport=false;
        reportSettings.includeTags=false;
        reportSettings.detailsLevel=false;
        reportSettings.linksToObjects=true;
        reportSettings.rptFile='';
        reportSettings.detailsDoors={...
        'Object Heading',...
        'Object Text',...
        '$AllAttributes$','$NonEmpty$',...
        '-Created Thru'};
        reportSettings.detailsWord={};
        reportSettings.navUseMatlab=false;
        reportSettings.followLibraryLinks=false;
        reportSettings.showDetailsWhenHighlighted=true;
        reportSettings.useRelativePath=true;
        reportSettings.mwreqLinkLabelProvider='';
        reportSettings.version=version('-release');
        dflts.reportSettings=reportSettings;

        filterSettings.enabled=false;
        filterSettings.tagsRequire={};
        filterSettings.tagsExclude={};
        filterSettings.filterMenus=false;
        filterSettings.filterConsistency=false;
        filterSettings.filterSurrogateLinks=false;
        filterSettings.linkedOnly=true;
        filterSettings.version=version('-release');
        dflts.filterSettings=filterSettings;

        coverageSettings.enabled=false;
        coverageSettings.maskTypeFilters={};
        coverageSettings.objTypeFilters={};
        coverageSettings.objPathFilters={};
        coverageSettings.version=version('-release');
        dflts.coverageSettings=coverageSettings;

        oslcSettings.serverAddress='';
        oslcSettings.rmRoot='rm';
        oslcSettings.serverUser='';
        oslcSettings.labelTemplate='';
        oslcSettings.serverVersion='';
        oslcSettings.configContextParam='oslc_config.context';
        oslcSettings.stripDefaultPortNumber=false;
        oslcSettings.matchBrowserContext=false;
        oslcSettings.customLoginExec='';
        oslcSettings.useGlobalConfig=false;
        oslcSettings.version=version('-release');
        dflts.oslcSettings=oslcSettings;

        polarionSettings.serverAddress='';
        polarionSettings.projectId='';
        polarionSettings.version=version('-release');
        dflts.polarionSettings=polarionSettings;

        doorsSettings.moduleId='';
        doorsSettings.inwardBacklink=false;
        doorsSettings.syncAnnotations=false;
        doorsSettings.externalLinksHtml=false;
        doorsSettings.version=version('-release');
        dflts.doorsSettings=doorsSettings;

        pathSettings.reqDocBase='';
        pathSettings.resourceBase='';
        dflts.pathSettings=pathSettings;

        dflts.settingsTab=0;

        dflts.selectTag='';

        dflts.protectSurrogateLinks=[];

        dflts.httpPortEnabled=false;


        storageSettings.external=rmiAvailable();

        storageSettings.duplicateOnCopy=getSlFeatureValue('MdlDuplicateRequirementsOnCopy');
        storageSettings.version=version('-release');
        dflts.storageSettings=storageSettings;
    end

    if strcmp(variable,'SAVE')

        settings=fields(dflts);
        settings_file=settings_file_name();
        if exist(settings_file,'file')~=2

            settingsTab=dflts.settingsTab;
            save(settings_file,'settingsTab');
        end
        for i=1:length(settings)

            oneVariable=settings{i};
            eval([oneVariable,'=dflts.',oneVariable]);
            save(settings_file,'-append',oneVariable);
        end
        out=dflts;
    else
        out=dflts.(variable);
    end
end

function slValue=getSlFeatureValue(featureLabel)

    if any(strcmp(inmem,'slfeature'))
        slValue=logical(slfeature(featureLabel));
    else
        switch featureLabel
        case 'MdlDuplicateRequirementsOnCopy'
            slValue=true;
        otherwise
            slValue=false;
        end
    end
end

function flipped=syncSlFeatureValue(featureLabel,rmiValue)
    flipped=false;
    switch featureLabel
    case 'MdlDuplicateRequirementsOnCopy'
        if~any(strcmp(inmem,'slfeature'))&&rmiValue

        else
            current=slfeature(featureLabel);
            if current~=rmiValue
                slfeature(featureLabel,0+rmiValue);
                flipped=true;
            end
            if flipped
                vnv_copy(rmiValue);
            end
        end
    otherwise

    end
end

function out=settings_file_name()
    out=fullfile(prefdir,'rmi_settings.mat');
end

function mySettings=upgradeSettings(mySettings,myVariable)
    switch myVariable
    case 'storageSettings'
        mySettings=upgradeStorageSettings(mySettings);
    case 'linkSettings'
        mySettings=upgradeLinkSettings(mySettings);
    case 'filterSettings'
        mySettings=upgradeFilterSettings(mySettings);
    case 'reportSettings'
        mySettings=upgradeReportSettings(mySettings);
    case 'oslcSettings'
        mySettings=upgradeOslcSettings(mySettings);
    case 'doorsSettings'
        mySettings=upgradeDoorsSettings(mySettings);
    otherwise
    end
end

function doorsSettings=upgradeDoorsSettings(doorsSettings)
    if~isfield(doorsSettings,'inwardBacklink')
        doorsSettings.inwardBacklink=false;
    end
    if~isfield(doorsSettings,'syncAnnotations')
        doorsSettings.syncAnnotations=false;
    end
    if~isfield(doorsSettings,'externalLinksHtml')
        doorsSettings.externalLinksHtml=false;
    end
    doorsSettings.version=version('-release');
    if~isParallel()
        save(settings_file_name(),'-append','doorsSettings');
    end
end

function reportSettings=upgradeReportSettings(reportSettings)
    if~isfield(reportSettings,'includeTags')
        reportSettings.includeTags=false;
    end
    if~isfield(reportSettings,'detailsLevel')
        reportSettings.detailsLevel=false;
    end
    if~isfield(reportSettings,'linksToObjects')
        reportSettings.linksToObjects=true;
    end
    if~isfield(reportSettings,'rptFile')
        reportSettings.rptFile='';
    end
    if~isfield(reportSettings,'detailsDoors')
        reportSettings.detailsDoors={...
        'Object Heading',...
        'Object Text',...
        '$AllAttributes$','$NonEmpty$',...
        '-Created Thru'};
    end
    if~isfield(reportSettings,'navUseMatlab')
        reportSettings.navUseMatlab=false;
    end
    if~isfield(reportSettings,'followLibraryLinks')
        reportSettings.followLibraryLinks=false;
    end
    if~isfield(reportSettings,'showDetailsWhenHighlighted')
        reportSettings.showDetailsWhenHighlighted=true;
    end
    if~isfield(reportSettings,'useRelativePath')
        reportSettings.useRelativePath=true;
    end
    if~isfield(reportSettings,'mwreqLinkLabelProvider')
        reportSettings.mwreqLinkLabelProvider='';
    end
    reportSettings.version=version('-release');
    if~isParallel()
        save(settings_file_name(),'-append','reportSettings');
    end
end

function linkSettings=upgradeLinkSettings(linkSettings)
    if~isfield(linkSettings,'slrefUserBitmap')
        linkSettings.slrefUserBitmap='';
        linkSettings.slrefCustomized=false;
    end
    if~isfield(linkSettings,'useActiveX')
        linkSettings.useActiveX=false;
    end
    if~isfield(linkSettings,'doorsLabelFormat')
        linkSettings.doorsLabelFormat='';
    end
    linkSettings.version=version('-release');
    if~isParallel()
        save(settings_file_name(),'-append','linkSettings');
    end
end

function filterSettings=upgradeFilterSettings(filterSettings)
    if~isfield(filterSettings,'filterSurrogateLinks')
        if isfield(filterSettings,'filterDoorsSurrogateLinks')
            filterSettings.filterSurrogateLinks=filterSettings.filterDoorsSurrogateLinks';
            filterSettings=rmfield(filterSettings,'filterDoorsSurrogateLinks');
        else
            filterSettings.filterSurrogateLinks=false;
        end
        filterSettings.version=version('-release');
        if~isParallel()
            save(settings_file_name(),'-append','filterSettings');
        end
    end
end

function storageSettings=upgradeStorageSettings(storageSettings)
    if~isfield(storageSettings,'duplicateOnCopy')


        storageSettings.duplicateOnCopy=getSlFeatureValue('MdlDuplicateRequirementsOnCopy');
    end
    storageSettings.version=version('-release');
    if~isParallel()
        save(settings_file_name(),'-append','storageSettings');
    end
end

function oslcSettings=upgradeOslcSettings(oslcSettings)
    if~isfield(oslcSettings,'labelTemplate')
        oslcSettings.labelTemplate='';
    end
    if~isfield(oslcSettings,'serverVersion')
        oslcSettings.serverVersion='';
    end
    if~isfield(oslcSettings,'configContextParam')
        oslcSettings.configContextParam='oslc_config.context';
    end
    if~isfield(oslcSettings,'stripDefaultPortNumber')
        oslcSettings.stripDefaultPortNumber=false;
    end
    if~isfield(oslcSettings,'matchBrowserContext')
        oslcSettings.matchBrowserContext=false;
    end
    if~isfield(oslcSettings,'rmRoot')
        if isfield(oslcSettings,'serverSection')
            serviceRoot=oslcSettings.serverSection;
        else
            serviceRoot='rm';
        end
        oslcSettings=rmfield(oslcSettings,'serverSection');
        oslcSettings.rmRoot=serviceRoot;
    end
    if~isfield(oslcSettings,'customLoginExec')
        oslcSettings.customLoginExec='';
    end
    if~isfield(oslcSettings,'useGlobalConfig')
        oslcSettings.useGlobalConfig=false;
    end
    oslcSettings.version=version('-release');
    if~isParallel()
        save(settings_file_name(),'-append','oslcSettings');
    end
end

function yesno=isParallel()
    try
        yesno=~isempty(getCurrentTask());
    catch err
        if~any(strcmp(err.identifier,{'MATLAB:UndefinedFunction','parallel:internal:cluster:JVMNotPresent'}))
            rethrow(err);
        end
        yesno=false;
    end
end

function yesno=rmiAvailable()
    [rmiInstalled,rmiLicenseAvailable]=rmi.isInstalled();
    yesno=rmiInstalled&&rmiLicenseAvailable;
end

