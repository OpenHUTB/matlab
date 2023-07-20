classdef VariantConfigurationsCacheWrapper<handle





    properties(SetAccess=private)
        VariantConfigurationCatalog(1,1)Simulink.VariantConfigurationData;
        VariantConfigurationCatalogCache(1,1)Simulink.VariantConfigurationData;
        IsVariantConfigurationMissingInWks(1,1)logical=false;
        ModelName='';
        ConfigWorkspace=slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceTitle;
    end

    methods(Access=private)

        function checkSLDDValidity(obj,bdName)
            ddSpec=get_param(bdName,'DataDictionary');
            if~isempty(ddSpec)

                try

                    Simulink.dd.open(ddSpec);
                    obj.ConfigWorkspace=ddSpec;
                catch excep



                    ddExcep=MException(message('Simulink:VariantManager:VariantManagerV2ErrorWhileLaunching',bdName));
                    ddExcep=ddExcep.addCause(excep);
                    throwAsCaller(ddExcep);
                end
            end
        end

        function sourceConfigObj=getSourceConfigObjFromBaseWks(~,configName)
            sourceConfigObj=[];
            varExists=evalin('base',['exist(''',configName,''', ''var'');']);
            if varExists


                sourceConfigObj=evalin('base',configName);
                if~isa(sourceConfigObj,'Simulink.VariantConfigurationData')
                    sourceConfigObj=[];
                end
            end
        end

        function sourceConfigObj=getSourceConfigObjFromSLDD(obj,bdName,configName)
            sourceConfigObj=[];
            checkSLDDValidity(obj,bdName);
            ddSpec=get_param(bdName,'DataDictionary');
            ddConn=Simulink.dd.open(ddSpec);
            varExists=false;
            hasAccessToBaseWks=strcmp(get_param(bdName,'HasAccessToBaseWorkspace'),'on');


            section='Configurations';
            inConfigurationsSectionDD=ddConn.entryExists(['Configurations','.',configName],true);
            inGlobalSectionDD=ddConn.entryExists(['Global','.',configName],true);
            inDD=inConfigurationsSectionDD||inGlobalSectionDD;
            if hasAccessToBaseWks&&~inDD
                varExists=evalin('base',['exist(''',configName,''', ''var'');']);
            elseif inConfigurationsSectionDD
                varExists=true;
            else
                section='Global';
                if inGlobalSectionDD
                    varExists=true;
                end
            end
            if~varExists
                return;
            end
            if~inDD&&hasAccessToBaseWks


                sourceConfigObj=evalin('base',configName);
            elseif inConfigurationsSectionDD

                try










                    warnStateDC=warning('off','Simulink:VariantManager:DefaultConfigurationRemoved');
                    warnStateSMC=warning('off','Simulink:VariantManager:SubModelConfigsRemoved');
                    warnStateDCCleanup=onCleanup(@()warning(warnStateDC));
                    warnStateSMCCleanup=onCleanup(@()warning(warnStateSMC));
                    sourceConfigObj=Simulink.variant.utils.evalExpressionInSection(...
                    bdName,configName,section);
                    warnStateDCCleanup=[];warnStateSMCCleanup=[];%#ok<NASGU>
                catch excep


                    ddExcep=MException(message('Simulink:VariantManager:VariantManagerV2ErrorWhileLaunching',bdName));
                    ddExcep=ddExcep.addCause(excep);
                    throwAsCaller(ddExcep);
                end
            else
                sourceConfigObj=Simulink.variant.utils.evalExpressionInSection(...
                bdName,configName,section);
            end
        end

        function sourceConfigObj=getSourceConfigObjHelper(obj,bdName,configName)
            ddSpec=get_param(bdName,'DataDictionary');
            warnState=warning('off','Simulink:VariantManager:DefaultConfigurationRemoved');
            warnStateCleanup=onCleanup(@()warning(warnState));
            if isempty(ddSpec)

                sourceConfigObj=getSourceConfigObjFromBaseWks(obj,configName);
            else
                sourceConfigObj=getSourceConfigObjFromSLDD(obj,bdName,configName);
            end
        end

        function sourceConfigObj=getSourceConfigObj(obj,bdName,configName)
            if isempty(configName)
                configName=get_param(bdName,'VariantConfigurationObject');
            end
            sourceConfigObj=getSourceConfigObjHelper(obj,bdName,configName);

            if isempty(sourceConfigObj)||~isscalar(sourceConfigObj)
                obj.IsVariantConfigurationMissingInWks=true;
                sourceConfigObj=Simulink.VariantConfigurationData();
                return;
            end

            if isa(sourceConfigObj,'Simulink.VariantConfigurationData')




                slvariants.internal.config.migrateVCD(sourceConfigObj,bdName);
            end
        end

    end

    methods(Access=public)
        function obj=VariantConfigurationsCacheWrapper(isSourceObjProvided,src,vcdName)
            if nargin==2
                vcdName=[];
            end


            if isSourceObjProvided


                sourceObj=src;
            else

                obj.ModelName=src;
                sourceObj=obj.getSourceConfigObj(obj.ModelName,vcdName);
            end
            obj.VariantConfigurationCatalog=sourceObj;
            obj.VariantConfigurationCatalogCache=copy(sourceObj);
        end

        function saveCacheToVariantConfigurationCatalog(obj)
            obj.VariantConfigurationCatalog=copy(obj.VariantConfigurationCatalogCache);
        end

        function resetVariantConfigurationCatalogCache(obj)
            obj.VariantConfigurationCatalogCache=copy(obj.VariantConfigurationCatalog);
        end

        function applyVariantConfigurationCatalogCache(obj,configObjVarName)

            obj.saveCacheToVariantConfigurationCatalog();
            obj.VariantConfigurationCatalog.AreSubModelConfigurationsMigrated=true;
            modelName=obj.ModelName;
            isModelLoaded=bdIsLoaded(modelName);

            if~isModelLoaded
                try
                    load_system(modelName);
                catch excep
                    throwAsCaller(excep)
                end
            end

            currentNameOfVariantConfigurationCatalog=get_param(modelName,'VariantConfigurationObject');
            if~strcmp(configObjVarName,currentNameOfVariantConfigurationCatalog)
                set_param(modelName,'VariantConfigurationObject',configObjVarName);
            end

            if~isempty(configObjVarName)
                Simulink.variant.utils.slddaccess.assignInConfigurationsSection(...
                modelName,configObjVarName,copy(obj.VariantConfigurationCatalog));
            end
        end

        function refreshVariantConfigurationCatalog(obj,configObjVarName)


            sourceObj=obj.getSourceConfigObj(obj.ModelName,configObjVarName);
            obj.VariantConfigurationCatalog=sourceObj;
            obj.VariantConfigurationCatalogCache=copy(sourceObj);
        end

        function setVariantConfigurationCatalog(obj,sourceObj)
            obj.VariantConfigurationCatalog=sourceObj;
            obj.VariantConfigurationCatalogCache=copy(sourceObj);
        end

        function deepCopyVariantConfigurationCatalog(obj)
            obj.VariantConfigurationCatalog=copy(obj.VariantConfigurationCatalogCache);
        end

        function updateConfigWorkspace(obj,ddName)
            if isempty(ddName)
                obj.ConfigWorkspace=slvariants.internal.manager.ui.config.VMgrConstants.BaseWorkspaceTitle;
            else
                obj.ConfigWorkspace=ddName;
            end
        end
    end
end


