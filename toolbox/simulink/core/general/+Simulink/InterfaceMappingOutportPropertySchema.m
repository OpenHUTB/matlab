classdef InterfaceMappingOutportPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:DataViewOutports');
        end
    end

    methods
        function this=InterfaceMappingOutportPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(obj,panel)
            if strcmp(panel,'propertyInspector')
                names=obj.getStereotypeNames('Outports');
                props={'Simulink:studio:DataViewPerspective_Design',...
                'Simulink:studio:DataViewPerspective_CodeGen'};
                [~,target]=Simulink.CodeMapping.getCurrentMapping(obj.getOwnerGraphHandle);
                if any(strcmp(target,{'AutosarTarget','AutosarTargetCPP'}))
                    props{end+1}='RTW:autosar:uiComSpecTitleSpreadsheet';
                    props{end+1}='RTW:autosar:CalibrationParametersTitle';
                end
                props=[props,names];
            else
                props={'Simulink:studio:DataViewPerspective_CodeGen'};
            end
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={' ',true};
        end
        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            isHierarchical=true;
        end
        function needsRefresh=needsRefreshForMappingChange(~,perspective)
            needsRefresh=false;
            if strcmp(perspective,DAStudio.message('Simulink:studio:DataViewPerspective_CodeGen'))
                needsRefresh=true;
            end
        end
        function props=getPerInstanceProperties(obj,perspective)
            props={};
            if isa(obj.Source,'DataView')
                return;
            else
                blockH=obj.Source.getForwardedObject.Handle;
            end
            model=bdroot(blockH);
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
            if strcmp(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                if~isempty(modelMapping)&&strcmp(mappingType,'CoderDictionary')
                    mappedPort=Simulink.CodeMapping.getBlockMapping(...
                    modelMapping,'Outports',model,blockH);
                    if~isempty(mappedPort.MappedTo)
                        props=mappedPort.MappedTo.getCSCAttributeNames(model)';
                    end
                elseif~isempty(modelMapping)&&strcmp(mappingType,'CppModelMapping')
                    mappedPort=Simulink.CodeMapping.getBlockMapping(...
                    modelMapping,'Outports',model,blockH);
                    mappedTo=mappedPort.MessageCustomizationKind;
                    if(strcmp(mappedTo,'POSIX Message'))
                        props{end+1}=DAStudio.message('coderdictionary:mapping:PriorityLabel');
                    end
                end
            else
                stereotypeNames=obj.getStereotypeNames('Outports');
                if any(strcmp(perspective,stereotypeNames))
                    if any(strcmp(mappingType,{'CoderDictionary','SimulinkCoderCTarget'}))
                        props=coder.internal.ProfileStereotypeUtils.getStereotypeProperties('Calibration',perspective,'getVisbleProps');
                    end
                end
            end
        end
        function isVisible=isTabVisible(obj,bd)%#ok<INUSL>
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(bd.Handle);
            if(strcmp(mappingType,'AutosarTarget')&&~isempty(modelMapping)&&~modelMapping.IsSubComponent)...
                ||(strcmp(mappingType,'CoderDictionary')&&(~modelMapping.isFunctionPlatform||~isequal(modelMapping.DeploymentType,'Subcomponent')))...
                ||strcmp(mappingType,'SimulinkCoderCTarget')...
                &&~Simulink.CodeMapping.isSLRealTimeCompliant(bd.Handle)...
                ||strcmp(mappingType,'AutosarTargetCPP')...
                ||(strcmp(mappingType,'CppModelMapping')&&slfeature('CppIOCustomization')>0&&isequal(modelMapping.DeploymentType,'Application'))
                isVisible=true;
            else
                isVisible=false;
            end
        end
        function out=needsRefresh(~,eventData)
            if(contains(eventData.EventName,'OutportMappingEntity'))
                out=true;
            else
                out=false;
            end
        end

        function toolTip=propertyTooltip(obj,prop)
            switch prop
            case 'RTW:autosar:uiComSpecTitleSpreadsheet'
                toolTip=DAStudio.message('RTW:autosar:uiComSpecTitleSpreadsheet');
            case 'RTW:autosar:CalibrationParametersTitle'
                toolTip=DAStudio.message('RTW:autosar:CalibrationParametersTitle');
            case DAStudio.message('RTW:autosar:ArLongNameProperty')
                toolTip=DAStudio.message('RTW:autosar:ArLongNameTooltip');
            otherwise
                toolTip=propertyTooltip@Simulink.InterfaceMappingPropertySchema(obj,prop);
            end
        end
    end


    methods(Access=protected)

        function props=getCommonProperties(~,~,~)
            props={'Source'};
        end
        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_Design'
                props={
                'Data Type',...
                'Min',...
                'Max',...
                'Dimensions',...
                'Complexity',...
                'Sample Time',...
                'Unit',...
                };
                props=obj.addResolveProperty(props);
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                props={};
                if isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.m_Source.Handle);
                else
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                end
                [mapping,target]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(target,'CoderDictionary')||strcmp(target,'SimulinkCoderCTarget')
                    if strcmp(target,'CoderDictionary')&&mapping.isFunctionPlatform&&...
                        slfeature('DeploymentTypeInCMapping')==1
                        props{end+1}=DAStudio.message('coderdictionary:mapping:WriteServiceColumnName');
                    else
                        props{end+1}=DAStudio.message('coderdictionary:mapping:StorageClassColumnName');
                    end
                    if~isa(obj.Source,'DataView')

                        props{end+1}=DAStudio.message('coderdictionary:mapping:CodeIdentifierColumnName');
                    end
                elseif strcmp(target,'CppModelMapping')
                    if slfeature('CppIOCustomization')==1
                        props{end+1}=DAStudio.message('coderdictionary:mapping:TopicLabel');
                        props{end+1}=DAStudio.message('coderdictionary:mapping:WriterXMLTagLabel');
                        props{end+1}=DAStudio.message('coderdictionary:mapping:WriterQoSLabel');
                    elseif slfeature('CppIOCustomization')==2
                        props{end+1}=DAStudio.message('coderdictionary:mapping:MessageQueueNameLabel');
                        props{end+1}=DAStudio.message('coderdictionary:mapping:MaxMsgNumLabel');
                    end
                else
                    if strcmp(target,'AutosarTargetCPP')
                        mc=metaclass(Simulink.AutosarTarget.PortProvidedEvent);
                    elseif strcmp(target,'AutosarTarget')
                        mc=metaclass(Simulink.AutosarTarget.PortElement);
                    end
                    for ii=1:numel(mc.PropertyList)
                        prop=mc.PropertyList(ii);
                        if strcmp(prop.GetAccess,'public')&&~prop.Hidden
                            props{end+1}=prop.Name;%#ok<AGROW>
                        end
                    end
                end
                if isa(obj.Source,'Simulink.DataViewProxy')
                    props=obj.addResolveProperty(props);
                elseif isa(obj.Source,'DataView')&&~strcmp(target,'CppModelMapping')

                    props{end+1}=obj.mappingInspectorColumnName;
                end
            case 'RTW:autosar:uiComSpecTitleSpreadsheet'
                props={};
                if isa(obj.Source,'DataView')
                    port=obj.Source.m_Source;
                    model=bdroot(port.Handle);
                else
                    port=obj.Source.getForwardedObject();
                    model=bdroot(port.Handle);
                end
                [~,target]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(target,'AutosarTargetCPP')

                    return;
                elseif strcmp(target,'AutosarTarget')
                    m3iModel=autosar.api.Utils.m3iModel(model,showProgressBar=true);
                    props=...
                    autosar.ui.comspec.ComSpecPropertyHandler.getValidComSpecPropertiesForPort(...
                    model,port.Name,false,m3iModel);
                end
            case 'RTW:autosar:CalibrationParametersTitle'
                props={};
                if isa(obj.Source,'DataView')
                    port=obj.Source.m_Source;
                    model=bdroot(port.Handle);
                else
                    port=obj.Source.getForwardedObject();
                    model=bdroot(port.Handle);
                end
                [~,target]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(target,'AutosarTarget')||strcmp(target,'AutosarTargetCPP')
                    isInport=false;
                    props=...
                    autosar.ui.codemapping.PortCalibrationAttributeHandler.getValidCalibrationAttributesForPort(...
                    model,port.Name,isInport);
                end
            otherwise
                props={};
            end
        end
    end

end



