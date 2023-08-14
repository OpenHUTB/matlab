classdef(Sealed,Hidden)ConfigHandler<handle




    methods(Access=public)

        function obj=ConfigHandler(reductionInfo)
            obj.ReductionInfo=reductionInfo;
            obj.CompileHandler=slvariants.internal.reducer.CompileHandler;
            obj.VarNameSimParamExpressionHierarchyMap=containers.Map();
        end

        function compH=getCompileHandler(obj)
            compH=obj.CompileHandler;
        end

        function delete(obj)
            obj.VarNameSimParamExpressionHierarchyMap=containers.Map();
        end

        function processConfigs(obj)
            obj.handleConfigSpecifiedAsVariables();
        end

        function validateSlExpr(obj)



            errid='Simulink:VariantReducer:InconsistentSlexprDefinitions';
            if slfeature('VMGRV2UI')>0
                try
                    slvariants.internal.configobj.throwInconsistentSlexprDefinitions(...
                    obj.ReductionInfo.getReducedModelName(),...
                    obj.ReductionInfo.getReductionOptions().getNamedConfigurations(),...
                    errid);
                catch ex
                    throwAsCaller(ex);
                end
            else
                dataDictionaries=obj.VarNameSimParamExpressionHierarchyMap.keys;
                for idx=1:numel(dataDictionaries)


                    err=Simulink.variant.utils.getInconsistentSlexprError(...
                    obj.VarNameSimParamExpressionHierarchyMap(dataDictionaries{idx}),...
                    numel(obj.ReductionInfo.getConfigInfos()),errid);
                    if isempty(err)
                        continue;
                    end
                    throwAsCaller(err);
                end
            end
        end

        function compileForConfig(obj,configName)
            if~isempty(configName)
                validateModelForConfig(obj,configName);
            end


            obj.CompileHandler.compile();
        end

        function frInfo=getFullRangeAnalysisInfo(obj)
            frInfo=obj.FullRangeAnalysisInfo;
        end

        function configsForSummary=getConfigsForSummary(obj)
            namedConfigs=obj.ReductionInfo.getReductionOptions().getNamedConfigurations();
            origModelName=obj.ReductionInfo.getReductionOptions().getModelName();
            reducedModelName=obj.ReductionInfo.getReducedModelName();


            if obj.ReductionInfo.getReductionOptions().getConfigSpecifiedAsVariableGroups()
                vcd=Simulink.variant.utils.getConfigurationDataNoThrow(reducedModelName);
            else
                vcd=Simulink.variant.utils.getConfigurationDataNoThrow(origModelName);
            end
            configsForSummary=struct('ModelName','',...
            'Name','',...
            'Description','',...
            'ControlVariables',[],...
            'SubModelConfigurations',[]);
            configsForSummary(end)=[];
            if isempty(vcd)
                return;
            end
            for outIdx=1:numel(namedConfigs)
                for idx=1:numel(vcd.Configurations)
                    if(strcmp(namedConfigs(outIdx),vcd.Configurations(idx).Name))
                        configsForSummary(idx).ModelName=origModelName;
                        configsForSummary(idx).Name=vcd.Configurations(idx).Name;
                        configsForSummary(idx).Description=vcd.Configurations(idx).Description;
                        configsForSummary(idx).ControlVariables=vcd.Configurations(idx).ControlVariables;
                        configsForSummary(idx).SubModelConfigurations=[];
                        break;
                    end
                end
            end
        end
    end

    methods(Access=private)

        function validateModelForConfig(obj,currCfgName)
            slvariants.internal.reducer.log(['Validating model for config ',currCfgName]);


            if slfeature('VMgrV2UI')>0
                [~,errors]=slvariants.internal.manager.core.activateModel(obj.ReductionInfo.getReducedModelName(),currCfgName);
            else
                optArgs=struct('ConfigurationName',currCfgName,...
                'VarNameSimParamExpressionHierarchyMap',...
                obj.VarNameSimParamExpressionHierarchyMap);
                validationLog=[];
                [errors,~]=Simulink.variant.manager.configutils.validateModelEntry(...
                obj.ReductionInfo.getReducedModelName(),...
                validationLog,optArgs);
            end
            if~isempty(errors)
                slvariants.internal.reducer.log('Model validation failed');

                vcd=Simulink.variant.utils.getConfigurationDataNoThrow(obj.ReductionInfo.getReducedModelName());
                obj.throwVCDConfigErrors(vcd,currCfgName);
                Simulink.variant.reducer.utils.throwInvalidConfig(...
                obj.ReductionInfo.getReductionOptions().getModelName(),...
                obj.ReductionInfo.getReductionOptions().getConfigSpecifiedAsVariableGroups(),...
                vcd.getConfiguration(currCfgName),...
                errors);
            end
        end

        function handleConfigSpecifiedAsVariables(obj)
            if~obj.ReductionInfo.getReductionOptions().getConfigSpecifiedAsVariableGroups()
                return;
            end
            createVCDOWithNamedConfigurations(obj);
        end

        function createVCDOWithNamedConfigurations(obj)
            configInfos=obj.ReductionInfo.getConfigInfos();
            redMdlName=obj.ReductionInfo.getReducedModelName();
            [configInfos,obj.FullRangeAnalysisInfo]=...
            Simulink.variant.reducer.fullrange.FullRangeManager.processControlVars(...
            redMdlName,...
            configInfos,...
            obj.ReductionInfo().getFullRangeVariables());

            vcdoObj=Simulink.variant.variablegroups.VCDOImpl(...
            redMdlName,obj.ReductionInfo.getReductionOptions().getModelName(),configInfos);
            vtcObj=Simulink.variant.variablegroups.VarsToConfigImpl();
            vtcObj.convertVarsToObject(vcdoObj);
            newVCDO=vcdoObj.newVCDO;
            hasExcludeFiles=~isempty(obj.ReductionInfo.getReductionOptions().getExcludeFiles());
            numVarGroupsAsConfigs=length(newVCDO.Configurations);
            if hasExcludeFiles&&numVarGroupsAsConfigs>1


                errid='Simulink:VariantReducer:MultiVariableGroupsExcludeFilesUnsupported';
                err=MException(message(errid));
                throwAsCaller(err);
            end


            varsInGlobalWS=Simulink.variant.utils.evalStatementInConfigurationsSection(...
            redMdlName,'whos');
            redModelVCDOName=Simulink.variant.reducer.utils.getUniqueName(...
            [redMdlName,'_VCDO'],{varsInGlobalWS.name});
            set_param(redMdlName,'VariantConfigurationObject',redModelVCDOName);





            toDelete=true;
            obj.ReductionInfo.getEnvironment().addVCDOForModel(redMdlName,redModelVCDOName,...
            newVCDO,toDelete);

            configInfos={newVCDO.VariantConfigurations.Name};
            obj.ReductionInfo.setGeneratedNamedCfgs(configInfos);
        end

        function throwVCDConfigErrors(obj,vcd,currCfgName)
            origMdlName=obj.ReductionInfo.getReductionOptions().getModelName();

            if~isempty(currCfgName)&&isempty(vcd)


                errid='Simulink:Variants:ConfigDataNotFoundForModel';
                errmsg=message(errid,origMdlName,currCfgName);
                err=MException(errmsg);
                throwAsCaller(err);
            end

            try
                vcd.getConfiguration(currCfgName);
            catch vcdExcep
                Simulink.variant.reducer.utils.logException(vcdExcep);


                errid='Simulink:Variants:ConfigNotFoundForModel';
                vcdoName=get_param(origMdlName,'VariantConfigurationObject');
                errmsg=message(errid,currCfgName,vcdoName,origMdlName);
                err=MException(errmsg);
                throwAsCaller(err);
            end
        end

    end

    properties(Access=private)


        ReductionInfo slvariants.internal.reducer.ReductionInfo;

        CompileHandler slvariants.internal.reducer.CompileHandler;


        FullRangeAnalysisInfo=[];


        VarNameSimParamExpressionHierarchyMap;

    end

end

