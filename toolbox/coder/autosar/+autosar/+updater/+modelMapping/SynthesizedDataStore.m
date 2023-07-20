classdef SynthesizedDataStore<autosar.updater.modelMapping.PIMMapping









    methods
        function this=SynthesizedDataStore(modelName)
            this=this@autosar.updater.modelMapping.PIMMapping(modelName);
        end

        function markAsUnmatched(this)
            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end

            if autosar.api.Utils.isMappedToAdaptiveApplication(this.ModelName)


                return;
            end

            dsmInfo=this.findMappedSynthDSMs('ArTypedPerInstanceMemory');
            for pimIdx=1:numel(dsmInfo)
                this.UnmatchedArTypedPIM(dsmInfo(pimIdx).slObjName)=dsmInfo(pimIdx).slObjName;
            end

            dsmInfo=this.findMappedSynthDSMs('StaticMemory');
            for pimIdx=1:numel(dsmInfo)
                this.UnmatchedStaticMemory(dsmInfo(pimIdx).slObjName)=dsmInfo(pimIdx).slObjName;
            end
        end

        function[isMapped,dsmName,slObj]=isMapped(this,varargin)

            assert(slfeature('ArSynthesizedDS')>0,'Should not be called while feature is off');

            m3iData=varargin{1};
            type=varargin{2};

            if nargin<3||isempty(type)
                [isMapped,dsmName,slObj]=this.isMapped(m3iData,'ArTypedPerInstanceMemory');
                if~isMapped
                    [isMapped,dsmName,slObj]=this.isMapped(m3iData,'StaticMemory');
                end
                return;
            end

            isMapped=false;
            dsmName='';
            slObj=[];

            dsmInfo=this.findMappedSynthDSMs(type,m3iData.Name);
            if~isempty(dsmInfo)
                isMapped=true;
                slObj=dsmInfo.slObj;
                dsmName=dsmInfo.slObjName;
                switch type
                case 'ArTypedPerInstanceMemory'
                    if this.UnmatchedArTypedPIM.isKey(dsmName)
                        this.UnmatchedArTypedPIM.remove(dsmName);
                    end
                case 'StaticMemory'
                    if this.UnmatchedStaticMemory.isKey(dsmName)
                        this.UnmatchedStaticMemory.remove(dsmName);
                    end
                otherwise

                end

            end
        end

        function dsmInfo=findMappedSynthDSMs(this,type,shortName)
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
                if strcmp(m3iSerDep.UsedDataElement.Name,synthDsmShortName)
                    needsNVRAMAccess='true';
                    break;
                end
            end

            slMapping.mapSynthesizedDataStore(pimInfo.slObjName,mappedTo,...
            'ShortName',m3iObj.Name,...
            'SwAddrMethod',swAddrMethod,...
            'SwCalibrationAccess',autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iObj.SwCalibrationAccess),...
            'DisplayFormat',m3iObj.DisplayFormat,...
            'IsVolatile',m3iObj.Type.IsVolatile,...
            'Qualifier',m3iObj.Type.Qualifier,...
            'NeedsNVRAMAccess',needsNVRAMAccess);
        end

        function slObj=requiresSignalObject(this,mmPim)
            [~,slObj]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,mmPim.Name);
        end
    end

    methods(Access=protected)
        function logDeletionsGeneric(this,changeLogger,pimMap)
            slMapping=autosar.api.getSimulinkMapping(this.ModelName);
            pimNames=pimMap.keys();
            for dsmIdx=1:length(pimNames)
                dsmName=pimNames{dsmIdx};
                currentMapping=slMapping.getSynthesizedDataStore(dsmName);
                slMapping.mapSynthesizedDataStore(dsmName,'Auto');


                variableUsage=Simulink.findVars(this.ModelName,'Name',dsmName,'SearchMethod','cached');
                changeLogger.logModification('Automatic','DataStoreMemory mapping',...
                sprintf('data store signal object "%s" in block',dsmName),...
                variableUsage.Users{1},currentMapping,'Auto');
            end
        end
    end

    methods(Static)
        function pimInfo=generatePimInfo(mmPim,slObj)
            pimInfo=struct('slObjName',mmPim.Name,'slObj',slObj);
        end

        function modelMappings=getPimMappings(modelMapping)
            modelMappings=modelMapping.SynthesizedDataStores;
        end

        function arShortName=getShortNameFromMapping(mappingObj,mmPim)
            arShortName=mappingObj.getSynthesizedDataStore(mmPim.Name,'ShortName');
        end
    end
end


