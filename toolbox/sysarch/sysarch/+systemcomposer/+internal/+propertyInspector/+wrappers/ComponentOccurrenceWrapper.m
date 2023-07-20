classdef ComponentOccurrenceWrapper<systemcomposer.internal.propertyInspector.wrappers.ComponentElementWrapper





    properties
        mdl;
        occurenceElement;
        isImpl=false;
        isAdapterComp=false;
    end

    methods
        function obj=ComponentOccurrenceWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ComponentElementWrapper(varargin{:});

            if(obj.isAUTOSARCompositionSubDomain)
                obj.schemaType='AUTOSARComponent';
            elseif(obj.isAdapterComp)
                obj.schemaType='Adapter';
            else
                obj.schemaType='Component';
            end
        end
        function type=getObjectType(obj)
            if(obj.isAdapterComp)
                type='Adapter';
            else
                type='Component';
            end
        end
        function setPropElement(obj)
            obj.bdH=get_param(obj.archName,'Handle');
            obj.app=Simulink.SystemArchitecture.internal.ApplicationManager.getAppMgrFromBDHandle(obj.bdH);
            obj.mdl=obj.app.getArchViewsAppMgr.getModel();
            obj.occurenceElement=obj.mdl.findElement(obj.uuid);
            obj.element=obj.occurenceElement.getComponent;
            obj.sourceHandle=get_param(obj.element.getQualifiedName,'Handle');
            if(~ischar(obj.bdH)&&Simulink.internal.isArchitectureModel(obj.bdH,'AUTOSARArchitecture'))
                obj.isAUTOSARCompositionSubDomain=true;
                return;
            end
            if(obj.element.isAdapterComponent)
                obj.isAdapterComp=true;
            end
            if obj.element.isImplComponent
                obj.isImpl=true;
            end
            if obj.element.isReferenceComponent
                obj.isReference=true;
            end
            if isa(obj.element,'systemcomposer.architecture.model.design.VariantComponent')
                obj.isVarComp=true;
            end
            try
                contextElem=obj.element.getArchitecture;
            catch ME
                if~(strcmp(ME.identifier,'Simulink:Commands:OpenSystemUnknownSystem'))
                    rethrow(ME)
                else
                    contextElem={};
                end
            end
            if~isempty(contextElem)&&(~contextElem.hasParentComponent&&bdIsLoaded(contextElem.getName))
                obj.contextBdH=get_param(contextElem.getName,'Handle');
            else
                obj.contextBdH=obj.bdH;
            end
        end

        function[mode,entries]=getAdapterMode(obj,~)
            elem=obj.getElemToSetPropFor();
            elemH=elem.SimulinkHandle;

            mode=systemcomposer.internal.adapter.getAdapterMode(elemH);
            entries=systemcomposer.internal.adapter.getSupportedAdapterModes(elemH);
        end

        function error=setAdapterMode(obj,changeSet,~)
            error='';
            elem=obj.getElemToSetPropFor();
            elemH=elem.SimulinkHandle;
            newValue=changeSet.newValue;
            systemcomposer.internal.adapter.setAdapterMode(elemH,newValue,[]);
            systemcomposer.internal.adapter.resetAdapterMappingsForMerge(elemH);
        end

        function tooltip=getAdapterConversionTooltip(obj,~)
            elem=obj.getElemToSetPropFor();
            elemH=elem.SimulinkHandle;
            archName=bdroot(getfullname(elemH));
            if strcmp(get_param(archName,'SimulinkSubDomain'),'SoftwareArchitecture')
                tooltip=DAStudio.message('SystemArchitecture:Adapter:SWConversionTooltip');
            else
                tooltip=DAStudio.message('SystemArchitecture:Adapter:ConversionTooltip');
            end
        end

        function[kind,entries]=getKind(obj,~)
            kind=autosar.composition.pi.PropertyHandler.getPropertyValue(...
            obj.sourceHandle,'ComponentKind');
            if isempty(kind)
                kind='';
                entries=[];
                return;
            end
            if Simulink.CodeMapping.isAutosarAdaptiveSTF(obj.archName)
                entries={'AdaptiveApplication'};
            else
                entries=autosar.composition.Utils.getSupportedComponentKinds();
            end
        end

        function tooltip=getKindTooltip(obj,~)
            if autosar.composition.Utils.isComponentBlock(obj.sourceHandle)
                tooltip=DAStudio.message('autosarstandard:editor:PropertyInspectorComponentKind');
            else
                tooltip=DAStudio.message('autosarstandard:editor:PropertyInspectorComposition');
            end
        end

        function enabled=isKindEnabled(obj,~)
            if autosar.composition.Utils.isComponentBlock(obj.sourceHandle)&&...
                ~Simulink.CodeMapping.isAutosarAdaptiveSTF(obj.archName)
                enabled=~autosar.composition.Utils.isCompBlockLinked(obj.sourceHandle);
            else


                enabled=false;
            end
        end

        function value=getMappingsAction(~,~)
            value=DAStudio.message('SystemArchitecture:PropertyInspector:Edit');
        end

        function enabled=isAdapterMappingsEnabled(obj)
            elem=obj.getElemToSetPropFor();
            elemH=elem.SimulinkHandle;

            modeEnum=systemcomposer.internal.adapter.ModeEnums;
            enabled=~strcmpi(systemcomposer.internal.adapter.getAdapterMode(elemH),modeEnum.Merge);
        end

        function error=setKind(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            assert(autosar.api.Utils.isMappedToComposition(obj.archName),...
            'model %s has no AUTOSAR Composition information.',obj.archName);


            autosar.composition.pi.PropertyHandler.setPropertyValue(...
            obj.sourceHandle,'ComponentKind',newValue);
        end

        function error=setMappingsActions(obj,~,~)

            error='';
            elemH=systemcomposer.utils.getSimulinkPeer(obj.element);
            dObj=systemcomposer.internal.adapter.Dialog(elemH);
            dialogInstance=DAStudio.Dialog(dObj);

            dialogInstance.show();
            dialogInstance.refresh();
        end
    end
end


