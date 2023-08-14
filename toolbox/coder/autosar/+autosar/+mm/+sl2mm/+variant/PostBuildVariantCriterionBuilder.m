classdef PostBuildVariantCriterionBuilder<handle




    properties(Access=private)
M3iModel
    end

    properties(SetAccess=private)
PbConstsPkg
    end

    methods
        function this=PostBuildVariantCriterionBuilder(m3iModel,dataTypePackage)
            this.M3iModel=m3iModel;
            this.PbConstsPkg=this.getPbConstsPkg(dataTypePackage);
        end

        function[m3iPbCrit,m3iPbCritValueSet]=findOrCreatePostBuildVariantCriterion(this,pbCritName,pbCritValue)
            arPkg=this.M3iModel.rootModel.RootPackage.at(1);
            assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
            m3iPbCriterionMetaClass=Simulink.metamodel.arplatform.variant.PostBuildVariantCriterion.MetaClass;
            m3iPbCritPkg=this.PbConstsPkg;
            seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,pbCritName,m3iPbCriterionMetaClass);
            m3iPbCritValueSet=[];
            createPbCritValueSet=true;
            if seq.size()==0
                m3iPbCrit=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                m3iPbCritPkg,m3iPbCritPkg.packagedElement,...
                pbCritName,m3iPbCriterionMetaClass.qualifiedName);
            else
                m3iPbCrit=seq.at(1);
                m3iPbCritPkg=m3iPbCrit.containerM3I;
                if autosar.mm.arxml.Exporter.isExternalReference(m3iPbCrit)
                    createPbCritValueSet=false;
                end
            end

            if createPbCritValueSet
                m3iPbCritValueSet=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                m3iPbCritPkg,m3iPbCritPkg.packagedElement,...
                'PostBuildVariantCriterionValSets','Simulink.metamodel.arplatform.variant.PostBuildVariantCriterionValueSet');
                this.findOrCreatePostBuildVariantCriterionValue(...
                m3iPbCritValueSet,m3iPbCrit,pbCritValue);
            end
        end

        function findOrCreatePostBuildVariantCriterionValue(this,m3iPbCritValueSet,m3iPbCrit,pbCritValue)
            m3iPbCritValue=[];
            for jj=1:m3iPbCritValueSet.PostBuildVariantCriterionValue.size()
                if m3iPbCritValueSet.PostBuildVariantCriterionValue.at(jj).VariantCriterion==m3iPbCrit
                    m3iPbCritValue=m3iPbCritValueSet.PostBuildVariantCriterionValue.at(jj);
                    break;
                end
            end
            if isempty(m3iPbCritValue)
                m3iPbCritValue=Simulink.metamodel.arplatform.variant.PostBuildVariantCriterionValue(this.M3iModel);
                try
                    m3iPbCritValue.Value=pbCritValue;
                catch err
                    newError=MSLException('autosarstandard:exporter:InvalidPostBuildVariantCriterionValue',...
                    m3iPbCrit.Name);
                    newError.addCause(err);
                    newError.throw();
                end
                m3iPbCritValue.VariantCriterion=m3iPbCrit;
                m3iPbCritValueSet.PostBuildVariantCriterionValue.append(m3iPbCritValue);
            else
                if Simulink.data.isSupportedEnumClass(class(pbCritValue))
                    pbCritValue=pbCritValue.int32();
                end
                m3iPbCritValue.Value=pbCritValue;
            end
        end

        function m3iPbCritValueSet=findOrCreatePostBuildVariantCriterionValueSet(...
            this,modelName,variantConfig,maxShortNameLength)
            arPkg=this.M3iModel.RootPackage.at(1);
            assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));
            pbCritValueSetName=arxml.arxml_private('p_create_aridentifier',...
            ['PostBuildVariantCriterionValueSet_',variantConfig.Name],maxShortNameLength);
            m3iPbCritsPkg=this.PbConstsPkg;
            m3iPbCritValueSet=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
            m3iPbCritsPkg,m3iPbCritsPkg.packagedElement,...
            pbCritValueSetName,'Simulink.metamodel.arplatform.variant.PostBuildVariantCriterionValueSet');
            for ii=1:numel(variantConfig.ControlVariables)
                pbCritName=variantConfig.ControlVariables(ii).Name;
                valueObj=variantConfig.ControlVariables(ii).Value;
                if~autosar.mm.sl2mm.variant.Utils.isPostBuildVariantCriterion(modelName,pbCritName)
                    continue;
                end

                pbCritValue=valueObj;

                m3iMetaClass=Simulink.metamodel.arplatform.variant.PostBuildVariantCriterion.MetaClass;
                seq=Simulink.metamodel.arplatform.ModelFinder.findObjectInModel(arPkg,pbCritName,m3iMetaClass);
                if seq.size()==0
                    m3iPbCrit=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                    m3iPbCritsPkg,m3iPbCritsPkg.packagedElement,...
                    pbCritName,m3iMetaClass.qualifiedName);
                else
                    m3iPbCrit=seq.at(1);
                end
                this.findOrCreatePostBuildVariantCriterionValue(...
                m3iPbCritValueSet,m3iPbCrit,pbCritValue);
            end
        end

        function createPostBuildVariantCondition(this,m3iVariationPointOrProxy,pbCritName,activeValue,pbCondValue)
            arPkg=this.M3iModel.RootPackage.at(1);
            assert(isa(arPkg,'Simulink.metamodel.arplatform.common.AUTOSAR'));

            m3iPostBuildVariantCriterion=this.findOrCreatePostBuildVariantCriterion(pbCritName,pbCondValue);

            m3iMetaClass=Simulink.metamodel.arplatform.variant.PostBuildVariantCondition.MetaClass;
            m3iPbCond=autosar.mm.sl2mm.ModelBuilder.createInSequenceNamedItem(...
            m3iVariationPointOrProxy,m3iVariationPointOrProxy.PostBuildVariantCondition,...
            '',m3iMetaClass.qualifiedName);
            m3iPbCond.MatchingCriterion=m3iPostBuildVariantCriterion;
            m3iPbCond.Value=activeValue;
        end
    end

    methods(Access=private)
        function m3iPbConstsPkg=getPbConstsPkg(this,dataTypePackage)




            arRoot=this.M3iModel.RootPackage.at(1);
            PbConstPkg=autosar.mm.util.XmlOptionsAdapter.get(...
            arRoot,'PostBuildCriterionPackage');
            if isempty(PbConstPkg)
                PbConstPkg=[dataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.PostBuildCriterions];
                autosar.mm.util.XmlOptionsAdapter.set(...
                arRoot,'PostBuildCriterionPackage',PbConstPkg);
            end

            m3iPbConstsPkg=autosar.mm.Model.getOrAddARPackage(this.M3iModel,PbConstPkg);
        end
    end
end



