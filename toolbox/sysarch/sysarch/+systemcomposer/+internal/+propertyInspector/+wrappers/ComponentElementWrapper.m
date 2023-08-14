classdef ComponentElementWrapper<systemcomposer.internal.propertyInspector.wrappers.ArchitectureElementWrapper





    properties
        IsInView;
        isImpl;
        isAdapterComp=false;
    end

    methods
        function obj=ComponentElementWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ArchitectureElementWrapper(varargin{:});
            if nargin>3
                obj.IsInView=varargin{4};
            else
                obj.IsInView=false;
            end


            if(obj.isAUTOSARCompositionSubDomain)
                obj.schemaType='AUTOSARComponent';
            elseif(obj.element.isAdapterComponent)
                obj.schemaType='Adapter';
            else
                obj.schemaType='Component';
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

            obj.sourceHandle=obj.getElemToSetPropFor.SimulinkHandle;
        end

        function type=getObjectType(obj)
            if(obj.element.isAdapterComponent)
                type='Adapter';
            else
                type='Component';
            end
        end

        function setStereotypeElement(obj)
            if obj.element.isSubsystemReferenceComponent
                obj.stereotypeElement=obj.element.getOwnedArchitecture;
            else
                obj.stereotypeElement=obj.element.getArchitecture;
            end
        end

        function name=getNameTooltip(obj)

            elem=obj.getElemToSetPropFor();
            name=elem.getQualifiedName;
        end
        function name=getName(obj)

            if~(obj.sourceHandle==-1)
                name=get_param(obj.sourceHandle,'Name');
            else
                name=obj.element.getName;
            end
        end

        function error=setName(obj,changeSet,~)

            error='';
            newValue=changeSet.newValue;
            try
                obj.getElemToSetPropFor().Name=newValue;
            catch
                error='Failed to set Name';
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
            if autosar.composition.Utils.isComponentBlock(obj.getElemToSetPropFor.SimulinkHandle)
                tooltip=DAStudio.message('autosarstandard:editor:PropertyInspectorComponentKind');
            else
                tooltip=DAStudio.message('autosarstandard:editor:PropertyInspectorComposition');
            end
        end

        function enabled=isKindEnabled(obj,~)
            if autosar.composition.Utils.isComponentBlock(obj.getElemToSetPropFor.SimulinkHandle)&&...
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
            elem=obj.getElemToSetPropFor();
            elemH=elem.SimulinkHandle;
            dObj=systemcomposer.internal.adapter.Dialog(elemH);
            dialogInstance=DAStudio.Dialog(dObj);

            dialogInstance.show();
            dialogInstance.refresh();
        end

        function err=setParameterValue(obj,changeSet,propObj)
            paramName=propObj.id;
            newValue=changeSet.newValue;
            [~,remain]=strtok(changeSet.tag,':');
            [propName,~]=strtok(remain,':');
            err='';
            elem=obj.getElemToSetPropFor;
            try
                switch(propName)
                case 'Value'
                    elem.setParameterValue(paramName,newValue);
                case 'Unit'

                    ex=MException('SystemArchitecture:Views:CannotChangeUnitOnInstance',message('SystemArchitecture:Views:CannotChangeUnitOnInstance').getString);
                    throw(ex);
                end
            catch mException
                rethrow(mException);
            end
        end

        function[value,entries]=getParameterValue(obj,paramName)
            entries={};
            elem=obj.getElemToSetPropFor;
            valStruct=elem.getImpl.getParamVal(paramName);
            paramUsage=elem.getImpl.getParameter(paramName);
            if isempty(paramUsage)
                paramDef=elem.getImpl.getParameterDefinition(paramName);
            else
                paramDef=paramUsage.definition;
            end
            if isempty(paramDef)
                paramVal=valStruct.expression;
                paramUnits=valStruct.units;
            else
                switch class(paramDef.type)
                case 'systemcomposer.property.BooleanType'
                    paramVal=valStruct.expression;
                    paramUnits='';
                case{'systemcomposer.property.StringType',...
                    'systemcomposer.property.StringArrayType'}
                    paramVal=valStruct.expression;
                    paramUnits='';
                case{'systemcomposer.property.FloatType',...
                    'systemcomposer.property.IntegerType'}
                    paramVal=valStruct.expression;
                    paramUnits=valStruct.units;
                    if isempty(paramUnits)
                        paramUnits=paramDef.ownedType.units;
                    end
                    if~isempty(paramUnits)
                        compatibleUnits=paramDef.getSimilarUnits();
                        if isempty(compatibleUnits)


                            compatibleUnits={paramDef.type.units};
                        end
                        entries=compatibleUnits;
                    end
                case 'systemcomposer.property.Enumeration'
                    try
                        enumVal=eval(valStruct.expression);
                        paramVal=char(enumVal);
                        entries=paramDef.type.getLiteralsAsStrings;
                    catch ME
                        if(strcmp(ME.identifier,'SystemArchitecture:Property:InvalidEnumPropValue'))
                            propVal=eval(val.expression);
                        else
                            rethrow(ME)
                        end
                    end
                    paramUnits='';
                otherwise
                end
            end
            if~isempty(paramUnits)
                value=[paramVal,' ',paramUnits];
            else
                value=paramVal;
            end
        end

    end

    methods(Access=private)
        function elem=getElemToSetPropFor(obj)
            elem=obj.element;
            if(obj.IsInView)&&~isempty(elem.p_Redefines)
                elem=elem.p_Redefines;
            end
            elem=systemcomposer.internal.getWrapperForImpl(elem);
        end
    end
end


