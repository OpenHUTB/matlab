classdef SharedElementsCopier<handle





    properties(Access=private)
        SystemPathToExport;
        ArchModelName;
        RootM3IModel;
    end


    methods
        function this=SharedElementsCopier(systemPathToExport)
            this.SystemPathToExport=systemPathToExport;
            this.ArchModelName=bdroot(this.SystemPathToExport);
            this.RootM3IModel=autosar.api.Utils.m3iModel(this.ArchModelName);
        end

        function copySharedElementsFromComp(this,compModelName)

            srcM3IModel=autosar.api.Utils.m3iModel(compModelName);
            if autosar.dictionary.Utils.hasReferencedModels(srcM3IModel)
                srcM3IModel=autosar.dictionary.Utils.getUniqueReferencedModel(srcM3IModel);
            end
            dstM3IModel=this.RootM3IModel;
            this.copySharedElements(srcM3IModel,dstM3IModel);
        end

        function copySharedElementsFromInterfaceDict(this,interfaceDictName)
            dictM3IModel=Simulink.AutosarDictionary.ModelRegistry.getOrLoadM3IModel(interfaceDictName);
            dstM3IModel=this.RootM3IModel;
            this.copySharedElements(dictM3IModel,dstM3IModel);
        end
    end

    methods(Static)
        function m3iObjSeq=findSharedPackagedElements(srcM3IModel)


            m3iObjSeq=M3I.SequenceOfClassObject.make(srcM3IModel);
            m3iPkgElms=autosar.mm.Model.findObjectByMetaClass(srcM3IModel,...
            Simulink.metamodel.foundation.PackageableElement.MetaClass,true,true);
            for i=1:m3iPkgElms.size()
                m3iPkgElm=m3iPkgElms.at(i);
                if~isa(m3iPkgElm,'Simulink.metamodel.arplatform.common.Package')&&...
                    ~isa(m3iPkgElm,'Simulink.metamodel.arplatform.common.AUTOSAR')&&...
                    ~isa(m3iPkgElm,'Simulink.metamodel.arplatform.component.Component')&&...
                    ~isa(m3iPkgElm,'Simulink.metamodel.arplatform.timingExtension.SwcTiming')&&...
                    ~isa(m3iPkgElm,'Simulink.metamodel.arplatform.timingExtension.VfbTiming')
                    m3iObjSeq.push_back(m3iPkgElm);
                end
            end
        end
    end

    methods(Access=private)

        function copySharedElements(this,srcM3IModel,dstM3IModel)


            m3iObjSeq=autosar.composition.build.SharedElementsCopier.findSharedPackagedElements(srcM3IModel);

            if~m3iObjSeq.isEmpty()



                copierOptions=Simulink.metamodel.arplatform.ElementCopierOptions();
                copierOptions.setDeleteUnmatchedElements(false);

                copier=Simulink.metamodel.arplatform.ElementCopier(srcM3IModel,dstM3IModel,copierOptions);
                for i=1:m3iObjSeq.size()
                    m3iSrcObj=m3iObjSeq.at(i);
                    this.checkIfCanBeCopied(m3iSrcObj,dstM3IModel);
                    copier.deepCopy(m3iSrcObj);
                end
            end
        end


        function checkIfCanBeCopied(this,m3iSrcObj,dstM3IModel)



            m3iDstObj=autosar.mm.Model.findChildByName(...
            dstM3IModel,autosar.api.Utils.getQualifiedName(m3iSrcObj));
            if m3iDstObj.isvalid

                if(m3iSrcObj.MetaClass~=m3iDstObj.MetaClass)
                    DAStudio.error('autosarstandard:validation:Composition_UnableToSyncElementNameClash',...
                    this.SystemPathToExport,autosar.api.Utils.getQualifiedName(m3iSrcObj),...
                    m3iSrcObj.MetaClass.name,m3iDstObj.MetaClass.name);
                end




                if isa(m3iSrcObj,'Simulink.metamodel.arplatform.interface.PortInterface')
                    this.checkInterfaceCompatibility(m3iSrcObj,m3iDstObj);
                end
            end
        end

        function checkInterfaceCompatibility(this,m3iSrcObj,m3iDstObj)
            interfaceToElemPropNameMap=autosar.mm.ModelMetaData.InterfaceToElementsPropName;
            m3iSrcInterface=m3iSrcObj;
            m3iDstInterface=m3iDstObj;
            if isa(m3iSrcInterface,'Simulink.metamodel.arplatform.interface.TriggerInterface')

                return;
            end

            if isa(m3iSrcInterface,'Simulink.metamodel.arplatform.interface.ModeSwitchInterface')



                return;
            end


            m3iSrcIntfElms=m3iSrcInterface.(interfaceToElemPropNameMap(class(m3iSrcInterface)));
            m3iDstIntfElms=m3iDstInterface.(interfaceToElemPropNameMap(class(m3iDstInterface)));
            if isa(m3iSrcInterface,'Simulink.metamodel.arplatform.interface.ClientServerInterface')
                m3iSrcOps=m3iSrcInterface.Operations;
                m3iDstOps=m3iDstInterface.Operations;

                srcOpNames=m3i.mapcell(@(x)x.Name,m3iSrcOps);
                dstOpNames=m3i.mapcell(@(x)x.Name,m3iDstOps);
                [matchingOps,srcIdx,dstIdx]=intersect(srcOpNames,dstOpNames);
                for opIdx=1:length(matchingOps)
                    this.checkInterfaceElementsTypeCompatible(m3iSrcOps.at(srcIdx(opIdx)).Arguments,...
                    m3iDstOps.at(dstIdx(opIdx)).Arguments);
                end
            else
                this.checkInterfaceElementsTypeCompatible(m3iSrcIntfElms,m3iDstIntfElms);
            end
        end

        function checkInterfaceElementsTypeCompatible(this,m3iSrcIntfElms,m3iDstIntfElms)%#ok<INUSD>





            srcElemNames=m3i.mapcell(@(x)x.Name,m3iSrcIntfElms);
            dstElemNames=m3i.mapcell(@(x)x.Name,m3iDstIntfElms);
            [matchingElements,srcIdx,dstIdx]=intersect(srcElemNames,dstElemNames);

            for elmIdx=1:length(matchingElements)
                m3iSrcElm=m3iSrcIntfElms.at(srcIdx(elmIdx));
                m3iDstElm=m3iDstIntfElms.at(dstIdx(elmIdx));
                assert(strcmp(m3iSrcElm.Name,m3iDstElm.Name),'Element names must match!');
                if(m3iSrcElm.Type.isvalid&&m3iDstElm.Type.isvalid)&&...
                    (m3iSrcElm.Type.IsApplication~=m3iDstElm.Type.IsApplication)
                    if m3iDstElm.Type.IsApplication
                        metaClass='ApplicationDataType';
                    else
                        metaClass='ImplementationDataType';
                    end
                    DAStudio.warning('autosarstandard:validation:Composition_InterfaceElmsTypesInconsistent',...
                    autosar.api.Utils.getQualifiedName(m3iDstElm),...
                    autosar.api.Utils.getQualifiedName(m3iDstElm.Type),...
                    metaClass,autosar.api.Utils.getQualifiedName(m3iDstElm.owner));
                end
            end
        end
    end
end


