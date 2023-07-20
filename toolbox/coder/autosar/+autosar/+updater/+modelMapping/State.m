classdef State<autosar.updater.modelMapping.PIMMapping









    methods
        function this=State(modelName)
            this=this@autosar.updater.modelMapping.PIMMapping(modelName);
        end

        function markAsUnmatched(this)
            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end

            if autosar.api.Utils.isMappedToAdaptiveApplication(this.ModelName)


                return;
            end

            stateInfo=this.findMappedStates('ArTypedPerInstanceMemory');
            for pimIdx=1:numel(stateInfo)
                this.UnmatchedArTypedPIM(stateInfo(pimIdx).slObjName)=...
                this.getMappingStruct(stateInfo(pimIdx).stateOwnerBlkH,stateInfo(pimIdx).slObjName);
            end

            stateInfo=this.findMappedStates('StaticMemory');
            for pimIdx=1:numel(stateInfo)
                this.UnmatchedStaticMemory(stateInfo(pimIdx).slObjName)=...
                this.getMappingStruct(stateInfo(pimIdx).stateOwnerBlkH,stateInfo(pimIdx).slObjName);
            end
        end

        function[isMapped,stateOwnerBlkH,stateName,slObj]=isMapped(this,varargin)

            m3iData=varargin{1};
            if nargin>=3
                type=varargin{2};
            else
                type='';
            end

            if isempty(type)
                [isMapped,stateOwnerBlkH,stateName,slObj]=this.isMapped(m3iData,'ArTypedPerInstanceMemory');
                if~isMapped
                    [isMapped,stateOwnerBlkH,stateName,slObj]=this.isMapped(m3iData,'StaticMemory');
                end
                return;
            end

            isMapped=false;
            stateOwnerBlkH=[];
            slObj=[];
            stateName='';

            stateInfo=this.findMappedStates(type,m3iData.Name);
            if~isempty(stateInfo)
                isMapped=true;
                stateOwnerBlkH=stateInfo.stateOwnerBlkH;
                slObj=stateInfo.slObj;
                stateName=stateInfo.slObjName;
                switch type
                case 'ArTypedPerInstanceMemory'
                    if this.UnmatchedArTypedPIM.isKey(stateInfo.slObjName)
                        this.UnmatchedArTypedPIM.remove(stateInfo.slObjName);
                    end
                case 'StaticMemory'
                    if this.UnmatchedStaticMemory.isKey(stateInfo.slObjName)
                        this.UnmatchedStaticMemory.remove(stateInfo.slObjName);
                    end
                otherwise

                end

            end
        end

        function stateInfo=findMappedStates(this,type,shortName)
            if nargin<3
                shortName='';
            end
            stateInfo=this.findMapped(type,shortName);
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

            slMapping.mapState(pimInfo.stateOwnerBlkH,pimInfo.slObjName,mappedTo,...
            'ShortName',m3iObj.Name,...
            'SwAddrMethod',swAddrMethod,...
            'SwCalibrationAccess',autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iObj.SwCalibrationAccess),...
            'DisplayFormat',m3iObj.DisplayFormat,...
            'IsVolatile',m3iObj.Type.IsVolatile,...
            'Qualifier',m3iObj.Type.Qualifier);
        end

        function slObj=requiresSignalObject(this,mmPim)
            slObj=[];
            blkH=mmPim.OwnerBlockHandle;
            requiresSignalObject=strcmp(get_param(blkH,'StateMustResolveToSignalObject'),'on');
            if requiresSignalObject
                [~,slObj]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,mmPim.Name);
            end
        end
    end

    methods(Access=protected)
        function logDeletionsGeneric(this,changeLogger,pimMap)
            slMapping=autosar.api.getSimulinkMapping(this.ModelName);
            pimNames=pimMap.keys();
            for stateIdx=1:length(pimNames)
                stateName=pimNames{stateIdx};
                stateOwnerBlkH=pimMap(stateName).stateOwnerBlkH;
                internalStateName=pimMap(stateName).stateName;
                currentMapping=slMapping.getState(stateOwnerBlkH,internalStateName);
                slMapping.mapState(stateOwnerBlkH,internalStateName,'Auto');

                if isfield(get_param(stateOwnerBlkH,'DialogParameters'),'StateStorageClass')
                    changeLogger.logModification('Automatic','State mapping',...
                    sprintf('state "%s" in block',internalStateName),...
                    getfullname(stateOwnerBlkH),currentMapping,'Auto');
                end
            end
        end
    end

    methods(Static)
        function pimInfo=generatePimInfo(mmPim,slObj)
            pimInfo=struct('slObjName',mmPim.Name,'stateOwnerBlkH',mmPim.OwnerBlockHandle,'slObj',slObj);
        end

        function modelMappings=getPimMappings(modelMapping)
            modelMappings=modelMapping.States;
        end

        function arShortName=getShortNameFromMapping(mappingObj,mmPim)
            stateName=mmPim.Name;
            stateOwnerBlkH=mmPim.OwnerBlockHandle;
            arShortName=mappingObj.getState(stateOwnerBlkH,stateName,'ShortName');
        end
    end

    methods(Static,Access=private)
        function stateMappingStruct=getMappingStruct(stateOwnerBlkH,stateName)
            stateMappingStruct=struct('stateOwnerBlkH',stateOwnerBlkH,'stateName',stateName);
        end
    end
end


