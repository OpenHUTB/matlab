function mdladvObj=getModelAdvisor(system,varargin)





    argumentStruct=parseArguments(varargin{:});

    [RunningInBackground,mdladvObj]=checkBackgroundRun(system,argumentStruct);
    if RunningInBackground
        return;
    end

    if argumentStruct.force

        activeMAObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;
        if isa(activeMAObj,'Simulink.ModelAdvisor')

            if isa(activeMAObj.ConfigUIWindow,'DAStudio.Explorer')
                DAStudio.error('Simulink:tools:MAUnableStartMAWhenMACEOpen');
            end

            try
                if isa(activeMAObj.ResultGUI,'DAStudio.Informer')&&~strcmp(getfullname(bdroot(system)),bdroot(activeMAObj.SystemName))
                    slprivate('remove_hilite',bdroot(activeMAObj.SystemHandle));
                end
            catch %#ok<CTCH> 815942

            end

            caller=dbstack;
            accordionCall=false;
            for i=1:length(caller)
                if~isempty(strfind(caller(i).name,'MECallback'))
                    accordionCall=true;
                    break;
                end
            end

            if accordionCall



                if nargin>2&&~strcmp(activeMAObj.CustomTARootID,argumentStruct.customRoot)
                    modeladvisorprivate('modeladvisorutil2','SaveTaskAdvisorMiniInfo',activeMAObj);
                    if isa(activeMAObj.MAExplorer,'DAStudio.Explorer')


                        activeMAObj.MAExplorer.delete
                    end
                end
            end
        end
    end

    [SpecifiedStartConfigFilePath,StartConfigFilePath]=loc_generateConfigInfo(argumentStruct);

    if ischar(system)
        system=remove_mdl_ext(system);
    end






















    Simulink.ModelAdvisor.checkEnvironment(system);

    am=Advisor.Manager.getInstance;
    systemName=getfullname(system);














    if argumentStruct.OmittedArguments

        app=Advisor.Manager.getActiveApplicationObj();


        if~isempty(app)

            mdladvObj=app.getMAObjs('System',systemName);
        else
            mdladvObj={};
        end


        if~isempty(mdladvObj)

            mdladvObj=mdladvObj{1};

        else




            bdName=bdroot(systemName);

            rootType=Advisor.component.Types.SubSystem;
            root=systemName;
            if strcmp(bdName,systemName)
                rootType=Advisor.component.Types.Model;
            end



            applicationObj=am.getApplication('advisor',argumentStruct.customRoot,...
            'Root',systemName,'RootType',rootType,...
            'Legacy',true,'MultiMode',false,'token','MWAdvi3orAPICa11');

            if isempty(applicationObj)
                applicationObj=loc_createApplication(argumentStruct.customRoot,root,...
                rootType,StartConfigFilePath,argumentStruct.WorkingDir);
            end


            mdladvObj=applicationObj.getRootMAObj();
        end



    else
        bdName=bdroot(systemName);

        rootType=Advisor.component.Types.SubSystem;
        root=systemName;
        if strcmp(bdName,systemName)
            rootType=Advisor.component.Types.Model;
        end



        applicationObj=am.getApplication('advisor',argumentStruct.customRoot,...
        'Root',systemName,'RootType',rootType,...
        'Legacy',true,'MultiMode',false,'token','MWAdvi3orAPICa11');

        if isempty(applicationObj)
            applicationObj=loc_createApplication(argumentStruct.customRoot,root,...
            rootType,StartConfigFilePath,argumentStruct.WorkingDir);


            mdladvObj=applicationObj.getRootMAObj();
        else




            mdladvObj=applicationObj.getRootMAObj();



            if~isa(mdladvObj,'Simulink.ModelAdvisor')||mdladvObj.ContinueViewExistRpt

                applicationObj.delete();

                applicationObj=loc_createApplication(argumentStruct.customRoot,root,...
                rootType,StartConfigFilePath,argumentStruct.WorkingDir);


                mdladvObj=applicationObj.getRootMAObj();



            elseif SpecifiedStartConfigFilePath&&...
                ~strcmp(mdladvObj.StartConfigFilePath,StartConfigFilePath)&&~strcmp(StartConfigFilePath,'_empty_')




                if isa(mdladvObj.MAExplorer,'DAStudio.Explorer')&&mdladvObj.MAExplorer.isVisible

                    if isempty(argumentStruct.WorkingDir)

                        DAStudio.error('Simulink:tools:MAErrorChangeWorkConfiguration',...
                        mdladvObj.StartConfigFilePath);
                    else




                        applicationObj.delete();

                        applicationObj=loc_createApplication(argumentStruct.customRoot,root,...
                        rootType,StartConfigFilePath,argumentStruct.WorkingDir);


                        mdladvObj=applicationObj.getRootMAObj();
                    end
                else
                    applicationObj.loadConfiguration(StartConfigFilePath);


                    mdladvObj=applicationObj.getRootMAObj();
                end
            else

            end
        end
    end



    Simulink.ModelAdvisor.getActiveModelAdvisorObj(mdladvObj);









    if SpecifiedStartConfigFilePath



        if strcmp(StartConfigFilePath,'_empty_')
            return
        end

        fullPath=which(mdladvObj.StartConfigFilePath);


        if~isempty(mdladvObj.StartConfigFilePath)&&(~(strcmp(mdladvObj.StartConfigFilePath,StartConfigFilePath)||...
            strcmp(fullPath,StartConfigFilePath))...
            &&~isempty(mdladvObj.CheckCellArray))
            DAStudio.error('Simulink:tools:MAErrorChangeWorkConfiguration',mdladvObj.StartConfigFilePath);
        end
    end


    function app=loc_createApplication(customTARoot,root,rootType,...
        StartConfigFilePath,workingDir)

        am=Advisor.Manager.getInstance();

        app=am.createApplication('Advisor',customTARoot,'token','MWAdvi3orAPICa11');

        if~isempty(workingDir)
            app.setWorkingDir(workingDir);
        end

        try
            app.setAnalysisRoot('Root',root,'RootType',rootType,...
            'legacy',true,'configFile',StartConfigFilePath);
        catch E
            app.delete();
            rethrow(E);
        end


        function[flag,mdladvObj]=checkBackgroundRun(system,argumentStruct)
            flag=false;
            mdladvObj=[];
            if ModelAdvisor.isRunning
                mdladvObj=Simulink.ModelAdvisor.getActiveModelAdvisorObj;

                if~argumentStruct.OmittedArguments&&...
                    (~strcmp(argumentStruct.customRoot,'_modeladvisor_')||...
                    ~strcmp(getfullname(system),mdladvObj.SystemName))



                    if strcmp(argumentStruct.customRoot,UpgradeAdvisor.UPGRADE_GROUP_ID)
                        DAStudio.error('ModelAdvisor:engine:MABackgroundRunningWarning');
                    else
                        DAStudio.warning('ModelAdvisor:engine:MABackgroundRunningWarning');
                    end
                end
                flag=true;
                return;
            end

            function[SpecifiedStartConfigFilePath,StartConfigFilePath]=loc_generateConfigInfo(argumentsStruct)
                SpecifiedStartConfigFilePath=argumentsStruct.configurationSpecified;
                StartConfigFilePath='';
                if argumentsStruct.configurationSpecified
                    if~isempty(argumentsStruct.configuration)
                        StartConfigFilePath=argumentsStruct.configuration;

                        if~strcmp(StartConfigFilePath,'shipping')

                            [~,~,StartConfigFilePathext]=fileparts(StartConfigFilePath);
                            if isempty(StartConfigFilePathext)
                                if exist([StartConfigFilePath,'.json'],'file')
                                    StartConfigFilePath=[StartConfigFilePath,'.json'];
                                elseif exist([StartConfigFilePath,'.mat'],'file')
                                    StartConfigFilePath=[StartConfigFilePath,'.mat'];
                                end
                            end
                            if~exist(StartConfigFilePath,'file')
                                DAStudio.error('Simulink:tools:MAInvalidConfigFile',StartConfigFilePath);
                            end
                        end
                    else
                        StartConfigFilePath='_empty_';
                    end
                end

                function system=remove_mdl_ext(system)

                    system=fliplr(system);
                    if strncmpi(system,'ldm.',4)
                        system=system(5:end);
                    end
                    system=fliplr(system);



















                    function argumentStruct=parseArguments(varargin)

                        ip=inputParser();

                        if nargin==0
                            argumentStruct.customRoot='_modeladvisor_';
                            argumentStruct.force=false;
                            argumentStruct.configuration='';
                            argumentStruct.configurationSpecified=false;
                            argumentStruct.OmittedArguments=true;
                            argumentStruct.WorkingDir='';

                        elseif nargin==1&&strcmp(varargin{1},'new')
                            argumentStruct.customRoot='_modeladvisor_';
                            argumentStruct.force=true;
                            argumentStruct.configuration='';
                            argumentStruct.configurationSpecified=false;
                            argumentStruct.OmittedArguments=false;
                            argumentStruct.WorkingDir='';

                        elseif nargin==2&&strcmp(varargin{1},'new')
                            argumentStruct.customRoot=varargin{2};
                            argumentStruct.force=true;
                            argumentStruct.configuration='';
                            argumentStruct.configurationSpecified=false;
                            argumentStruct.OmittedArguments=false;
                            argumentStruct.WorkingDir='';

                        elseif nargin>2&&strcmp(varargin{1},'new')

                            ip.addParameter('configuration','X');
                            ip.parse(varargin{3:end});
                            argumentStruct=ip.Results;
                            argumentStruct.OmittedArguments=false;
                            argumentStruct.customRoot=varargin{2};
                            argumentStruct.force=true;
                            argumentStruct.WorkingDir='';

                            if strcmp(argumentStruct.configuration,'X')
                                argumentStruct.configurationSpecified=false;
                                argumentStruct.configuration='';
                            else
                                argumentStruct.configurationSpecified=true;
                            end

                        else
                            ip.addParameter('customRoot','_modeladvisor_');
                            ip.addParameter('configuration','X');
                            ip.addParameter('force',false);
                            ip.addParameter('WorkingDir','');
                            ip.parse(varargin{:});
                            argumentStruct=ip.Results;
                            argumentStruct.OmittedArguments=false;
                            if strcmp(argumentStruct.configuration,'X')
                                argumentStruct.configurationSpecified=false;
                                argumentStruct.configuration='';
                            else
                                argumentStruct.configurationSpecified=true;
                            end
                        end


                        if isempty(argumentStruct.customRoot)
                            argumentStruct.customRoot='_modeladvisor_';
                        end
