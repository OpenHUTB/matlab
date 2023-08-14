classdef SysarchPrototypeHandler<handle





    properties(Constant,Access=public)

        stripPrototypePropTag=@(tag)tag(19:end)

        extractTopTag=@(tag)tag(1:strfind(tag,':')-1)

        extractBottomTag=@(tag)tag(strfind(tag,':')+1:end)

        isPrototypeZC=@(proto)any(strcmp(proto,{...
        'systemcomposer.Common',...
        'systemcomposer.Component',...
        'systemcomposer.Architecture',...
        'systemcomposer.Port',...
        'systemcomposer.Connector'}));
    end

    methods(Static)


        function toolTip=propertyTooltip(elem,prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler
            propTag=SysarchPrototypeHandler.stripPrototypePropTag(prop);
            if~contains(propTag,':')

                if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')

                    elem=getArchitectureInContext(elem);
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

                prototypeName=SysarchPrototypeHandler.extractTopTag(propTag);
                propName=SysarchPrototypeHandler.extractBottomTag(propTag);
                if strcmp(propName,'NoPropertiesDefined')
                    toolTip=DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions');
                else
                    if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')

                        elem=getArchitectureInContext(elem);
                    end
                    PU=SysarchPrototypeHandler.getPropUsage(elem,prototypeName,propName);
                    if~isempty(PU.propertyDef)
                        toolTip=PU.propertyDef.fullyQualifiedName;
                    else
                        toolTip=[PU.getName,DAStudio.message('SystemArchitecture:PropertyInspector:UnresolvedLabel')];
                    end

                    if elem.isPropValDefault([prototypeName,'.',propName])
                        toolTip=[toolTip,' ',DAStudio.message('SystemArchitecture:PropertyInspector:DefaultLabel')];
                    end
                end
            end
        end


        function prop=removeFakeProperty(fakeProp)







            idx=strfind(fakeProp,':');
            prop=fakeProp(1:idx(end)-1);
        end


        function err=setPropertyVal(elem,prop,newValue)
            err={};


            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler;
            propFullName=SysarchPrototypeHandler.stripPrototypePropTag(prop);
            if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
                elem=getArchitectureInContext(elem);
            end
            if~contains(propFullName,':')

                if strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:Remove'))
                    SysarchPrototypeHandler.performRemoveAction(elem,propFullName)
                end

                if strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:MakeDefault'))


                    stereoName=SysarchPrototypeHandler.stripPrototypePropTag(prop);
                    systemcomposer.internal.resetToDefaultValues(elem,stereoName);
                end
                if strcmp(newValue,DAStudio.message('SystemArchitecture:PropertyInspector:UnlinkParent'))
                    actualProto=elem.getPrototype.findobj('p_Name',propFullName);
                    SysarchPrototypeHandler.unlinkMissingParent(elem,actualProto);
                end
                return
            end
            propUsageTag=SysarchPrototypeHandler.extractBottomTag(propFullName);
            propType='';
            if contains(propUsageTag,':')

                propUsage=SysarchPrototypeHandler.extractTopTag(propUsageTag);
                propType=SysarchPrototypeHandler.extractBottomTag(propUsageTag);
            else
                propUsage=propUsageTag;
            end
            prototypeName=SysarchPrototypeHandler.extractTopTag(propFullName);
            PU=SysarchPrototypeHandler.getPropUsage(elem,prototypeName,propUsage);


            switch SysarchPrototypeHandler.getPropertyClass(PU)
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
                        unitsToSet='*';
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

        function hasSub=hasSubProperties(~,prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler
            if strcmp(prop,'Sysarch:Prototype')

                hasSub=false;
            else
                protoName=SysarchPrototypeHandler.stripPrototypePropTag(prop);
                if contains(protoName,':')

                    hasSub=false;
                else

                    hasSub=true;
                end
            end
        end

        function subprops=subProperties(elem,prop)
            subprops={};%#ok<NASGU>
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler
            if strcmp(prop,'Sysarch:Prototype')
                prototypeNames=elem.getPrototypeNames;



                idxToIgnore=find(arrayfun(SysarchPrototypeHandler.isPrototypeZC,prototypeNames));
                if~isempty(idxToIgnore)
                    prototypeNames(idxToIgnore)=[];
                end

                elemProtoName='';
                elemProto=elem.getElementPrototype;
                if~isempty(elemProto)
                    elemProtoName=elemProto.fullyQualifiedName;
                end
























                if~isempty(elemProtoName)
                    idxElemProto=ismember(prototypeNames,elemProtoName);
                    prototypeNames(idxElemProto)=[];
                end


                prototypeNames=horzcat(elemProtoName,...
                sort(prototypeNames));


                subprops=cellfun(@strcat,...
                repelem({'Sysarch:Prototype:'},numel(prototypeNames)),...
                prototypeNames,'UniformOutput',false);
            else

                currentPrototypeName=SysarchPrototypeHandler.stripPrototypePropTag(prop);
                subprops=SysarchPrototypeHandler.getSubPropertiesForPrototype(elem,currentPrototypeName);
            end
        end

        function result=propertyDisplayLabel(prop)

            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler
            propName=SysarchPrototypeHandler.stripPrototypePropTag(prop);
            if(contains(propName,':'))

                result=SysarchPrototypeHandler.extractBottomTag(propName);
                if strcmp(result,'NoPropertiesDefined')
                    result=DAStudio.message('SystemArchitecture:PropertyInspector:NoPropertyDefinitions');
                end
            else

                str=strsplit(propName,'.');
                result=str{2};
            end
        end

        function editor=propertyEditor(elem,prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler
            propName=SysarchPrototypeHandler.stripPrototypePropTag(prop);
            if~contains(propName,':')

                editor=DAStudio.UI.Widgets.ComboBox;
                editor.Entries={'',...
                DAStudio.message('SystemArchitecture:PropertyInspector:Remove'),...
                DAStudio.message('SystemArchitecture:PropertyInspector:MakeDefault')};
                editor.Index=0;
                actualProto=elem.getPrototype.findobj('p_Name',propName);
                if(~isempty(actualProto))
                    if(actualProto.hasMissingParent(true))
                        editor.Entries{end+1}=DAStudio.message('SystemArchitecture:PropertyInspector:UnlinkParent');
                    end
                end
                editor.Editable=false;
                return
            end

            if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
                elem=getArchitectureInContext(elem);
            end

            prototypeName=SysarchPrototypeHandler.extractTopTag(propName);
            propName=SysarchPrototypeHandler.extractBottomTag(propName);
            PU=SysarchPrototypeHandler.getPropUsage(elem,prototypeName,propName);
            propFullName=[prototypeName,'.',propName];
            propValue=elem.getPropVal(propFullName);

            if strcmp(SysarchPrototypeHandler.getPropertyClass(PU),'numeric')
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
                unitsBox.Editable=true;
                unitsBox.Tag=strcat(prop,':Unit');
                unitsBox.CurrentText=currentUnit;


                slTopModel=get_param(elem.getTopLevelArchitecture.getName,'Handle');
                isAUTOSARArchitectureModel=Simulink.internal.isArchitectureModel(slTopModel,'AUTOSARArchitecture');
                if isAUTOSARArchitectureModel
                    editor.Children={valueBox};
                else
                    editor.Children={valueBox,unitsBox};
                end

            elseif strcmp(SysarchPrototypeHandler.getPropertyClass(PU),'enumeration')
                editor=DAStudio.UI.Widgets.ComboBox;
                editor.Entries=PU.propertyDef.type.getLiteralsAsStrings;
                editor.Index=find(strcmp(eval(propValue.expression),editor.Entries),true,'first')-1;
            else
                editor=DAStudio.UI.Widgets.Edit;
                editor.Text=propValue.expression;
            end
        end

        function value=propertyValue(elem,prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler
            propFullName=SysarchPrototypeHandler.stripPrototypePropTag(prop);
            if contains(propFullName,':')
                propName=SysarchPrototypeHandler.extractBottomTag(propFullName);
                if strcmp(propName,'NoPropertiesDefined')
                    value='';
                    return
                end
                prototypeName=SysarchPrototypeHandler.extractTopTag(propFullName);
                propFullName=[prototypeName,'.',propName];

                propValue=elem.getPropVal(propFullName);
                PU=SysarchPrototypeHandler.getPropUsage(elem,prototypeName,propName);

                if strcmp(SysarchPrototypeHandler.getPropertyClass(PU),'numeric')
                    value=[propValue.expression,' ',propValue.units];
                elseif strcmp(SysarchPrototypeHandler.getPropertyClass(PU),'enumeration')

                    try


                        valObj=elem.getPropValObject(propFullName);
                        propValOriginal=eval('valObj.getValue');
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
                elseif strcmp(SysarchPrototypeHandler.getPropertyClass(PU),'unresolved')
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

        function mode=propertyRenderMode(comp,prop)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler
            propName=SysarchPrototypeHandler.stripPrototypePropTag(prop);
            if~contains(propName,':')
                mode='RenderAsComboBox';
                return;
            end

            prototypeName=SysarchPrototypeHandler.extractTopTag(propName);
            propUsage=SysarchPrototypeHandler.extractBottomTag(propName);

            if strcmp(propUsage,'NoPropertiesDefined')
                mode='RenderAsText';
                return
            end

            PU=SysarchPrototypeHandler.getPropUsage(comp,prototypeName,propUsage);

            if strcmp(SysarchPrototypeHandler.getPropertyClass(PU),'bool')
                mode='RenderAsCheckBox';
            elseif strcmp(SysarchPrototypeHandler.getPropertyClass(PU),'enumeration')
                mode='RenderAsComboBox';
            else
                mode='RenderAsText';
            end
        end

        function enabled=isPropertyEnabled(elem,prop,bdH,contextBdH)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler


            if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
                if(elem.isReferenceComponent&&~elem.isSubsystemReferenceComponent)||...
                    isa(elem,'systemcomposer.architecture.model.design.VariantComponent')||...
                    elem.isAdapterComponent
                    enabled=false;
                    return;
                end
                elem=getArchitectureInContext(elem);
            end



            if isa(elem,'systemcomposer.architecture.model.design.ArchitecturePort')
                if(bdH~=contextBdH)&&get_param(bdH,'blockdiagramtype')~="subsystem"
                    if(strcmpi(get_param(bdH,'SimulinkSubDomain'),'Architecture')||...
                        strcmpi(get_param(bdH,'SimulinkSubDomain'),'SoftwareArchitecture'))
                        enabled=false;
                        return;
                    end
                end

                owningArch=elem.getContainingArchitecture();
                if owningArch.isVariantArchitecture()
                    enabled=false;
                    return;
                end



                if owningArch.hasParentComponent
                    parentComp=owningArch.getParentComponent;
                    parentBlockH=systemcomposer.utils.getSimulinkPeer(parentComp);
                    if(parentBlockH&&ishandle(parentBlockH)&&...
                        systemcomposer.internal.isArchitectureLocked(parentBlockH))
                        enabled=false;
                        return;
                    end
                end
            end




            if isa(elem,'systemcomposer.architecture.model.design.Architecture')
                if elem.isVariantArchitecture()
                    enabled=false;
                    return;
                elseif~elem.hasParentComponent
                    zcModelImpl=systemcomposer.architecture.model.SystemComposerModel.getSystemComposerModel(mf.zero.getModel(elem));
                    if zcModelImpl.isProtectedModel
                        enabled=false;
                        return;
                    end
                elseif elem.hasParentComponent
                    parentComp=elem.getParentComponent;
                    parentBlockH=systemcomposer.utils.getSimulinkPeer(parentComp);
                    if(parentBlockH&&ishandle(parentBlockH)&&...
                        systemcomposer.internal.isArchitectureLocked(parentBlockH))
                        enabled=false;
                        return;
                    end
                end
            end

            propFullName=SysarchPrototypeHandler.stripPrototypePropTag(prop);
            propUsageTag=SysarchPrototypeHandler.extractBottomTag(propFullName);

            if isempty(propUsageTag)

                enabled=true;
            else

                prototypeName=SysarchPrototypeHandler.extractTopTag(propFullName);
                PU=SysarchPrototypeHandler.getPropUsage(elem,prototypeName,propUsageTag);
                if(~PU.isInSyncWithPropDef()||...
                    PU.propertySet.propertySet.prototype.hasMissingParent(true))

                    enabled=false;
                    return
                else
                    enabled=true;
                end
            end
        end

        function PU=getPropUsage(elem,protoName,propUsgName)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler



            if isa(elem,'systemcomposer.architecture.model.design.BaseComponent')
                elem=getArchitectureInContext(elem);
            end
            psu=elem.getPropertySet(protoName);
            PU=psu.getPropertyUsage(propUsgName);
            if isempty(PU)


                protoParent=psu.p_Parent;
                if~isempty(protoParent)
                    PU=SysarchPrototypeHandler.getPropUsage(elem,protoParent.getName,propUsgName);
                end
            end
        end

    end

    methods(Static,Access=private)

        function prop_class=getPropertyClass(propertyUsage)



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

        function result=hasPrototypeAttached(elem,psuName)
            protoNames=elem.getPrototypeNames();
            result=any(strcmp(protoNames,psuName));
        end

        function performRemoveAction(elem,prop)
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

        function unlinkMissingParent(elem,proto)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler;
            if(elem.hasUnresolvedProperties)
                confirm=systemcomposer.internal.arch.internal.propertyinspector.createFixAndUnlinkParentStereotypeDialog(proto.fullyQualifiedName,elem.getName);
                if strcmp(confirm,message('SystemArchitecture:PropertyInspector:ConfirmFixAndUnlink_Yes').string)
                    elem.removeAllBrokenProperties;
                    SysarchPrototypeHandler.doUnlinkMissingStereotypeParentInHierarchy(proto);
                end
            else
                confirm=systemcomposer.internal.arch.internal.propertyinspector.createUnlinkParentStereotypeDialog(proto.fullyQualifiedName);
                if strcmp(confirm,message('SystemArchitecture:PropertyInspector:ConfirmUnlink_Yes').string)
                    SysarchPrototypeHandler.doUnlinkMissingStereotypeParentInHierarchy(proto);
                end
            end
        end

        function doUnlinkMissingStereotypeParentInHierarchy(proto)
            import systemcomposer.internal.arch.internal.propertyinspector.SysarchPrototypeHandler;
            if(proto.hasMissingParent)
                proto.unlinkParent;
            else
                SysarchPrototypeHandler.doUnlinkMissingStereotypeParentInHierarchy(proto.parent);
            end
        end

        function props=getSubPropertiesForPrototype(elem,prototypeName)
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
                        foundProps{originalIdx+1}=['Sysarch:Prototype:',propSetUsage.getName,':',propDef.getName];%#ok<AGROW>, % prop defs are 0-indexed
                    else

                        missingProps{end+1}=['Sysarch:Prototype:',propSetUsage.getName,':',propUsage.getName];%#ok<AGROW>
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
                props={['Sysarch:Prototype:',prototypeName,':','NoPropertiesDefined']};
            end
        end
    end
end




function architecture=getArchitectureInContext(compOrArch)
    if isa(compOrArch,'systemcomposer.architecture.model.design.Architecture')
        component=compOrArch.getParentComponent;
        if isempty(component)


            architecture=compOrArch;
            return;
        end
    else
        component=compOrArch;
    end
    if component.isSubsystemReferenceComponent
        architecture=component.getOwnedArchitecture;
    else
        architecture=component.getArchitecture;
    end
end



