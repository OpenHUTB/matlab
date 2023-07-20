classdef ApplicationTypeMapper<handle




    properties(Constant,Access=private)
        DefaultDataTypeMappingsSetName='DataTypeMappingsSet';
    end

    properties(Access=private)
App2DataTypeMappingSetQNameMap
App2ImpTypeQNameMap
App2ImpTypeNameMap
CompApp2ImpTypeQNameMap
        IsCompMapInitialized=false;
ModelName
        M3IModel;
    end

    methods
        function this=ApplicationTypeMapper(modelName)
            this.ModelName=modelName;


            this.M3IModel=this.determineM3IModelForDataTypeMap();

            this.App2ImpTypeQNameMap=containers.Map();
            this.App2ImpTypeNameMap=containers.Map();
            this.App2DataTypeMappingSetQNameMap=containers.Map();
            this.xformGlobalDataTypeMappingSets();
        end

        function isMapped=isMapped(this,m3iAppType)



            assert(m3iAppType.IsApplication,'Expected application type');
            isMapped=this.App2ImpTypeQNameMap.isKey(autosar.api.Utils.getQualifiedName(m3iAppType));
        end

        function isMapped=isMappedByName(this,typeName)


            isMapped=this.App2ImpTypeNameMap.isKey(typeName);
        end

        function m3iImpType=mappedTo(this,m3iAppType)



            assert(m3iAppType.IsApplication,'m3iType should be application type');

            impTypeQName=this.App2ImpTypeQNameMap(autosar.api.Utils.getQualifiedName(m3iAppType));
            m3iImpType=autosar.mm.Model.findChildByName(this.M3IModel,impTypeQName);
        end

        function updateApplToImplTypesMappings(this,oldImplTypeName,newImplTypeName,oldImplTypeQName,newImplTypeQName)

            updateMapEntries(this,this.App2ImpTypeNameMap,oldImplTypeName,newImplTypeName);
            updateMapEntries(this,this.App2ImpTypeQNameMap,oldImplTypeQName,newImplTypeQName);
        end

        function impTypeName=mappedToByName(this,appTypeName)
            impTypeName=this.App2ImpTypeNameMap(appTypeName);
        end

        function removeMapping(this,m3iAppTypeName,m3iAppTypeQName)
            if this.App2ImpTypeNameMap.isKey(m3iAppTypeName)
                remove(this.App2ImpTypeNameMap,m3iAppTypeName);
            end
            if this.App2ImpTypeQNameMap.isKey(m3iAppTypeQName)
                remove(this.App2ImpTypeQNameMap,m3iAppTypeQName);
            end
            if this.App2DataTypeMappingSetQNameMap.isKey(m3iAppTypeQName)
                remove(this.App2DataTypeMappingSetQNameMap,m3iAppTypeQName);
            end
        end

        function mapInComponent(this,m3iAppType,m3iImpType)



            import Simulink.metamodel.arplatform.common.DataTypeMap;

            if~this.IsCompMapInitialized
                this.initCompMap();
            end
            assert(this.IsCompMapInitialized,'Expected comp map to be initialized');

            adtQName=autosar.api.Utils.getQualifiedName(m3iAppType);
            idtQName=autosar.api.Utils.getQualifiedName(m3iImpType);
            if this.CompApp2ImpTypeQNameMap.isKey(adtQName)
                assert(m3iAppType.IsApplication);
                if~strcmp(this.CompApp2ImpTypeQNameMap(adtQName),idtQName)

                    [~,dtMap]=this.findDataTypeMappingSetForAppTypeInternal(m3iAppType);
                    dtMap.ImplementationType=m3iImpType;
                end
                isAppTypeInBehaviorMappingSet=true;

            else
                isAppTypeInBehaviorMappingSet=false;
            end

            this.App2ImpTypeQNameMap(adtQName)=idtQName;
            this.CompApp2ImpTypeQNameMap(adtQName)=idtQName;
            if isAppTypeInBehaviorMappingSet
                return
            end

            m3iComp=autosar.api.Utils.m3iMappedComponent(this.ModelName);
            m3iBehavior=m3iComp.Behavior;





            [dataTypeMappingSet,dtMap]=this.findDataTypeMappingSetForAppTypeInternal(m3iAppType);
            if~isempty(dataTypeMappingSet)
                if m3iImpType~=dtMap.ImplementationType

                    dtMap.ImplementationType=m3iImpType;
                end
                m3iBehavior.DataTypeMapping.append(dataTypeMappingSet);
                return;
            end



            dataTypeMappingSets=m3iBehavior.DataTypeMapping;
            if~dataTypeMappingSets.isEmpty()
                dataTypeMappingSet=dataTypeMappingSets.at(1);
            else
                dataTypeMappingSet=this.addDefaultDataTypeMappingSet();
            end


            m3iDTMap=DataTypeMap(this.M3IModel);
            m3iDTMap.ApplicationType=m3iAppType;
            if~m3iAppType.IsApplication
                m3iAppType.IsApplication=true;
            end
            m3iDTMap.ImplementationType=m3iImpType;
            dataTypeMappingSet.dataTypeMap.append(m3iDTMap);

            assert(size(m3i.filterSeq(@(x)strcmp(autosar.api.Utils.getQualifiedName(x.ApplicationType),adtQName)&&...
            ~strcmp(autosar.api.Utils.getQualifiedName(x.ImplementationType),idtQName),dataTypeMappingSet.dataTypeMap))==0,...
            sprintf('Expected one and only one data type mapping for the application type %s.',adtQName));


            dataTypeMappingSeqQName=autosar.api.Utils.getQualifiedName(dataTypeMappingSet);
            this.App2DataTypeMappingSetQNameMap(adtQName)=dataTypeMappingSeqQName;
        end

        function mapModeGroupInComponent(this,m3iModeGroup,m3iImpType)

            import Simulink.metamodel.arplatform.common.DataTypeMappingSet;
            import Simulink.metamodel.arplatform.common.ModeRequestTypeMap;

            m3iComp=autosar.api.Utils.m3iMappedComponent(this.ModelName);
            m3iBehavior=m3iComp.Behavior;

            dataTypeMapSet=m3iBehavior.DataTypeMapping;
            if dataTypeMapSet.isEmpty()
                this.addDefaultDataTypeMappingSet();
            end

            for ii=1:dataTypeMapSet.size()
                modeRequestTypeMap=dataTypeMapSet.at(ii).ModeRequestTypeMap;
                for jj=1:modeRequestTypeMap.size()
                    if strcmp(modeRequestTypeMap.at(jj).ModeGroupType.Name,m3iModeGroup.Name)
                        modeRequestTypeMap.at(jj).ImplementationType=m3iImpType;
                        return;
                    end
                end
            end

            m3iMRTMap=ModeRequestTypeMap(this.M3IModel);
            m3iMRTMap.ModeGroupType=m3iModeGroup;
            m3iMRTMap.ImplementationType=m3iImpType;
            m3iBehavior.DataTypeMapping.at(1).ModeRequestTypeMap.append(m3iMRTMap);
        end

    end


    methods(Static)

        function[dtMapSet,dtMap]=findDataTypeMappingSetForAppType(m3iAppType)

            m3iDataTypeMappingSeq=...
            Simulink.metamodel.arplatform.ModelFinder.findObjectByMetaClass(m3iAppType.rootModel,...
            Simulink.metamodel.arplatform.common.DataTypeMappingSet.MetaClass,true);

            dtMap=[];
            dtMapSet=[];
            foundDtMap=false;
            for mIdx=1:m3iDataTypeMappingSeq.size()
                dtMappingSet=m3iDataTypeMappingSeq.at(mIdx);
                dtMapVec=m3iDataTypeMappingSeq.at(mIdx).dataTypeMap;
                for idx=1:dtMapVec.size
                    dtMap=dtMapVec.at(idx);
                    if(m3iAppType==dtMap.ApplicationType)
                        foundDtMap=true;
                        break;
                    end
                end
                if(foundDtMap)
                    break;
                end
            end

            if foundDtMap
                dtMapSet=dtMappingSet;
            end
        end

    end

    methods(Access=private)

        function updateMapEntries(~,map,oldValue,newValue)

            index=cellfun(@(x)isequal(x,oldValue),values(map));
            mapKeys=keys(map);
            mapKey=mapKeys(index);
            for i=1:numel(mapKey)
                map(mapKey{i})=newValue;
            end
        end

        function m3iModel=determineM3IModelForDataTypeMap(this)


            localM3IModel=autosar.api.Utils.m3iModel(this.ModelName);
            if autosar.dictionary.Utils.hasReferencedModels(localM3IModel)
                m3iModel=autosar.dictionary.Utils.getUniqueReferencedModel(localM3IModel);
            else
                m3iModel=localM3IModel;
            end
        end

        function xformGlobalDataTypeMappingSets(this)









            m3iDataTypeMappingSeq=M3I.SequenceOfClassObject.make(this.M3IModel);
            autosar.mm.arxml.Exporter.findByBaseType(...
            m3iDataTypeMappingSeq,this.M3IModel,...
            'Simulink.metamodel.arplatform.common.DataTypeMappingSet');
            for mIdx=1:m3iDataTypeMappingSeq.size()
                dtMappingQName=autosar.api.Utils.getQualifiedName(m3iDataTypeMappingSeq.at(mIdx));
                dtMapVec=m3iDataTypeMappingSeq.at(mIdx).dataTypeMap;
                for idx=1:dtMapVec.size()
                    dtMap=dtMapVec.at(idx);
                    adtQName=autosar.api.Utils.getQualifiedName(dtMap.ApplicationType);
                    idtQName=autosar.api.Utils.getQualifiedName(dtMap.ImplementationType);
                    this.App2ImpTypeQNameMap(adtQName)=idtQName;
                    this.App2ImpTypeNameMap(dtMap.ApplicationType.Name)=...
                    dtMap.ImplementationType.Name;
                    this.App2DataTypeMappingSetQNameMap(adtQName)=dtMappingQName;
                end
            end
        end

        function initCompMap(this)


            assert(~this.IsCompMapInitialized,'Comp maps should not be initialized');

            this.CompApp2ImpTypeQNameMap=containers.Map();
            m3iComp=autosar.api.Utils.m3iMappedComponent(this.ModelName);
            m3iBehavior=m3iComp.Behavior;





            dataTypeMapSet=m3iBehavior.DataTypeMapping;
            for dtMapIdx=1:dataTypeMapSet.size()
                dtMaps=dataTypeMapSet.at(dtMapIdx);
                for idx=1:dtMaps.dataTypeMap.size()
                    dtMap=dtMaps.dataTypeMap.at(idx);
                    adtQName=autosar.api.Utils.getQualifiedName(dtMap.ApplicationType);
                    idtQName=autosar.api.Utils.getQualifiedName(dtMap.ImplementationType);
                    this.CompApp2ImpTypeQNameMap(adtQName)=idtQName;
                end
            end

            this.IsCompMapInitialized=true;
        end


        function[dtMapSet,dtMap]=findDataTypeMappingSetForAppTypeInternal(this,m3iAppType)

            dtMap=[];
            dtMapSet=[];
            foundDtMap=false;
            if this.App2DataTypeMappingSetQNameMap.isKey(autosar.api.Utils.getQualifiedName(m3iAppType))
                dtMapSetQName=this.App2DataTypeMappingSetQNameMap(autosar.api.Utils.getQualifiedName(m3iAppType));
                dtMapSet=autosar.mm.Model.findChildByName(this.M3IModel,dtMapSetQName);
                dtMapVec=dtMapSet.dataTypeMap;
                for idx=1:dtMapVec.size
                    dtMap=dtMapVec.at(idx);
                    if(m3iAppType==dtMap.ApplicationType)
                        foundDtMap=true;
                        break;
                    end
                end
                assert(foundDtMap,'Expected to find data type map');
            end
        end



        function m3iDTMappingSet=addDefaultDataTypeMappingSet(this)
            import autosar.mm.util.XmlOptionsAdapter;
            import Simulink.metamodel.arplatform.common.DataTypeMappingSet;

            m3iComp=autosar.api.Utils.m3iMappedComponent(this.ModelName);
            m3iBehavior=m3iComp.Behavior;
            arRoot=this.M3IModel.RootPackage.front();

            dtmPkg=XmlOptionsAdapter.get(arRoot,'DataTypeMappingPackage');
            if isempty(dtmPkg)
                dtmPkg=[arRoot.DataTypePackage,'/'...
                ,autosar.mm.util.XmlOptionsDefaultPackages.DataTypeMappingSets];
                XmlOptionsAdapter.set(arRoot,'DataTypeMappingPackage',dtmPkg);
            end

            m3iDTMappingPkg=autosar.mm.Model.getOrAddARPackage(...
            this.M3IModel,dtmPkg);

            mappingSetName=this.getMappingSetName();

            m3iDTMappingSet=autosar.mm.Model.findChildByName(this.M3IModel,...
            [dtmPkg,'/',mappingSetName]);
            if~m3iDTMappingSet.isvalid()
                m3iDTMappingSet=DataTypeMappingSet(this.M3IModel);
                m3iDTMappingSet.Name=mappingSetName;
                m3iDTMappingPkg.packagedElement.append(m3iDTMappingSet);
            end

            m3iBehavior.DataTypeMapping.append(m3iDTMappingSet);
        end

        function mappingSetName=getMappingSetName(this)
            [isSharedM3IModel,dictFileName]=autosar.dictionary.Utils.isSharedM3IModel(this.M3IModel);
            if isSharedM3IModel
                dtMappingSetPrefix=autosar.utils.File.dropPath(dictFileName,DropExtension=true);
            else
                m3iComp=autosar.api.Utils.m3iMappedComponent(this.ModelName);
                compQName=autosar.api.Utils.getQualifiedName(m3iComp);
                [~,dtMappingSetPrefix]=autosar.mm.sl2mm.ModelBuilder.getNodePathAndName(compQName);
            end
            maxShortNameLength=get_param(this.ModelName,'AutosarMaxShortNameLength');
            mappingSetName=arxml.arxml_private('p_create_aridentifier',...
            [dtMappingSetPrefix,autosar.mm.sl2mm.ApplicationTypeMapper.DefaultDataTypeMappingsSetName],...
            maxShortNameLength);
        end

    end
end


