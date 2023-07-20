classdef PredefinedVariantBuilder<handle





    properties
        MaxShortNameLength;
        SystemConstantBuilder;
        PostBuildVariantCriterionBuilder;
        SharedM3IModel;
        ModelName;
        CodeDescriptor;
    end

    methods
        function this=PredefinedVariantBuilder(modelName,systemConstantBuilder,postBuildVariantCriterionBuilder,sharedM3IModel,codeDescriptor)
            this.ModelName=modelName;
            this.SystemConstantBuilder=systemConstantBuilder;
            this.PostBuildVariantCriterionBuilder=postBuildVariantCriterionBuilder;
            this.SharedM3IModel=sharedM3IModel;
            this.CodeDescriptor=codeDescriptor;
            this.MaxShortNameLength=...
            get_param(modelName,'AutosarMaxShortNameLength');
        end

        function findOrCreatePredefinedVariants(this)



            if~this.codeDescHasVariantAnnotations()

                return;
            end

            configObjName=get_param(this.ModelName,'VariantConfigurationObject');
            if isempty(configObjName)

                return;
            end

            if isempty(get_param(this.ModelName,'DataDictionary'))
                configObj=evalinGlobalScope(this.ModelName,configObjName);
            else
                configObj=slprivate('evalinScopeSection',this.ModelName,configObjName,'Configurations',true);
            end

            for ii=1:numel(configObj.VariantConfigurations)
                variantConfig=configObj.VariantConfigurations(ii);
                this.findOrCreatePredefinedVariant(variantConfig);
            end
        end
    end

    methods(Access=private)
        function findOrCreatePredefinedVariant(this,variantConfig)
            arPkg=this.SharedM3IModel.RootPackage.at(1);
            m3iPredefinedVariantMetaClass=Simulink.metamodel.arplatform.variant.PredefinedVariant.MetaClass;
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(...
            arPkg,variantConfig.Name,m3iPredefinedVariantMetaClass);
            if seq.size()>0

                m3iPredefinedVariant=seq.at(1);
            else

                m3iSysConstsPkg=this.SystemConstantBuilder.SysConstsPkg;
                m3iPredefinedVariant=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                m3iSysConstsPkg,m3iSysConstsPkg.packagedElement,...
                variantConfig.Name,m3iPredefinedVariantMetaClass.qualifiedName);
            end

            m3iSysConstValueSet=this.SystemConstantBuilder.findOrCreateSystemConstantValueSet(...
            variantConfig,this.MaxShortNameLength);
            if~isempty(m3iSysConstValueSet)
                m3iPredefinedVariant.SysConstValueSet.append(m3iSysConstValueSet);
            end

            if slfeature('AUTOSARPostBuildVariant')
                m3iPbVarCritValueSet=this.PostBuildVariantCriterionBuilder.findOrCreatePostBuildVariantCriterionValueSet(...
                this.ModelName,variantConfig,this.MaxShortNameLength);
                if~isempty(m3iPbVarCritValueSet)
                    m3iPredefinedVariant.PostBuildVariantCriterionValueSet.append(m3iPbVarCritValueSet);
                end
            end
        end
    end

    methods(Access=private)
        function hasVariantAnnotations=codeDescHasVariantAnnotations(this)
            preBuildAnno=this.CodeDescriptor.getFullComponentInterface.VariantAnnotations.toArray;
            if slfeature('AUTOSARPostBuildVariant')
                postBuildAnno=this.CodeDescriptor.getFullComponentInterface.PostBuildVariantAnnotations.toArray;
            else
                postBuildAnno=[];
            end
            hasVariantAnnotations=~isempty(preBuildAnno)||~isempty(postBuildAnno);
        end
    end
end


