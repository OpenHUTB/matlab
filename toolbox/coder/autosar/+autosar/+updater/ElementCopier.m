classdef ElementCopier<handle





    properties(Constant)
        ValidDatatypeCategories={'ApplicationDataType','ImplementationDataType','SwBaseType'};
        ValidInterfaceCategories={'ClientServerInterface','SenderReceiverInterface',...
        'ModeSwitchInterface','TriggerInterface','ParameterInterface',...
        'NvDataInterface','ServiceInterface','PersistencyKeyValueInterface'};
        ValidOtherCategories={'CompuMethod','Unit','Dimension',...
        'SystemConst','SystemConstValueSet','PredefinedVariant',...
        'SwRecordLayout','SwAddrMethod','ConstantSpecification',...
        'DataConstr','ModeDeclarationGroup','DataTypeMappingSet'};
        SupportedCategories=[...
        autosar.updater.ElementCopier.ValidDatatypeCategories,...
        autosar.updater.ElementCopier.ValidInterfaceCategories,...
        autosar.updater.ElementCopier.ValidOtherCategories];
    end

    properties(SetAccess=immutable,GetAccess=private)
        SrcM3IModel;
        DstM3IModel;
        MMChangeLogger;
        MarkCopiedElementsAsReadOnly;


        Categories;
        Packages;
        RootPaths;
    end

    methods

        function this=ElementCopier(srcM3IModel,dstM3IModel,mmChangeLogger,...
            markCopiedElmsAsReadOnly,...
            categories,packages,rootPaths)
            this.SrcM3IModel=srcM3IModel;
            this.DstM3IModel=dstM3IModel;
            this.MMChangeLogger=mmChangeLogger;
            this.MarkCopiedElementsAsReadOnly=markCopiedElmsAsReadOnly;


            if nargin>4
                this.Categories=categories;
                this.Packages=packages;
                this.RootPaths=rootPaths;
            end
        end

        function copy(this)


            if isempty(this.Categories)&&isempty(this.Packages)&&...
                isempty(this.RootPaths)

                m3iElmsToCopy=this.getElementsToCopy();

            else

                m3iElmsToCopy=this.getUserSpecifiedElementsToCopy(...
                this.Categories,this.Packages,this.RootPaths);
            end


            autosar.updater.ElementCopier.validateElementsToCopy(m3iElmsToCopy);


            m3iCopiedElms=this.copyElements(m3iElmsToCopy);



            this.processCopiedElements(m3iCopiedElms);
        end


        function m3iCopiedElms=copyElements(this,m3iObjSeq)
            copier=Simulink.metamodel.arplatform.ElementCopier(this.SrcM3IModel,this.DstM3IModel);
            for i=1:m3iObjSeq.size()
                m3iObj=m3iObjSeq.at(i);
                copier.deepCopy(m3iObj);
            end
            m3iCopiedElms=copier.getCopiedElements();






            Simulink.metamodel.arplatform.ModelFinder.removeDuplicatesInSequence(m3iCopiedElms);
        end
    end


    methods(Static,Access=private)
        function validateElementsToCopy(m3iObjSeq)

            unsupportedElements=[];
            for i=1:m3iObjSeq.size()
                m3iObj=m3iObjSeq.at(i);
                if isa(m3iObj,'Simulink.metamodel.arplatform.component.Component')
                    unsupportedElements{end+1}=autosar.api.Utils.getQualifiedName(m3iObj);%#ok<AGROW>
                end
            end
            if~isempty(unsupportedElements)
                DAStudio.error('autosarstandard:importer:UpdateReferencesUnsupportedMetaClass',...
                autosar.api.Utils.cell2str(unsupportedElements));
            end
        end
    end

    methods(Access=private)
        function processCopiedElements(this,m3iCopiedElms)


            if this.MarkCopiedElementsAsReadOnly&&~m3iCopiedElms.isEmpty()
                arRoot=m3iCopiedElms.at(1).rootModel.RootPackage.front();
                autosar.mm.Model.setExtraExternalToolInfo(arRoot,...
                'ARXML_HasExternalReference',{'%s'},{'1'});
            end
            for ii=1:m3iCopiedElms.size()
                m3iCopiedElm=m3iCopiedElms.at(ii);
                toolId='ARXML_IsReference';
                if this.MarkCopiedElementsAsReadOnly
                    m3iCopiedElm.setExternalToolInfo(M3I.ExternalToolInfo(toolId,'1'));
                else
                    m3iCopiedElm.removeExternalToolInfo(M3I.ExternalToolInfo(toolId,''));
                end


                if isa(m3iCopiedElm,'Simulink.metamodel.foundation.NamedElement')
                    this.MMChangeLogger.logAddition('MetaModel',m3iCopiedElm.MetaClass().name,...
                    autosar.api.Utils.getQualifiedName(m3iCopiedElm));
                end
            end
        end


        function m3iObjSeq=getElementsToCopy(this)
            m3iObjSeq=M3I.SequenceOfClassObject.make(this.SrcM3IModel);
            m3iPkgElms=autosar.mm.Model.findObjectByMetaClass(this.SrcM3IModel,...
            Simulink.metamodel.foundation.PackageableElement.MetaClass,true,true);
            for i=1:m3iPkgElms.size()
                m3iPkgElm=m3iPkgElms.at(i);
                if~isa(m3iPkgElm,'Simulink.metamodel.arplatform.common.Package')&&...
                    ~isa(m3iPkgElm,'Simulink.metamodel.arplatform.common.AUTOSAR')
                    m3iObjSeq.push_back(m3iPkgElm);
                end
            end
        end

        function m3iObjSeq=getUserSpecifiedElementsToCopy(...
            this,categories,packages,rootPaths)

            m3iRootPaths={};
            m3iPackages={};
            m3iMetaClasses=[];
            m3iObjSeq=M3I.SequenceOfClassObject.make(this.SrcM3IModel);


            supportedCategories=[this.ValidDatatypeCategories,...
            this.ValidInterfaceCategories,...
            this.ValidOtherCategories];
            if isempty(categories)
                categories=supportedCategories;
            else
                invalidCategories=setdiff(categories,supportedCategories);
                if~isempty(invalidCategories)
                    DAStudio.error('RTW:autosar:updateReferencesInvalidCategory',invalidCategories{1},...
                    autosar.api.Utils.cell2str(supportedCategories))
                end
            end

            for ii=1:numel(categories)
                m3iMetaClass=autosar.api.getAUTOSARProperties.getMetaClassFromCategory(categories{ii});
                m3iMetaClasses=[m3iMetaClasses,m3iMetaClass];%#ok<AGROW>
            end


            for ii=1:numel(packages)
                m3iPkg=autosar.mm.Model.getArPackage(this.SrcM3IModel,packages{ii});
                if~isempty(m3iPkg)
                    m3iPackages{end+1}=m3iPkg;%#ok<AGROW>
                else
                    DAStudio.error('autosarstandard:common:invalidPackagePath',packages{ii});
                end
            end


            for ii=1:numel(rootPaths)
                seq=autosar.mm.Model.findObjectByName(this.SrcM3IModel,rootPaths{ii});
                if~seq.isEmpty()
                    m3iRootPaths{end+1}=seq.at(1);%#ok<AGROW>
                else
                    DAStudio.error('RTW:autosar:apiInvalidPath',rootPaths{ii});
                end
            end

            if~isempty(m3iRootPaths)
                for ii=1:numel(m3iRootPaths)
                    m3iObjSeq.push_back(m3iRootPaths{ii});
                end
            else
                if~isempty(m3iPackages)
                    for ii=1:numel(m3iPackages)
                        m3iObjSeq.push_back(m3iPackages{ii});
                    end
                else
                    for jj=1:numel(m3iMetaClasses)
                        m3iObjSeqMetaClass=Simulink.metamodel.arplatform.ModelFinder.findObjectByParentMetaClass(this.SrcM3IModel,...
                        m3iMetaClasses(jj),true);
                        for kk=1:m3iObjSeqMetaClass.size()
                            m3iObjSeq.push_back(m3iObjSeqMetaClass.at(kk));
                        end
                    end
                end
            end



            for i=1:m3iObjSeq.size()
                m3iObj=m3iObjSeq.at(i);
                if isa(m3iObj,'Simulink.metamodel.foundation.ValueType')&&m3iObj.IsApplication
                    m3iMapSets=autosar.mm.Model.findObjectByMetaClass(this.SrcM3IModel,...
                    Simulink.metamodel.arplatform.common.DataTypeMappingSet.MetaClass,true,true);
                    m3iObjSeq.addAll(m3iMapSets);
                    break;
                end
            end
        end
    end
end



