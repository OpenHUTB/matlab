classdef Persistency




    properties(Access=private)
Model
m3iModel
modelName
m3iComp
maxShortNameLength
perKvDbPkgName
perPortToKvDbMappingsPkgName
defProcessQualPath
defProcessName
processPkgName
modelMapping
    end

    methods(Access=private)
        function self=Persistency(model)
            self.Model=get_param(model,'Handle');
            self.m3iModel=autosar.api.Utils.m3iModel(self.Model);
            self.modelName=get_param(self.Model,'Name');
            self.m3iComp=autosar.api.Utils.m3iMappedComponent(self.modelName);
            if Simulink.CodeMapping.isAutosarAdaptiveSTF(self.modelName)
                self.maxShortNameLength=get_param(self.modelName,'AutosarMaxShortNameLength');
            else
                self.maxShortNameLength=128;
            end

            self.perKvDbPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_PersistencyKeyValueDatabases'],self.maxShortNameLength);
            self.perPortToKvDbMappingsPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_PersistencyPortPrototypeToKeyValueDatabaseMappings'],self.maxShortNameLength);

            self.defProcessName=arxml.arxml_private('p_create_aridentifier',...
            'DefaultInstance',self.maxShortNameLength);
            self.processPkgName=arxml.arxml_private('p_create_aridentifier',...
            [self.m3iComp.Name,'_Processes'],self.maxShortNameLength);
            self.defProcessQualPath=['/',self.processPkgName,'/',self.defProcessName];

            self.modelMapping=autosar.api.Utils.modelMapping(self.modelName);
        end

        function syncMetamodelWithPersistencyInfo(self)

            for i=1:numel(self.modelMapping.DataStores)
                dsMapping=self.modelMapping.DataStores(i);
                if strcmp(dsMapping.MappedTo.ArDataRole,'Persistency')
                    self.addPerPortToKvDbMapping(dsMapping);
                end
            end
        end

        function addPerPortToKvDbMapping(self,dsMapping)


            port=dsMapping.MappedTo.getPerInstancePropertyValue('Port');
            perPort=autosar.mm.sl2mm.ModelBuilder.findInSequenceNamedItem(...
            self.m3iComp,self.m3iComp.PersistencyProvidedRequiredPorts,port,...
            'Simulink.metamodel.arplatform.port.PersistencyProvidedRequiredPort');


            kvDbPkgObj=autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.perKvDbPkgName);


            kvDbObj=self.addKvDatabaseTokvDbPackage(perPort,dsMapping,kvDbPkgObj);
            portToKvDbMappingPkgObj=...
            autosar.mm.Model.getOrAddARPackage(self.m3iModel,self.perPortToKvDbMappingsPkgName);
            portTokvDbMappingName=[perPort.Name,'_DbMapping'];
            portTokvDbMappingQualPath=['/',self.perPortToKvDbMappingsPkgName,'/',portTokvDbMappingName];
            if(autosar.mm.Model.findObjectByName(portToKvDbMappingPkgObj,portTokvDbMappingQualPath).size()==0)
                portTokvDbMappingObj=self.addManifestPackageElement(['/',self.perPortToKvDbMappingsPkgName],...
                portTokvDbMappingName,'PersistencyPortToKeyValueDatabaseMapping');
                processObj=autosar.mm.Model.findObjectByName(self.m3iModel,self.defProcessQualPath).at(1);
                portTokvDbMappingObj.Process=processObj;
                portTokvDbMappingObj.Port=perPort;
                portTokvDbMappingObj.KeyValueStorage=kvDbObj;
            end

        end

        function kvDbObj=addKvDatabaseTokvDbPackage(self,perPort,dsMapping,kvDbPkgObj)

            kvDbName=[perPort.Name,'_Db'];
            kvDbQualPath=['/',self.perKvDbPkgName,'/',kvDbName];
            kvDbObj=autosar.mm.Model.findObjectByName(kvDbPkgObj,kvDbQualPath);
            if(kvDbObj.size()==0)
                kvDbObj=self.addManifestPackageElement(['/',self.perKvDbPkgName],...
                kvDbName,'PersistencyKeyValueDatabase');
            else
                kvDbObj=kvDbObj.at(1);
            end


            key=dsMapping.MappedTo.getPerInstancePropertyValue('DataElement');
            if~isempty(key)
                m3iData=autosar.mm.sl2mm.ModelBuilder.findOrCreateInSequenceNamedItem(...
                perPort.Interface,perPort.Interface.DataElements,key,...
                'Simulink.metamodel.arplatform.interface.PersistencyData');


                initValBlk=get_param(dsMapping.OwnerBlockHandle,'InitialValue');
                try
                    isVar=existsInGlobalScope(self.modelName,initValBlk);
                    if isVar


                        initValue=evalinGlobalScope(self.modelName,initValBlk);
                        if~isstruct(initValue)


                            initValue=initValue.Value;
                        end
                    else
                        initValue=eval(initValBlk);
                    end
                catch
                    return;
                end

                kvPairPath=[kvDbQualPath,'/',key];
                kvPairSeq=autosar.mm.Model.findObjectByName(kvDbObj,kvPairPath);
                if(kvPairSeq.size()==0)

                    self.addKeyValuePairtoKvDb(m3iData,initValue,kvDbObj);
                else


                    initValueName=autosar.mm.sl2mm.utils.init_value_name_for_datatype(...
                    m3iData.Type.Name,self.maxShortNameLength);
                    kvPairObj=kvPairSeq.at(1);
                    kvPairObj.InitValue.destroy();
                    kvPairObj.InitValue=autosar.mm.sl2mm.ConstantBuilder.updateOrCreateValueSpecification(self.m3iModel,...
                    [],[],m3iData.Type,self.maxShortNameLength,...
                    initValueName,initValue,[]);
                end
            end
        end

        function addKeyValuePairtoKvDb(self,m3iData,initValue,kvDbObj)







            if~isempty(m3iData.Type)
                keyName=m3iData.Name;
                kvPairObj=feval(kvDbObj.getMetaClass.getProperty('KeyValuePair').type.qualifiedName,self.m3iModel);
                kvPairObj.Name=keyName;
                kvPairObj.Type=m3iData.Type;


                initValueName=autosar.mm.sl2mm.utils.init_value_name_for_datatype(m3iData.Type.Name,self.maxShortNameLength);
                kvPairObj.InitValue=autosar.mm.sl2mm.ConstantBuilder.updateOrCreateValueSpecification(self.m3iModel,...
                [],[],m3iData.Type,self.maxShortNameLength,...
                initValueName,initValue,[]);

                kvDbObj.KeyValuePair.append(kvPairObj);
            end
        end

        function m3iChildObj=addManifestPackageElement(self,pkgPath,pkgElemName,pkgElemType,varargin)

            autosar.api.Utils.checkQualifiedName(...
            self.Model,[pkgPath,'/',pkgElemName],'absPathShortName');


            m3iParentObj=autosar.mm.Model.getOrAddARPackage(self.m3iModel,pkgPath);

            childMetaClass=Simulink.metamodel.arplatform.manifest.(pkgElemType).MetaClass;

            m3iChildObj=feval(childMetaClass.qualifiedName,self.m3iModel);
            m3iChildObj.Name=pkgElemName;
            m3iParentObj.('packagedElement').append(m3iChildObj);
        end
    end

    methods(Static)
        function updateManifestMetaModelWithPersistencyData(modelName)
            obj=autosar.internal.adaptive.manifest.Persistency(modelName);
            obj.syncMetamodelWithPersistencyInfo();
        end
    end
end


