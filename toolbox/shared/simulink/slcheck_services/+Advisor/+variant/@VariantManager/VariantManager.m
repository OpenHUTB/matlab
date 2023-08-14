classdef VariantManager<handle




    properties(Hidden)
        variants={};
        AnalysisRoot='';
        ApplicationID='';

        backupVariants=[];
        backupSelectedCheckInstances={};
    end

    methods

        function applicationObj=getApplicationObj(this)
            applicationObj=Advisor.Manager.getApplication('ID',this.ApplicationID,'token','MWAdvi3orAPICa11');
        end

        function activateVariant(this,variantObj)
            DAStudio.message('ModelAdvisor:engine:ActivateVariant',variantObj.Name);
            if variantObj.isDefinedInVariantManager
                Simulink.VariantConfigurationData.validateModel(bdroot(this.AnalysisRoot),variantObj.Name);
            else
                for i=1:length(variantObj.ControlVariables)
                    assigninGlobalScope(bdroot(this.AnalysisRoot),variantObj.ControlVariables(i).Name,variantObj.ControlVariables(i).Value);
                end
            end
            applicationObj=this.getApplicationObj;
            applicationObj.swapValueSet(variantObj.Name);
        end

        function backupActiveVariant(this)
            applicationObj=this.getApplicationObj;

            this.backupVariants=Simulink.VariantManager.findVariantControlVars(bdroot(this.AnalysisRoot));
            this.backupSelectedCheckInstances=applicationObj.getSelectedCheckInstances;


            this.saveActiveVariant;
        end

        function name=getActiveVariantName(this)
            applicationObj=this.getApplicationObj;
            if~strcmp(applicationObj.ActiveValueSetID,'_unnamed_')
                name=applicationObj.ActiveValueSetID;
            else
                name='';
            end
        end

        function saveActiveVariant(this)
            applicationObj=this.getApplicationObj;
            applicationObj.saveActiveValueSet;
        end

        function restoreActiveVariant(this)
            if~isempty(this.backupVariants)

                model=bdroot(this.AnalysisRoot);
                for i=1:length(this.backupVariants)
                    assigninGlobalScope(model,this.backupVariants(i).Name,this.backupVariants(i).Value);
                end

                applicationObj=this.getApplicationObj;
                applicationObj.swapValueSet('_unnamed_');
            end
        end

        function variants=getVariants(this)
            variants=this.variants;
        end

        function foundVariants=findVariants(this)
            this.variants=[];
            applicationObj=this.getApplicationObj;
            if~isempty(applicationObj.VariantData)
                this.variants=applicationObj.VariantData;
                foundVariants=this.getVariants;
                return
            end
            VariantConfigurationObject=Simulink.variant.utils.getConfigurationDataNoThrow(bdroot(this.AnalysisRoot));
            if isa(VariantConfigurationObject,'Simulink.VariantConfigurationData')
                for i=1:length(VariantConfigurationObject.VariantConfigurations)
                    newVariant=Advisor.variant.Variant;
                    newVariant.Name=VariantConfigurationObject.VariantConfigurations(i).Name;
                    newVariant.Description=VariantConfigurationObject.VariantConfigurations(i).Description;
                    newVariant.isDefinedInVariantManager=true;
                    this.variants{i}=newVariant;
                end
            end
            foundVariants=this.getVariants;
        end

        function matchVariant=findActiveVariantConfigName(this)
            matchVariant='';

            VariantConfigurationObject=Simulink.variant.utils.getConfigurationDataNoThrow(bdroot(this.AnalysisRoot));
            if isa(VariantConfigurationObject,'Simulink.VariantConfigurationData')
                for i=1:length(VariantConfigurationObject.VariantConfigurations)
                    matched=true;
                    ControlVariables=VariantConfigurationObject.VariantConfigurations(i).ControlVariables;
                    for j=1:length(ControlVariables)
                        currentValue=evalinGlobalScope(bdroot(this.AnalysisRoot),ControlVariables(j).Name);
                        if isnumeric(currentValue)
                            currentValue=num2str(currentValue);
                        end
                        if~strcmp(currentValue,ControlVariables(j).Value)
                            matched=false;
                            break;
                        end
                    end
                    if matched
                        matchVariant=VariantConfigurationObject.VariantConfigurations(i).Name;
                        break;
                    end
                end
            end
        end
    end
end
