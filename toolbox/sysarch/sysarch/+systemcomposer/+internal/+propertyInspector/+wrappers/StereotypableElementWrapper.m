classdef StereotypableElementWrapper<systemcomposer.internal.propertyInspector.wrappers.ElementWrapper





    properties
        stereotypeElement;
        isReference=false;
        isVarComp=false;
        DEL_STEREOTYPE_ICN='delete_16';
        EDIT_INTERFACE_MAP_ICN='';
        RESET_PROPS_TO_DEFAULT_ICN='refresh_16';
    end

    properties(Constant,Access=private)
        AddStr=DAStudio.message('SystemArchitecture:PropertyInspector:Add');
        RemoveStr=DAStudio.message('SystemArchitecture:PropertyInspector:RemoveAll');
        Separator=DAStudio.message('SystemArchitecture:PropertyInspector:Separator');



        OpenProfEditorStr=DAStudio.message('SystemArchitecture:PropertyInspector:NewOrEdit');
        RefreshStr=DAStudio.message('SystemArchitecture:PropertyInspector:Refresh');







    end

    methods
        function obj=StereotypableElementWrapper(varargin)


            obj=obj@systemcomposer.internal.propertyInspector.wrappers.ElementWrapper(varargin{:});
            obj.setStereotypeElement();
        end

        function setStereotypeElement(obj)
            obj.stereotypeElement=obj.element;
        end
        function[value,entries]=getAppliedStereotypeAction(this)

            value='';
            entries={this.DEL_STEREOTYPE_ICN,this.RESET_PROPS_TO_DEFAULT_ICN};






        end
        function err=setAppliedStereotypeAction(obj,changeSet,propObj)
            err='';
            id=propObj.id;
            stereotypeIDSet=split(id,':');
            stereotypeFqn=stereotypeIDSet{end};
            elem=obj.stereotypeElement;
            if ischar(changeSet)
                switch changeSet
                case{"doRemove",'Remove'}
                    elem.removePrototype(stereotypeFqn);
                case{"doReset",'Reset to default values'}
                    systemcomposer.internal.resetToDefaultValues(elem,stereotypeFqn);
                end
            end
        end
        function toolTip=propertyTooltip(elemWrap,prop)

            propTag=prop;
            elem=elemWrap.stereotypeElement;
            if~contains(propTag,':')

                if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')||isa(elem,'systemcomposer.architecture.model.design.Architecture')


                    elem=systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema.getArchitectureInContext(elemWrap.element);
                end
                defaultProps=systemcomposer.internal.getPropertiesUsingDefaultValuesInStereotypeHierarchy(elem,propTag);
                if~isempty(defaultProps)
                    defaultPropNamesList=cellfun(@(name)sprintf('\n- %s',name),defaultProps,'UniformOutput',false);
                    toolTip=strcat(DAStudio.message('SystemArchitecture:PropertyInspector:DefaultProperties'),...
                    sprintf('%s',defaultPropNamesList{:}));
                else
                    toolTip=propTag;
                end
            else

                prototypeName=propTag(1:strfind(propTag,':')-1);
                propName=propTag(strfind(propTag,':')+1:end);
                if strcmp(propName,DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions'))
                    toolTip=DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions');
                else
                    if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')||isa(elem,'systemcomposer.architecture.model.design.Architecture')


                        elem=systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema.getArchitectureInContext(elemWrap.element);
                    end
                    PU=elemWrap.getPropUsage(prototypeName,propName);
                    if~isempty(PU.propertyDef)
                        toolTip=PU.propertyDef.fullyQualifiedName;
                    else
                        toolTip=[PU.getName,DAStudio.message('SystemArchitecture:PropertyInspector:UnresolvedLabel')];
                    end

                    try
                        if elem.isPropValDefault([prototypeName,'.',propName])
                            toolTip=[toolTip,' ',DAStudio.message('SystemArchitecture:PropertyInspector:DefaultLabel')];
                        end
                    end
                end
            end
        end
        function value=propertyValue(elemWrap,prop)
            elem=elemWrap.stereotypeElement;
            if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')||isa(elem,'systemcomposer.architecture.model.design.Architecture')


                elem=systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema.getArchitectureInContext(elemWrap.element);
            end
            propFullName=(prop);
            if contains(propFullName,':')
                propName=propFullName(strfind(propFullName,":")+1:end);
                if strcmp(propName,DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions'))
                    value='';
                    return
                end
                prototypeName=propFullName(1:strfind(propFullName,":")-1);
                propFullName=[prototypeName,'.',propName];

                propValue=elem.getPropVal(propFullName);
                PU=elemWrap.getPropUsage(prototypeName,propName);

                if strcmp(elemWrap.getPropertyClass(PU),'numeric')
                    value=[propValue.expression,' ',propValue.units];
                elseif strcmp(elemWrap.getPropertyClass(PU),'enumeration')

                    try


                        valObj=elem.getPropValObject(propFullName);
                        propValOriginal=valObj.getValue;
                        value=char(propValOriginal);
                        if~strcmp(value,eval(propValue.expression))




                            value=eval(propValue.expression);
                            ZCStudio.notifyInvalidEnum(elem,PU.propertyDef);
                        end
                    catch ME
                        if(strcmp(ME.identifier,'SystemArchitecture:Property:InvalidEnumPropValue'))

                            ZCStudio.notifyInvalidEnum(elem,PU.propertyDef);
                        else
                            rethrow(ME);
                        end
                    end
                elseif strcmp(elemWrap.getPropertyClass(PU),'unresolved')
                    propVal=elem.getPropVal(propFullName);
                    if~isempty(propVal.units)
                        value=[propVal.expression,' ',propVal.units];
                    else
                        value=propVal.expression;
                    end
                else
                    value=propValue.expression;
                end
            else

                value=DAStudio.message('SystemArchitecture:PropertyInspector:Select');
            end
        end
        function prop_class=getPropertyClass(~,propertyUsage)



            if isempty(propertyUsage.propertyDef)
                prop_class='unresolved';
                return;
            end

            pd_class=class(propertyUsage.propertyDef.type);
            switch pd_class
            case 'systemcomposer.property.BooleanType'
                prop_class='bool';
            case{'systemcomposer.property.StringType',...
                'systemcomposer.property.StringArrayType'}
                prop_class='string';
            case{'systemcomposer.property.FloatType',...
                'systemcomposer.property.IntegerType'}
                prop_class='numeric';
            case 'systemcomposer.property.Enumeration'
                prop_class='enumeration';
            otherwise
                prop_class='string';
            end
        end
        function props=getSubPropertiesForPrototype(elemWrap,prototypeName)
            elem=elemWrap.stereotypeElement;
            propSetUsage=elem.getPropertySet(prototypeName);
            props={};

            if isempty(propSetUsage)
                return;
            end

            while~isempty(propSetUsage)
                propUsages=propSetUsage.properties.toArray;
                foundProps={};
                missingProps={};

                for propUsage=propUsages
                    propDef=propUsage.propertyDef;
                    if~isempty(propDef)&&strcmp(propDef.getName,propUsage.getName)
                        originalIdx=propDef.p_Index;
                        foundProps{originalIdx+1}=[propSetUsage.getName,':',propDef.getName];%#ok<AGROW>, % prop defs are 0-indexed
                    else

                        missingProps{end+1}=[propSetUsage.getName,':',propUsage.getName];%#ok<AGROW>
                    end
                end

                emptyIdx=cellfun(@isempty,foundProps);
                if any(emptyIdx)



                    foundProps(emptyIdx)=[];%#ok<AGROW>
                end

                props=horzcat(props,foundProps,missingProps);%#ok<AGROW>

                propSetUsage=propSetUsage.p_Parent;
            end

            if isempty(props)
                props={[prototypeName,':',DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions')]};
            end
        end
        function editor=propertyEditor(elem,prop)

            if~contains(prop,':')

                editor=DAStudio.UI.Widgets.ComboBox;
                editor.Entries={'',...
                DAStudio.message('SystemArchitecture:PropertyInspector:Remove'),...
                DAStudio.message('SystemArchitecture:PropertyInspector:MakeDefault')};
                editor.Index=0;
                actualProto=elem.element.p_Prototype.findobj('p_Name',prop);
                if(~isempty(actualProto))
                    if(actualProto.hasMissingParent(true))
                        editor.Entries{end+1}=DAStudio.message('SystemArchitecture:PropertyInspector:UnlinkParent');
                    end
                end
                editor.Editable=false;
                return
            end

            if isa(elem.element,'systemcomposer.architecture.model.design.BaseComponent')

                elem.element=systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema.getArchitectureInContext(elem.element);
            end

            x=split(prop,':');
            prototypeName=x{1};
            prop=x{2};
            PU=elem.getPropUsage(prototypeName,prop);
            propFullName=[prototypeName,'.',prop];
            propValue=elem.element.getPropVal(propFullName);
            if isempty(PU.propertyDef)
                prop_class='unresolved';
            else
                pd_class=class(PU.propertyDef.type);
                switch pd_class
                case 'systemcomposer.property.BooleanType'
                    prop_class='bool';
                case{'systemcomposer.property.StringType',...
                    'systemcomposer.property.StringArrayType'}
                    prop_class='string';
                case{'systemcomposer.property.FloatType',...
                    'systemcomposer.property.IntegerType'}
                    prop_class='numeric';
                case 'systemcomposer.property.Enumeration'
                    prop_class='enumeration';
                otherwise
                    prop_class='string';
                end
            end
            if strcmp(prop_class,'numeric')
                editor=DAStudio.UI.Container.Panel;


                valueBox=DAStudio.UI.Widgets.Edit;
                valueBox.Tag=strcat(prop,':Value');
                valueBox.Text=propValue.expression;


                unitsBox=DAStudio.UI.Widgets.ComboBox;
                currentUnit=propValue.units;
                compatibleUnits=PU.getSimilarUnits();
                if isempty(compatibleUnits)&&~isempty(PU.propertyDef.type.units)


                    compatibleUnits={PU.propertyDef.type.units};
                end
                idxDefinedUnits=strcmp(currentUnit,compatibleUnits);
                if(~any(idxDefinedUnits))


                    compatibleUnits{end+1}=currentUnit;
                end
                unitsBox.Entries=compatibleUnits;
                unitsBox.Index=find(strcmp(compatibleUnits,currentUnit),true,'first')-1;
                if isempty(unitsBox.Index)
                    return;
                end
                unitsBox.Editable=true;
                unitsBox.Tag=strcat(prop,':Unit');
                unitsBox.CurrentText=currentUnit;
                editor.Children={valueBox,unitsBox};

            elseif strcmp(prop_class,'enumeration')
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.Entries=PU.propertyDef.type.getLiteralsAsStrings;
                editor.Index=find(strcmp(eval(propValue.expression),editor.Entries),true,'first')-1;
            else
                editor=DAStudio.UI.Widgets.Edit;
                editor.Text=propValue.expression;
            end
        end

        function profileSource=getProfileSource(obj)
            mdlId=systemcomposer.services.proxy.ModelIdentifier.getModelIdentifier(mf.zero.getModel(obj.stereotypeElement));
            profileSource=mdlId.URI;
        end

        function[value,entries]=getStereotypes(obj)


            addStr=DAStudio.message('SystemArchitecture:PropertyInspector:Add');
            if strcmp(obj.getObjectType,'Connector')
                if~(ishandle(get_param(obj.sourceHandle,'DstPortHandle')))
                    value=addStr;
                    entries={};
                    return;
                end
            end

            if isempty(obj.stereotypeElement)
                value=addStr;
                entries={};
                return;
            end
            profileSource=obj.getProfileSource();















            objectType=obj.getObjectType;
            if(strcmpi(objectType,'NAryConnector'))
                objectType='Connector';
            end
            allValidStereotypes=systemcomposer.internal.arch.internal.getAllPrototypesFromArchProfile(...
            profileSource,true,['systemcomposer.',objectType]);
            elemPrototypes={};
            mixinPrototypes={};
            for i=1:numel(allValidStereotypes)
                if systemcomposer.internal.isPrototypeMixin(allValidStereotypes(i))
                    mixinPrototypes{end+1}=allValidStereotypes(i).fullyQualifiedName;%#ok<AGROW>
                else
                    elemPrototypes{end+1}=allValidStereotypes(i).fullyQualifiedName;%#ok<AGROW>
                end
            end
            entries=horzcat(elemPrototypes,mixinPrototypes);
            value=addStr;
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

                    elem=obj.element;
                    if isa(obj.element,'systemcomposer.architecture.model.design.BaseComponent')

                        elem=systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema.getArchitectureInContext(obj.element);
                        topArch=obj.element.getArchitecture.getTopLevelArchitecture;
                    else
                        topArch=obj.element.getTopLevelArchitecture;
                    end
                    thatZCModel=topArch.p_Model;
                    profInfo=strsplit(changeSet.newValue,'.');
                    if isempty(obj.h)
                        obj.stereotypeElement.applyPrototype(changeSet.newValue);
                    else
                        if isempty(thatZCModel.getProfile(profInfo{1}))
                            thatZCModel.addProfile(profInfo{1});
                        end

                        systemcomposer.internal.arch.applyPrototype(elem,changeSet.newValue);
                    end

                catch ME
                    err=ME;
                end
            end
        end

        function handleRemoveAllStereotypes(obj,response)
            if strcmp(response,DAStudio.message('SystemArchitecture:PropertyInspector:ConfirmRemoveAllStereotypes_Yes'))
                systemcomposer.internal.arch.removePrototype(obj.element,'all');
                systemcomposer.internal.propertyInspector.schema.PropertySetSchema.refresh(obj.sourceHandle);
            end
        end
        function enable=isAddStereotypeEnabled(obj)
            enable=~obj.isReference&&~obj.isVarComp;
            try
                owningArch=obj.element.getContainingArchitecture();
                if owningArch.isVariantArchitecture()
                    enable=false;
                end
            end
        end
        function performRemoveAction(~,elem,prop)
            if~elem.hasPrototype(prop,false)
                confirm=systemcomposer.internal.arch.internal.propertyinspector.createDeletePSUDialog(prop);
                if strcmp(confirm,message('SystemArchitecture:PropertyInspector:ConfirmDeletePSU_Yes').string)
                    elem.getPropertySetUsage(prop).destroy;
                end
            else
                confirm=systemcomposer.internal.arch.internal.propertyinspector.createDeleteStereotypeDialog(prop,elem.getName);
                if strcmp(confirm,message('SystemArchitecture:PropertyInspector:ConfirmDeleteStereotype_Yes').string)
                    elem.removePrototype(prop);
                end
            end
        end
        function err=setPropertyVal(elemWrap,prop,newValue)
            err={};
            elem=elemWrap.stereotypeElement;

            if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')||isa(elem,'systemcomposer.architecture.model.design.Architecture')

                elem=systemcomposer.internal.propertyInspector.schema.PropertyInspectorSchema.getArchitectureInContext(elemWrap.element);
            end

            check=prop(1:strfind(prop,':')-1);
            StereoName=elemWrap.stereotypeElement.p_Prototype;
            propFullName=prop;
            for i=1:numel(StereoName)
                if ismember(check,(StereoName(i).propertySet.getAllPropertyNames))
                    name=StereoName(i).fullyQualifiedName;
                    propFullName=[name,':',prop];
                end

            end
            if~contains(propFullName,':')

                if strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:Remove'))
                    elemWrap.performRemoveAction(elem,propFullName)
                end

                if strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:MakeDefault'))



                    systemcomposer.internal.resetToDefaultValues(elem,propFullName);
                end
                if strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:UnlinkParent'))
                    actualProto=elem.p_Prototype.findobj('p_Name',propFullName);
                    SysarchPrototypeHandler.unlinkMissingParent(elem,actualProto);
                end
                try
                    if strcmp(prop,'Description')
                        elemWrap.h.Description=newValue;
                    end
                end
                return
            end
            if contains(propFullName,':')
                propUsageTag=propFullName(strfind(propFullName,':')+1:end);
                propType='';
            else
                return;
            end
            if contains(propUsageTag,':')


                propUsage=propUsageTag(1:strfind(propUsageTag,':')-1);
                propType=propUsageTag(strfind(propUsageTag,':')+1:end);


            else
                propUsage=propUsageTag;
            end
            if contains(propFullName,':')
                prototypeName=propFullName(1:strfind(propFullName,':')-1);
                PU=elemWrap.getPropUsage(prototypeName,propUsage);
            else
                return;
            end
            if isempty(PU.propertyDef)
                prop_class='unresolved';

            else
                pd_class=class(PU.propertyDef.type);
                switch pd_class
                case 'systemcomposer.property.BooleanType'
                    prop_class='bool';
                case{'systemcomposer.property.StringType',...
                    'systemcomposer.property.StringArrayType'}
                    prop_class='string';
                case{'systemcomposer.property.FloatType',...
                    'systemcomposer.property.IntegerType'}
                    prop_class='numeric';
                case 'systemcomposer.property.Enumeration'
                    prop_class='enumeration';
                otherwise
                    prop_class='string';
                end
            end


            switch prop_class
            case 'numeric'
                if isempty(newValue)

                    PU.clearValue(elem.UUID);
                    return;
                end
            case 'bool'
                bvalue=eval(newValue);
                if bvalue
                    newValue='true';
                else
                    newValue='false';
                end
            otherwise
                if isempty(newValue)
                    newValue='';
                else

                    try
                        PU.validateExpression(newValue);
                    catch ME
                        if(strcmp(ME.identifier,'SystemArchitecture:Property:CannotEvalExpression')||...
                            strcmp(ME.identifier,'SystemArchitecture:Property:InvalidStringPropValue'))

                            newValue="'"+string(newValue)+"'";
                        else
                            rethrow(ME);
                        end
                    end
                end
            end


            try
                propFQN=[prototypeName,'.',propUsage];
                prevValue=elem.getPropVal(propFQN);
                setValue=false;
                if isempty(propType)||strcmp(propType,'Value')
                    expressionToSet=newValue;
                    setValue=true;
                    if isempty(prevValue.units)
                        unitsToSet='';
                    else
                        unitsToSet=prevValue.units;
                    end
                elseif strcmp(propType,'Unit')
                    setValue=true;
                    expressionToSet=prevValue.expression;
                    unitsToSet=newValue;
                end

                if setValue
                    elem.setPropVal(propFQN,expressionToSet,unitsToSet);
                end
            catch ME
                err=ME;
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
        function mode=propertyRenderMode(elem,prop)
            if~contains(prop,':')
                mode='RenderAsComboBox';
                return;
            else
                x=split(prop,':');
                protoName=x{1};
                propUsage=x{2};
                if strcmp(propUsage,DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions'))
                    mode='RenderAsText';
                    return;
                end
                try
                    PU=elem.getPropUsage(protoName,propUsage);
                catch
                    mode="";
                    return;
                end
                if strcmp(elem.getPropertyClass(PU),'bool')
                    mode='RenderAsCheckBox';
                elseif strcmp(elem.getPropertyClass(PU),'enumeration')
                    mode='RenderAsComboBox';
                else
                    mode='RenderAsText';
                end
            end
        end
        function PU=getPropUsage(obj,protoName,propUsgName)



            if isa(obj.stereotypeElement,'systemcomposer.architecture.model.design.BaseComponent')
                obj.stereotypeElement=obj.stereotypeElement.getArchitecture;
            end
            psu=obj.stereotypeElement.getPropertySet(protoName);
            PU=psu.getPropertyUsage(propUsgName);

            if isempty(PU)


                protoParent=psu.p_Parent;
                if~isempty(protoParent)
                    PU=obj.getPropUsage(protoParent.getName,propUsgName);
                end
            end
        end

        function prop=removeFakeProperty(fakeProp)







            idx=strfind(fakeProp,':');
            if~isempty(idx)
                prop=fakeProp(1:idx(end)-1);
            end
        end

    end
end
