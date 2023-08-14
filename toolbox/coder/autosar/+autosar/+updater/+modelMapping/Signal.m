classdef Signal<autosar.updater.modelMapping.PIMMapping






    methods
        function this=Signal(modelName)
            this=this@autosar.updater.modelMapping.PIMMapping(modelName);
        end

        function markAsUnmatched(this)
            if~autosar.api.Utils.isMapped(this.ModelName)
                return
            end

            if autosar.api.Utils.isMappedToAdaptiveApplication(this.ModelName)


                return;
            end

            sigInfo=this.findMappedSignals('ArTypedPerInstanceMemory');
            for pimIdx=1:numel(sigInfo)
                this.UnmatchedArTypedPIM(sigInfo(pimIdx).slObjName)=sigInfo(pimIdx).lineH;
            end

            sigInfo=this.findMappedSignals('StaticMemory');
            for pimIdx=1:numel(sigInfo)
                this.UnmatchedStaticMemory(sigInfo(pimIdx).slObjName)=sigInfo(pimIdx).lineH;
            end
        end

        function[isMapped,lineH,slObj]=isMapped(this,varargin)

            m3iData=varargin{1};
            type=varargin{2};

            if nargin<3||isempty(type)
                [isMapped,lineH,slObj]=this.isMapped(m3iData,'ArTypedPerInstanceMemory');
                if~isMapped
                    [isMapped,lineH,slObj]=this.isMapped(m3iData,'StaticMemory');
                end
                return;
            end

            isMapped=false;
            lineH=[];
            slObj=[];

            sigInfo=this.findMappedSignals(type,m3iData.Name);
            if~isempty(sigInfo)
                isMapped=true;
                lineH=sigInfo.lineH;
                slObj=sigInfo.slObj;

                switch type
                case 'ArTypedPerInstanceMemory'
                    if this.UnmatchedArTypedPIM.isKey(sigInfo.slObjName)
                        this.UnmatchedArTypedPIM.remove(sigInfo.slObjName);
                    end
                case 'StaticMemory'
                    if this.UnmatchedStaticMemory.isKey(sigInfo.slObjName)
                        this.UnmatchedStaticMemory.remove(sigInfo.slObjName);
                    end
                otherwise

                end
            end
        end

        function sigInfo=findMappedSignals(this,type,shortName)
            if nargin<3
                shortName='';
            end
            sigInfo=this.findMapped(type,shortName);
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

            slMapping.mapSignal(pimInfo.lineH,mappedTo,...
            'ShortName',m3iObj.Name,...
            'SwAddrMethod',swAddrMethod,...
            'SwCalibrationAccess',autosar.mm.mm2sl.utils.convertSwCalibrationAccessKindToStr(m3iObj.SwCalibrationAccess),...
            'DisplayFormat',m3iObj.DisplayFormat,...
            'IsVolatile',m3iObj.Type.IsVolatile,...
            'Qualifier',m3iObj.Type.Qualifier);
        end

        function slObj=requiresSignalObject(this,mmPim)
            slObj=[];
            lineH=mmPim.PortHandle;
            requiresSignalObject=strcmp(get_param(lineH,'MustResolveToSignalObject'),'on');
            if requiresSignalObject
                [~,slObj]=autosar.utils.Workspace.objectExistsInModelScope(this.ModelName,mmPim.Name);
            end
        end
    end

    methods(Access=protected)
        function logDeletionsGeneric(this,changeLogger,pimMap)
            slMapping=autosar.api.getSimulinkMapping(this.ModelName);
            pimNames=pimMap.keys();
            for sigIdx=1:length(pimNames)
                sigName=pimNames{sigIdx};
                sigH=pimMap(sigName);
                currentMapping=slMapping.getSignal(sigH);
                slMapping.mapSignal(sigH,'Auto');
                changeLogger.logModification('Automatic','Signal mapping',...
                sprintf('signal line "%s" coming out of',get_param(sigH,'Name')),...
                get_param(sigH,'Parent'),currentMapping,'Auto');
            end
        end
    end

    methods(Static)
        function pimInfo=generatePimInfo(mmPim,slObj)
            pimInfo=struct('slObjName',mmPim.Name,'lineH',mmPim.PortHandle,'slObj',slObj);
        end

        function modelMappings=getPimMappings(modelMapping)
            modelMappings=modelMapping.Signals;
        end

        function arShortName=getShortNameFromMapping(mappingObj,mmPim)
            lineH=mmPim.PortHandle;
            arShortName=mappingObj.getSignal(lineH,'ShortName');
        end
    end
end


