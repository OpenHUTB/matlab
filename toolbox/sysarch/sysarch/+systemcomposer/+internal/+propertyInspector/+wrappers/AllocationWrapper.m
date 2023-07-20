classdef AllocationWrapper<systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper





    properties
        allocationSet;
        allocCatalog;
        scenarioName;
        scenario;
        allocation;
        source;
        target;
        sourceModelName;
        targetModelName;
        sourceElement;
        sourceElemUUID;
        sourceElemType;
        targetElement;
        targetElemUUID;
        targetElemType;
        sourceElemWrapper;
        targetElemWrapper;
        schemaType;
    end

    properties(Constant,Access=private)
        AddStr=DAStudio.message('SystemArchitecture:PropertyInspector:Add');
        RemoveStr=DAStudio.message('SystemArchitecture:PropertyInspector:RemoveAll');
        Separator=DAStudio.message('SystemArchitecture:PropertyInspector:Separator');
        OpenProfEditorStr=DAStudio.message('SystemArchitecture:PropertyInspector:NewOrEdit');
    end

    methods(Static)
        function res=hasBase(currentStereotype,baseName)
            res=false;
            if currentStereotype.appliesTo.indexOf(baseName)>0
                res=true;
            elseif~isempty(currentStereotype.parent)
                res=systemcomposer.internal.propertyInspector.wrappers.AllocationWrapper.hasBase(currentStereotype.parent,baseName);
            end
        end
    end

    methods
        function obj=AllocationWrapper(varargin)

            obj=obj@systemcomposer.internal.propertyInspector.wrappers.StereotypableElementWrapper(varargin{:});
            if isempty(obj.targetElement)
                obj.schemaType='AllocationElement';
            else
                obj.schemaType='Allocation';
            end
        end
        function type=getObjectType(obj)
            if isempty(obj.targetElement)
                type=obj.sourceElemType;
            else
                type='Allocation';
            end
        end

        function setPropElement(obj)
            obj.allocCatalog=systemcomposer.allocation.app.AllocationAppCatalog.getInstance;
            obj.allocationSet=obj.allocCatalog.getAllocationSet(obj.archName);
            obj.sourceModelName=obj.allocationSet.p_SourceModel.p_ModelURI;
            obj.targetModelName=obj.allocationSet.p_TargetModel.p_ModelURI;
            obj.element=mf.zero.getModel(obj.allocationSet).findElement(obj.uuid);
            obj.source=obj.element;
            obj.sourceElement=obj.element.getElement;
            obj.sourceElemUUID=obj.element.p_ElemUUID;
            obj.sourceElemType=systemcomposer.internal.propertyInspector.getElemType(obj.sourceElement);
            if isa(obj.element,'systemcomposer.allocation.model.AllocationTarget')
                obj.sourceElemWrapper=systemcomposer.internal.propertyInspector.getElementWrapperFromType(obj.sourceElemType,obj.sourceElemUUID,obj.targetModelName,'');
            else
                obj.sourceElemWrapper=systemcomposer.internal.propertyInspector.getElementWrapperFromType(obj.sourceElemType,obj.sourceElemUUID,obj.sourceModelName,'');
            end
            if isfield(obj.options,'targetElemUUID')
                targetAllocElemUUID=obj.options.targetElemUUID;
                obj.scenarioName=obj.options.scenarioName;
                obj.scenario=obj.allocationSet.getScenario(obj.scenarioName);
                obj.target=mf.zero.getModel(obj.allocationSet).findElement(targetAllocElemUUID);
                obj.allocation=obj.scenario.getAllocation(obj.source,obj.target);
                obj.targetElement=obj.target.getElement;
                obj.targetElemUUID=obj.targetElement.UUID;
                obj.targetElemType=systemcomposer.internal.propertyInspector.getElemType(obj.targetElement);
                obj.targetElemWrapper=systemcomposer.internal.propertyInspector.getElementWrapperFromType(obj.targetElemType,obj.targetElemUUID,obj.targetModelName,'');
            end
        end

        function type=getSourceType(obj)
            type=obj.sourceElemType;
        end

        function type=getTargetType(obj)
            type=obj.targetElemType;
        end

        function status=getAllocationStatus(obj)
            obj.allocation=obj.scenario.getAllocation(obj.source,obj.target);
            if isempty(obj.allocation)
                status='false';
            else
                status='true';
            end
            obj.setStereotypeElement();
        end

        function[value,entries]=getStereotypes(obj)




            value=DAStudio.message('SystemArchitecture:PropertyInspector:Add');

            allValidStereotypes=systemcomposer.internal.profile.Prototype.empty;
            profiles=obj.allocationSet.p_ProfileNamespace.Profiles;
            for pi=1:numel(profiles)
                profile=profiles(pi);
                prototypes=profile.prototypes.toArray;
                for pii=1:numel(prototypes)
                    allValidStereotypes(end+1)=prototypes(pii);%#ok<AGROW>
                end
            end


            currentPrototypes={};
            if(~isempty(obj.stereotypeElement))
                for pi=1:numel(obj.stereotypeElement.p_Prototype)
                    prototype=obj.stereotypeElement.p_Prototype(pi);
                    currentPrototypes{end+1}=prototype.fullyQualifiedName;%#ok<AGROW>
                end
            end
            elemPrototypes={};
            mixinPrototypes={};
            for i=1:numel(allValidStereotypes)
                if isempty(find(strcmp(currentPrototypes,allValidStereotypes(i).fullyQualifiedName),1))
                    if systemcomposer.internal.isPrototypeMixin(allValidStereotypes(i))
                        mixinPrototypes{end+1}=allValidStereotypes(i).fullyQualifiedName;%#ok<AGROW>
                    elseif obj.hasBase(allValidStereotypes(i),'Allocation')
                        elemPrototypes{end+1}=allValidStereotypes(i).fullyQualifiedName;%#ok<AGROW>
                    end
                end
            end

            entries=horzcat(elemPrototypes,mixinPrototypes);
        end

        function err=setStereotype(obj,changeSet,~)


            err='';
            if strcmp(changeSet.newValue,obj.RemoveStr)
                dp=DAStudio.DialogProvider;
                dp.questdlg(DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes',obj.element.getName),...
                DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Title'),...
                {DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Yes'),...
                DAStudio.message('SystemArchitecture:PropertyInspector:Cancel')},...
                DAStudio.message('SystemArchitecture:PropertyInspector:Cancel'),...
                @(response)obj.handleRemoveAllStereotypes(response));

            elseif strcmp(changeSet.newValue,obj.OpenProfEditorStr)
                systemcomposer.internal.profile.Designer.launch
                return

            elseif any(strcmp(changeSet.newValue,{obj.AddStr,''}))
                return

            else
                try
                    alloc=obj.scenario.getAllocation(obj.source,obj.target);
                    alloc.applyPrototype(changeSet.newValue);
                catch ME
                    err=ME;
                end
            end
        end
        function profileSource=getProfileSource(obj)
            profileSource=obj.allocationSet.UUID;
        end

        function setStereotypeElement(obj)
            if~isempty(obj.allocation)
                obj.stereotypeElement=obj.allocation;
            end
        end

        function err=setPropertyValue(obj,changeSet,propObj)


            err='';
            id=propObj.id;
            stereotypeAndPropertyName=split(id,':');
            stereotypeName=stereotypeAndPropertyName{end-1};
            propName=stereotypeAndPropertyName{end};
            elem=obj.stereotypeElement;
            propUsg=obj.getPropUsage(stereotypeName,propName);
            propType='Value';

            newValue=changeSet.newValue;
            widgetTag=changeSet.tag;
            switch class(propUsg.propertyDef.type)
            case 'systemcomposer.property.BooleanType'
                if newValue
                    newValue='true';
                else
                    newValue='false';
                end
            case{'systemcomposer.property.StringType',...
                'systemcomposer.property.StringArrayType'}

                try
                    propUsg.initialValue.type.validateExpression(newValue);
                catch ME
                    if strcmp(ME.identifier,'SystemArchitecture:Property:CannotEvalExpression')||...
                        strcmp(ME.identifier,'SystemArchitecture:Property:InvalidStringPropValue')

                        newValue="'"+string(newValue)+"'";
                    else
                        rethrow(ME);
                    end
                end
            case{'systemcomposer.property.FloatType',...
                'systemcomposer.property.IntegerType'}
                tag=split(widgetTag,':');
                tag=tag{end};
                switch tag
                case 'Value'
                    if isempty(newValue)
                        propUsg.clearValue(elem.UUID);
                        return;
                    end
                case 'Unit'
                    propType='Unit';
                    if isempty(newValue)


                        newValue=propUsg.propertyDef.defaultValue.units;
                    end
                otherwise
                    error('Invalid tag received on setting property value');
                end
            case 'systemcomposer.property.Enumeration'
                newValue="'"+string(newValue)+"'";
            otherwise
                error("Invalid Property")
            end
            propFQN=[propUsg.propertySet.getName,'.',propUsg.getName];
            prevValue=elem.getPropVal(propFQN);
            setValue=false;
            if strcmp(propType,'Value')
                expressionToSet=newValue;
                setValue=true;
                if isempty(prevValue.units)
                    unitsToSet='*';
                else
                    unitsToSet=prevValue.units;
                end
            elseif strcmp(propType,'Unit')
                setValue=true;
                expressionToSet=prevValue.expression;
                unitsToSet=newValue;
            end

            try
                if setValue
                    elem.setPropVal(propFQN,expressionToSet,unitsToSet);
                end
            catch ME
                if strcmp(ME.identifier,'SystemArchitecture:Property:ErrorSettingPropertyValue')&&~isempty(ME.cause)



                    throw(ME.cause{1});
                else
                    rethrow(ME)
                end
            end
        end

        function err=setAllocation(obj,changeSet,~)
            err='';
            allocationAction=changeSet.newValue;
            if allocationAction

                mdl=mf.zero.getModel(obj.scenario);
                txn=mdl.beginTransaction();
                obj.scenario.allocate(obj.source,obj.target);
                txn.commit();
            else

                mdl=mf.zero.getModel(obj.scenario);
                txn=mdl.beginTransaction();
                obj.scenario.deallocate(obj.source,obj.target);
                txn.commit();
            end
        end
    end
end

