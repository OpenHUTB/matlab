classdef InterfaceMappingParameterPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:DataViewParameters');
        end
    end

    methods
        function this=InterfaceMappingParameterPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(obj,panel)
            if strcmp(panel,'propertyInspector')
                names=obj.getStereotypeNames('ModelParameters');
                props={'Simulink:studio:DataViewPerspective_Design',...
                'Simulink:studio:DataViewPerspective_CodeGen',...
                'RTW:autosar:CalibrationParametersTitle'};
                props=[props,names];
            else
                props={'Simulink:studio:DataViewPerspective_CodeGen'};
            end
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={'Source',true};
        end
        function needsRefresh=needsRefreshForMappingChange(~,~)
            needsRefresh=true;
        end
        function props=getPerInstanceProperties(obj,perspective)
            props={};
            if isa(obj.Source,'DataView')
                return;
            end

            model=obj.getOwnerGraphHandle();
            paramName=obj.Source.getPropValue('Source');
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
            if~isempty(modelMapping)
                mappedParam=modelMapping.ModelScopedParameters.findobj('Parameter',paramName);
                if~isempty(mappedParam)
                    if strcmp(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                        if strcmp(mappingType,'CoderDictionary')
                            if~isempty(mappedParam.MappedTo)
                                props=mappedParam.MappedTo.getCSCAttributeNames(model)';
                            end
                        elseif strcmp(mappingType,'AutosarTarget')
                            if~isempty(mappedParam.MappedTo)
                                useLocalizedNames=true;
                                props=[props...
                                ,autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(...
                                mappedParam,useLocalizedNames)];
                            end
                        end
                    elseif strcmp(perspective,'RTW:autosar:CalibrationParametersTitle')
                        if strcmp(mappingType,'AutosarTarget')
                            if~isempty(mappedParam.MappedTo)
                                useLocalizedNames=true;
                                props=[props...
                                ,autosar.api.getSimulinkMapping.getValidCalibrationPerInstanceProperties(...
                                mappedParam,useLocalizedNames)];
                            end
                        end
                    else
                        stereotypeNames=obj.getStereotypeNames('ModelParameters');
                        if any(strcmp(perspective,stereotypeNames))
                            if any(strcmp(mappingType,{'CoderDictionary','SimulinkCoderCTarget'}))
                                props=coder.internal.ProfileStereotypeUtils.getStereotypeProperties('Calibration',perspective,'getVisbleProps');
                            end
                        end
                    end
                end
            end
        end

        function isVisible=isTabVisible(obj,~)
            isVisible=false;
            if isa(obj.Source,'DataView')
                model=bdroot(obj.Source.m_Source.Handle);
            else
                model=obj.Source.getFullName;
            end
            [~,target]=Simulink.CodeMapping.getCurrentMapping(model);
            if strcmp(target,'AutosarTargetCPP')

                isVisible=false;
            elseif strcmp(target,'AutosarTarget')
                isVisible=true;
            elseif strcmp(target,'CoderDictionary')||strcmp(target,'SimulinkCoderCTarget')
                isVisible=true;
            end
        end

        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            isHierarchical=true;
        end

        function out=needsRefresh(~,eventData)
            if(contains(eventData.EventName,'ParameterMappingEntity'))
                out=true;
            else
                out=false;
            end
        end

        function handleRemoveBtnClick(obj)
            if isa(obj.Source,'DataView')
                return;
            end

            blockHandle=obj.Source.getForwardedObject.Handle;
            if strcmp(get_param(blockHandle,'Type'),'block')
                model=get_param(bdroot(blockHandle),'Name');
                fullName=obj.Source.getPropValue('Source');
                paramField=extractAfter(fullName,'::');
                simulinkcoder.internal.util.CanvasElementSelection.removeBlockParameter(model,blockHandle,paramField);
            end
        end

        function toolTip=propertyTooltip(obj,prop)
            if strcmp(prop,'RTW:autosar:CalibrationParametersTitle')
                toolTip=DAStudio.message('RTW:autosar:CalibrationParametersTitle');
            elseif strcmp(prop,DAStudio.message('RTW:autosar:SwAddrMethodProperty'))
                toolTip=DAStudio.message('RTW:autosar:SwAddrMethodForParameterDataTooltip');
            else
                toolTip=propertyTooltip@Simulink.InterfaceMappingPropertySchema(obj,prop);
            end
        end
    end


    methods(Access=protected)

        function props=getCommonProperties(~,~,includeHidden)
            props={};
            props{end+1}='Source';
            if((slfeature('BlockParameterConfiguration')>0)&&...
                (slfeature('BlockParameterConfiguration')<5))
                props{end+1}='Name';
            end
            if includeHidden
                props{end+1}='Path';
                props{end+1}='Description';
            end
        end
        function props=getPerspectiveProperties(obj,perspective,~)
            props={};
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                if isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.m_Source.Handle);
                else
                    model=obj.getOwnerGraphHandle();
                    props{end+1}='Argument';
                end
                [mapping,target]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(target,'AutosarTarget')
                    props{end+1}=DAStudio.message('coderdictionary:mapping:MappedToColumnName');
                elseif strcmp(target,'CoderDictionary')||strcmp(target,'SimulinkCoderCTarget')
                    if strcmp(target,'CoderDictionary')&&mapping.isFunctionPlatform&&...
                        slfeature('DeploymentTypeInCMapping')==1
                        props{end+1}=DAStudio.message('coderdictionary:mapping:ParameterServiceColumnName');
                    else
                        props{end+1}=DAStudio.message('coderdictionary:mapping:StorageClassColumnName');
                    end
                    if~isa(obj.Source,'DataView')

                        props{end+1}=DAStudio.message('coderdictionary:mapping:CodeIdentifierColumnName');
                    end
                end
                if isa(obj.Source,'DataView')

                    props{end+1}=obj.mappingInspectorColumnName;
                end
            case 'Simulink:studio:DataViewPerspective_Design'
                props={'Value',...
                'Data Type',...
                'Min',...
                'Max',...
                'Dimensions',...
                'Unit',...
                'Argument',...
                };
            otherwise
                props={};
            end
        end
    end

end


