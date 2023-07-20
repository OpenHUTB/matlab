classdef M3IGarbageCollector<handle





    properties(Access=private)
        ReferencedTypesCountMap;
        M3IModel;
        DataTypeMappingSets;
        ClassesToCollect;
        NamespacesToTraverse;
        ElementCounter;
    end

    methods(Static,Access=public)









        function removeUnreferencedDataTypes(modelOrInterfaceDictName,forceImported)

            if nargin<2
                forceImported=false;
            end



            gcContext=autosar.mm.sl2mm.internal.M3IGarbageCollectorContext.createContext(...
            modelOrInterfaceDictName);


            m3iModel=gcContext.getM3IModel();

            if slfeature('AUTOSARLeanARXMLExport')==0
                return;
            end


            classesToCollect=["Simulink.metamodel.foundation.ValueSpecification",...
            "Simulink.metamodel.foundation.ValueType",...
            "Simulink.metamodel.types.CompuMethod",...
            "Simulink.metamodel.types.Unit",...
            "Simulink.metamodel.types.DataConstr",...
            "Simulink.metamodel.types.SwBaseType",...
            "Simulink.metamodel.types.ConstantSpecification"];


            namespacesToTraverse="Simulink.metamodel.types";

            gc=autosar.mm.sl2mm.M3IGarbageCollector(m3iModel,classesToCollect,namespacesToTraverse);




            unusedDataTypes=gc.collect(forceImported);







            gcContext.cacheRestoreDirtyState();

            if~unusedDataTypes.isEmpty()
                tran=M3I.Transaction(m3iModel);
                gc.destroy(unusedDataTypes);
                tran.commit();
            end
        end


        function isEnabled=logger(logMode,enable)
            persistent logModes;

            if isempty(logModes)
                logModes=struct(...
                'Debug',false,...
                'Verbose',false);
            end

            assert(isfield(logModes,logMode),...
            'Logging mode ''%s'' is not available!',logMode);

            if nargin>=2
                assert(islogical(enable),...
                'Logging value for ''%s'' must be a logical!',logMode)

                logModes.(logMode)=enable;
            end


            isEnabled=logModes.(logMode);
        end
    end

    methods(Access=public,Hidden=true)






        function this=M3IGarbageCollector(m3iModel,classesToCollect,compositionsToTraverse)
            this.M3IModel=m3iModel;
            this.ClassesToCollect=classesToCollect;
            this.NamespacesToTraverse=compositionsToTraverse;
            this.ReferencedTypesCountMap=containers.Map();
            this.DataTypeMappingSets=autosar.mm.Model.findObjectByMetaClass(this.M3IModel,...
            Simulink.metamodel.arplatform.common.DataTypeMappingSet.MetaClass);
        end



        function result=collect(this,forceImported)

            result=M3I.SequenceOfClassObject.make(this.M3IModel);




            this.ElementCounter=Simulink.metamodel.arplatform.ElementCounter(...
            this.ClassesToCollect,this.NamespacesToTraverse,forceImported,this.logger('Debug'));

            this.ElementCounter.traverseCountingReferences(this.M3IModel);
            references=this.ElementCounter.getReferences();
            for i=1:length(references)
                reference=references{i};
                this.ReferencedTypesCountMap(reference)=this.ElementCounter.getReferenceCount(reference);
            end








            unreferencedElements='';

            while containsUnreferenced(this)
                this.logResults(this.logger('Debug'),this.ReferencedTypesCountMap,unreferencedElements);




                unreferencedElements=getUnreferencedElementsUsingDTMaps(this);


                for i=1:length(unreferencedElements)
                    element=this.findElement(this.M3IModel,unreferencedElements(i));

                    if isempty(element)
                        continue;
                    end











                    hasReferencedElement=collectUnusedNodes(this,element,forceImported);


                    if~hasReferencedElement
                        result.append(element);
                    end
                end
            end
            this.logResults(this.logger('Debug'),this.ReferencedTypesCountMap,unreferencedElements);

        end

    end

    methods(Access=private)







        function result=containsUnreferenced(this)
            mat=cell2mat(values(this.ReferencedTypesCountMap));
            result=any(mat==0);
        end










        function unreferencedElements=getUnreferencedElementsUsingDTMaps(this)
            unreferencedElements=string();
            qualifiedNamesKeys=keys(this.ReferencedTypesCountMap);

            for i=1:length(qualifiedNamesKeys)
                qualifiedName=qualifiedNamesKeys{i};

                if(this.ReferencedTypesCountMap(qualifiedName)==0)&&~any(unreferencedElements(:)==qualifiedName)
                    hasApplicationType=false;
                    element=this.findElement(this.M3IModel,qualifiedName);


                    isImplType=isa(element,'Simulink.metamodel.foundation.ValueType')&&...
                    isprop(element,'IsApplication')&&~element.IsApplication;

                    if isImplType

                        hasApplicationType=hasMappedReferencedApplicationType(this,qualifiedName);
                    end

                    if~hasApplicationType




                        unreferencedElements(end+1)=string(qualifiedName);%#ok
                        remove(this.ReferencedTypesCountMap,qualifiedName);
                    else


                        if isImplType
                            this.ReferencedTypesCountMap(qualifiedName)=this.ReferencedTypesCountMap(qualifiedName)+1;
                        end
                    end
                end
            end
        end



        function hasReferencedElement=collectUnusedNodes(this,...
            element,...
            forceImported)

            hasReferencedElement=hasReferencedAncestor(this,element);



            if hasReferencedElement
                return;
            end

            attributes=this.ElementCounter.getCachedAttributes(element);

            for l=1:attributes.size
                attribute=attributes.at(l);

                if~isa(attribute.type,'M3I.ImmutableClass')||isempty(element.(attribute.name))
                    continue;
                end

                if this.isSequence(attribute)


                    sequence=element.(attribute.name);
                    for i=1:sequence.size
                        child=sequence.at(i);



                        if this.ReferencedTypesCountMap.isKey(this.getQualifiedName(child))||...
                            isa(child,'Simulink.metamodel.types.StructElement')||...
                            isa(child,'Simulink.metamodel.types.Slot')||...
                            isa(child,'Simulink.metamodel.types.Cell')
                            hasReferencedElement=collectUnusedNodes(this,child,forceImported);
                        end
                    end
                else
                    object=element.(attribute.name);
                    qualifiedName=this.getQualifiedName(object);
                    isReferenced=this.ReferencedTypesCountMap.isKey(qualifiedName);

                    if~isReferenced||(~isempty(object.getExternalToolInfo('ARXML_ArxmlFileInfo').externalId)&&~forceImported)
                        continue;
                    end





                    if attribute.isComposite&&this.ReferencedTypesCountMap(qualifiedName)>1
                        hasReferencedElement=true;





                    elseif this.ReferencedTypesCountMap(qualifiedName)>0
                        this.ReferencedTypesCountMap(qualifiedName)=this.ReferencedTypesCountMap(qualifiedName)-1;
                    end
                end
            end

        end


        function result=hasReferencedAncestor(this,element)
            result=false;
            elementOwner=element.owner;

            while~isempty(elementOwner)
                qualifiedName=this.getQualifiedName(elementOwner);
                isReferenced=this.ReferencedTypesCountMap.isKey(qualifiedName);

                if isReferenced&&this.ReferencedTypesCountMap(qualifiedName)>0
                    result=true;
                    break;
                end

                elementOwner=elementOwner.owner;
            end
        end


        function destroy(this,unusedNodes)
            for i=1:unusedNodes.size()
                item=unusedNodes.at(i);
                if~isempty(item)&&item.isvalid
                    if this.logger('Verbose')
                        fprintf("Removing unused ARXML element: %s\n",autosar.api.Utils.getQualifiedName(item));
                    end
                    container=item.containerM3I;
                    item.destroy();

                    while isempty(container)
                        parent=container;
                        container=container.containerM3I;
                        if this.logger('Verbose')
                            fprintf("Removing unused ARXML container: %s\n",autosar.api.Utils.getQualifiedName(parent));
                        end
                        parent.destroy();
                    end
                end
            end



            removeInvalidDataMaps(this);
        end


        function hasApplicationType=hasMappedReferencedApplicationType(this,implDataTypeName)
            hasApplicationType=false;

            applDataTypes=this.ElementCounter.findMappedApplicationDataTypes(this.M3IModel,implDataTypeName);

            for i=1:applDataTypes.size()
                applDataType=applDataTypes.at(i);
                applDataTypeName=this.getQualifiedName(applDataType);
                if this.ReferencedTypesCountMap.isKey(applDataTypeName)&&this.ReferencedTypesCountMap(applDataTypeName)>0
                    hasApplicationType=true;
                    return;
                end
            end
        end



        function removeInvalidDataMaps(this)
            for i=1:this.DataTypeMappingSets.size()
                dataTypeMapSet=this.DataTypeMappingSets.at(i);

                dataTypeMap=dataTypeMapSet.dataTypeMap;
                this.removeInvalidDataMapEntry(dataTypeMap,true);

                modelTypeMap=dataTypeMapSet.ModeRequestTypeMap;
                this.removeInvalidDataMapEntry(modelTypeMap,false);
            end
        end


        function removeInvalidDataMapEntry(~,dataTypeMap,...
            checkApplicationType)
            indexesToRemove=[];

            for idx=1:dataTypeMap.size()







                dataMapEntry=dataTypeMap.at(idx);
                if(checkApplicationType&&(isempty(dataMapEntry.ApplicationType)||~dataMapEntry.ApplicationType.isvalid))||...
                    (isempty(dataMapEntry.ImplementationType)||~dataMapEntry.ImplementationType.isvalid)
                    indexesToRemove(end+1)=idx;%#ok
                end
            end


            indexesToRemove=sort(indexesToRemove,'descend');
            for idx=1:length(indexesToRemove)
                unreferencedItem=dataTypeMap.at(indexesToRemove(idx));
                unreferencedItem.destroy();
            end
        end

    end

    methods(Static,Access=private)






        function element=findElement(m3iModel,...
            qualifiedName)
            element=[];
            qualifiedName=strrep(qualifiedName,'.','/');
            sequence=autosar.mm.Model.findObjectByName(m3iModel,qualifiedName);
            if~sequence.isEmpty()
                element=sequence.front();
            end
        end




        function qualifiedName=getQualifiedName(element)
            if isa(element,'Simulink.metamodel.foundation.NamedElement')
                qualifiedName=element.qualifiedName;
            else
                qualifiedName='';
            end
            qualifiedName=string(qualifiedName);
        end



        function isSeq=isSequence(attribute)
            isSeq=~strcmp(attribute.upper,'1');
        end







        function logResults(verbose,referencedTypes,...
            unreferencedTypes)
            if~verbose
                return
            end

            fprintf("\nReferenced types count:\n");
            keySet=keys(referencedTypes);
            for i=1:length(keySet)
                key=keySet{i};
                fprintf("\t[%d] - %s\n",referencedTypes(key),key);
            end
            fprintf("\nUnreferenced types:\n");
            for i=1:length(unreferencedTypes)
                fprintf("\t%s\n",unreferencedTypes(i));
            end
            fprintf("\n");
        end
    end
end


