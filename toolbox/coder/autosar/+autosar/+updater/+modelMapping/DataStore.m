classdef DataStore<autosar.updater.modelMapping.PIMMapping




    methods
        function this=DataStore(modelName)
            this=this@autosar.updater.modelMapping.PIMMapping(modelName);
        end

        function markAsUnmatched(this)
            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end

            if autosar.api.Utils.isMappedToAdaptiveApplication(this.ModelName)


                return;
            end

            dsmInfo=this.findMappedDSMBlocks('ArTypedPerInstanceMemory');
            for pimIdx=1:numel(dsmInfo)
                this.UnmatchedArTypedPIM(dsmInfo(pimIdx).slObjName)=dsmInfo(pimIdx).dsmOwnerBlkH;
            end

            dsmInfo=this.findMappedDSMBlocks('StaticMemory');
            for pimIdx=1:numel(dsmInfo)
                this.UnmatchedStaticMemory(dsmInfo(pimIdx).slObjName)=dsmInfo(pimIdx).dsmOwnerBlkH;
            end
        end

        function[isMapped,blockH,slObj]=isMapped(this,varargin)

            m3iData=varargin{1};
            type=varargin{2};

            if nargin<3||isempty(type)
                [isMapped,blockH,slObj]=this.isMapped(m3iData,'ArTypedPerInstanceMemory');
                if~isMapped
                    [isMapped,blockH,slObj]=this.isMapped(m3iData,'StaticMemory');
                end
                return;
            end

            isMapped=false;
            blockH=[];
            slObj=[];

            dsmInfo=this.findMappedDSMBlocks(type,m3iData.Name);
            if~isempty(dsmInfo)
                isMapped=true;
                blockH=dsmInfo.dsmOwnerBlkH;
                slObj=dsmInfo.slObj;
                switch type
                case 'ArTypedPerInstanceMemory'
                    if this.UnmatchedArTypedPIM.isKey(dsmInfo.slObjName)
                        this.UnmatchedArTypedPIM.remove(dsmInfo.slObjName);
                    end
                case 'StaticMemory'
                    if this.UnmatchedStaticMemory.isKey(dsmInfo.slObjName)
                        this.UnmatchedStaticMemory.remove(dsmInfo.slObjName);
                    end
                otherwise

                end
            end
        end

        function dsmInfo=findMappedDSMBlocks(this,type,shortName)
            if nargin<3
                shortName='';
            end
            dsmInfo=this.findMapped(type,shortName);
        end

        function updateMapping(this,pimInfo,m3iObj)
            assert(isa(m3iObj,'Simulink.metamodel.arplatform.interface.VariableData'),...
            'This function is only valid for VariableData');

            slMapping=autosar.api.getSimulinkMapping(this.ModelName);
            mappedTo=autosar.mm.util.getVariableRoleFromM3IData(m3iObj);

            if~isempty(m3iObj.SwAddrMethod)
                swAddrMethod=m3iObj.SwAddrMethod.Name;
            else
                swAddrMethod='';
            end


            needsNVRAMAccess='false';
            m3iComp=autosar.api.Utils.m3iMappedComponent(this.ModelName);
            m3iSerDeps=m3iComp.Behavior.ServiceDependency;
            for serDepIdx=1:m3iSerDeps.size
                m3iSerDep=m3iSerDeps.at(serDepIdx);
                if strcmp(m3iSerDep.UsedDataElement.Name,dsmShortName)
                    needsNVRAMAccess='true';
                    break;
                end
            end

            slMapping.mapDataStore(pimInfo.dsmOwnerBlkH,mappedTo,...
            'ShortName',m3iObj.Name,...
            'SwAddrMethod',swAddrMethod,...
            'SwCalibrationAccess',autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iObj.SwCalibrationAccess),...
            'DisplayFormat',m3iObj.DisplayFormat,...
            'IsVolatile',m3iObj.Type.IsVolatile,...
            'Qualifier',m3iObj.Type.Qualifier,...
            'NeedsNVRAMAccess',needsNVRAMAccess);
        end

        function slObj=requiresSignalObject(this,mmPim)
            dsmH=mmPim.OwnerBlockHandle;
            requiresSignalObject=strcmp(get_param(dsmH,'StateMustResolveToSignalObject'),'on');
            if requiresSignalObject
                [~,slObj]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,mmPim.Name);
            else

                slObj=get_param(dsmH,'StateSignalObject');
            end
        end

        function isValid=isLegacyMappingValid(this,mmPim,shortName,type)
            isValid=false;
            slObj=this.requiresSignalObject(mmPim);
            if isempty(slObj)
                return;
            end

            dsmName=get_param(mmPim.OwnerBlockHandle,'DataStoreName');
            if~isempty(shortName)&&~strcmp(dsmName,shortName)
                return;
            end

            switch(type)
            case 'ArTypedPerInstanceMemory'
                isValid=((strcmp(type,'ArTypedPerInstanceMemory')&&...
                isa(slObj,'AUTOSAR.Signal')&&...
                strcmp(slObj.CoderInfo.CustomStorageClass,'PerInstanceMemory')&&...
                slObj.CoderInfo.CustomAttributes.IsArTypedPerInstanceMemory));
            case 'StaticMemory'
                isValid=(strcmp(type,'StaticMemory')&&...
                isa(slObj,'AUTOSAR4.Signal')&&...
                strcmp(slObj.CoderInfo.StorageClass,'Global'));
            end
        end
    end

    methods(Access=protected)
        function logDeletionsGeneric(this,changeLogger,pimMap)
            slMapping=autosar.api.getSimulinkMapping(this.ModelName);
            pimNames=pimMap.keys();
            for dsmIdx=1:length(pimNames)
                dsmName=pimNames{dsmIdx};
                dsmBlockH=pimMap(dsmName);
                currentMapping=slMapping.getDataStore(dsmBlockH);
                slMapping.mapDataStore(dsmBlockH,'Auto');
                blkhyperlink=autosar.updater.Report.getBlkHyperlink(getfullname(dsmBlockH));
                changeLogger.logDeletion('Manual','DataStoreMemory block',...
                blkhyperlink,this.ModelName);
                changeLogger.logModification('Automatic','DataStoreMemory mapping',...
                sprintf('data store "%s" in block',get_param(dsmBlockH,'DataStoreName')),...
                getfullname(dsmBlockH),currentMapping,'Auto');
            end
        end
    end

    methods(Static)
        function supportsLegacyMapping=supportsLegacyMapping()
            supportsLegacyMapping=true;
        end

        function pimInfo=generatePimInfo(mmPim,slObj)
            pimInfo=struct('slObjName',mmPim.Name,'dsmOwnerBlkH',mmPim.OwnerBlockHandle,'slObj',slObj);
        end

        function pimInfo=generateLegacyPimInfo(mmPim,slObj)
            dsmBlkH=mmPim.OwnerBlockHandle;
            dsmName=get_param(dsmBlkH,'DataStoreName');
            pimInfo=struct('slObjName',dsmName,'dsmOwnerBlkH',dsmBlkH,'slObj',slObj);
        end

        function modelMappings=getPimMappings(modelMapping)
            modelMappings=modelMapping.DataStores;
        end

        function arShortName=getShortNameFromMapping(mappingObj,mmPim)
            dsmH=mmPim.OwnerBlockHandle;
            arShortName=mappingObj.getDataStore(dsmH,'ShortName');
        end
    end
end


