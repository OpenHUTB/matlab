classdef InterfaceMappingSignalPropertySchema<Simulink.InterfaceMappingPropertySchema





    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:DataViewSignalsStates');
        end
    end

    methods
        function this=InterfaceMappingSignalPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(obj,panel)
            if strcmp(panel,'propertyInspector')
                names=obj.getStereotypeNames('Signals');
                if(isa(obj.Source.getForwardedObject,'Simulink.Port'))

                    props={};
                    if(slfeature('ShowSignalDesignPropsOnMDE')>0)
                        props{end+1}='Simulink:studio:DataViewPerspective_Design';
                    end
                    if(slfeature('ShowComputedModelData')==3)
                        props{end+1}='Simulink:studio:DataViewPerspective_Computed';
                    end
                    props{end+1}='Simulink:studio:DataViewPerspective_CodeGen';
                    props{end+1}='RTW:autosar:CalibrationParametersTitle';
                else

                    props={'Simulink:studio:DataViewPerspective_Design',...
                    'Simulink:studio:DataViewPerspective_CodeGen',...
'RTW:autosar:CalibrationParametersTitle'...
                    };
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
            defaultSort={'Source',true};
        end
        function needsRefresh=needsRefreshForMappingChange(~,~)
            needsRefresh=true;
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
            if~isempty(modelMapping)
                blockSID=obj.Source.getPropValue('BlockSID');

                sid=obj.Source.getPropValue('BlockSID');
                identifier=str2double(obj.Source.getPropValue('StateIdentifier'));
                mappedStates=modelMapping.States.findobj('BlockSID',blockSID);
                for ii=1:numel(mappedStates)
                    mappedState=mappedStates(ii);
                    if mappedState.StateIdentifier==identifier
                        mappedState=modelMapping.States.findobj('BlockSID',sid);
                        if strcmp(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                            if strcmp(mappingType,'CoderDictionary')
                                if~isempty(mappedState)&&~isempty(mappedState.MappedTo)
                                    props=mappedState.MappedTo.getCSCAttributeNames(model)';
                                end
                            elseif strcmp(mappingType,'AutosarTarget')
                                if~isempty(mappedState)&&~isempty(mappedState.MappedTo)
                                    useLocalizedNames=true;
                                    props=autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(...
                                    mappedState,useLocalizedNames);
                                end
                            end
                        elseif strcmp(perspective,'RTW:autosar:CalibrationParametersTitle')
                            if strcmp(mappingType,'AutosarTarget')
                                if~isempty(mappedState)&&~isempty(mappedState.MappedTo)
                                    useLocalizedNames=true;
                                    props=...
                                    autosar.api.getSimulinkMapping.getValidCalibrationPerInstanceProperties(...
                                    mappedState,useLocalizedNames);
                                end
                            end
                        else
                            stereotypeNames=obj.getStereotypeNames('Signals');
                            if any(strcmp(perspective,stereotypeNames))
                                if any(strcmp(mappingType,{'CoderDictionary','SimulinkCoderCTarget'}))
                                    props=coder.internal.ProfileStereotypeUtils.getStereotypeProperties('Calibration',perspective,'getVisbleProps');
                                end
                            end
                        end
                    end
                    break;
                end

                portHandle=str2double(obj.Source.getPropValue('PortHandle'));
                mappedSignals=modelMapping.Signals.findobj('BlockSID',blockSID);
                for ii=1:numel(mappedSignals)
                    mappedSignal=mappedSignals(ii);
                    if mappedSignal.PortHandle==portHandle
                        if strcmp(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                            if strcmp(mappingType,'CoderDictionary')
                                if~isempty(mappedSignal.MappedTo)
                                    props=mappedSignal.MappedTo.getCSCAttributeNames(model)';
                                end
                            elseif strcmp(mappingType,'AutosarTarget')
                                if~isempty(mappedSignal)&&~isempty(mappedSignal.MappedTo)
                                    useLocalizedNames=true;
                                    props=autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(...
                                    mappedSignal,useLocalizedNames);
                                end
                            end
                        elseif strcmp(perspective,'RTW:autosar:CalibrationParametersTitle')
                            if strcmp(mappingType,'AutosarTarget')
                                if~isempty(mappedSignal)&&~isempty(mappedSignal.MappedTo)
                                    useLocalizedNames=true;
                                    props=...
                                    autosar.api.getSimulinkMapping.getValidCalibrationPerInstanceProperties(...
                                    mappedSignal,useLocalizedNames);
                                end
                            end
                        else
                            stereotypeNames=obj.getStereotypeNames('Signals');
                            if any(strcmp(perspective,stereotypeNames))
                                if any(strcmp(mappingType,{'CoderDictionary','SimulinkCoderCTarget'}))
                                    props=coder.internal.ProfileStereotypeUtils.getStereotypeProperties('Calibration',perspective,'getVisbleProps');
                                end
                            end
                        end
                        break;
                    end
                end
            end
        end

        function isVisible=isTabVisible(obj,~)
            isVisible=false;
            if isa(obj.Source,'DataView')
                model=bdroot(obj.Source.m_Source.Handle);
            else
                model=bdroot(obj.Source.getForwardedObject.Handle);
            end
            [modelMapping,target]=Simulink.CodeMapping.getCurrentMapping(model);
            if strcmp(target,'AutosarTargetCPP')

                isVisible=false;
            elseif strcmp(target,'AutosarTarget')&&~isempty(modelMapping)
                isVisible=true;
            elseif strcmp(target,'CoderDictionary')||strcmp(target,'SimulinkCoderCTarget')
                isVisible=true;
            end

        end

        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            isHierarchical=true;
        end

        function out=needsRefresh(~,eventData)
            if(contains(eventData.EventName,'SignalMappingEntity')...
                ||contains(eventData.EventName,'StateMappingEntity'))
                out=true;
            else
                out=false;
            end
        end

        function handleRemoveBtnClick(obj)
            if isa(obj.Source,'DataView')
                return;
            end

            ownerHandle=obj.Source.getForwardedObject.Handle;
            if strcmp(get_param(ownerHandle,'Type'),'port')


                obj.deleteEntry;
            end
        end

        function deleteEntry(obj,~)
            portHandle=obj.Source.getForwardedObject.Handle;
            model=get_param(bdroot(portHandle),'Name');
            simulinkcoder.internal.util.CanvasElementSelection.removeSignal(model,portHandle);
        end

        function toolTip=propertyTooltip(obj,prop)
            if strcmp(prop,'RTW:autosar:CalibrationParametersTitle')
                toolTip=DAStudio.message('RTW:autosar:CalibrationParametersTitle');
            else
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
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                if isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.m_Source.Handle);
                else
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                end
                [mapping,target]=Simulink.CodeMapping.getCurrentMapping(model);
                props={};
                if strcmp(target,'AutosarTarget')
                    props{end+1}=DAStudio.message('coderdictionary:mapping:MappedToColumnName');
                elseif strcmp(target,'CoderDictionary')||strcmp(target,'SimulinkCoderCTarget')
                    if strcmp(target,'CoderDictionary')&&mapping.isFunctionPlatform&&...
                        slfeature('DeploymentTypeInCMapping')==1
                        props{end+1}=DAStudio.message('coderdictionary:mapping:MeasurementServiceColumnName');
                    else
                        props{end+1}=DAStudio.message('coderdictionary:mapping:StorageClassColumnName');
                    end
                    if~isa(obj.Source,'DataView')

                        props{end+1}=DAStudio.message('coderdictionary:mapping:CodeIdentifierColumnName');
                    end
                end
                props{end+1}='Path';
                if isa(obj.Source,'DataView')

                    props{end+1}=obj.mappingInspectorColumnName;
                end
            case 'Simulink:studio:DataViewPerspective_Design'
                props={};
                if(isa(obj.Source,'Simulink.DataViewProxy')&&~isa(obj.Source.getForwardedObject,'Simulink.Port'))

                    props{end+1}='Initial Value';
                    if slfeature('StateRWForModelBlocks')>0&&slfeature('StateRWForMaskedSubsystem')<2
                        props{end+1}='Public';
                        props{end+1}='Public Name';
                    end
                    if slfeature('StateRWForMaskedSubsystem')==1
                        props{end+1}='Promote To Parent Subsystem';
                    elseif slfeature('StateRWForMaskedSubsystem')==2
                        props{end+1}='Promoted To';
                    end
                else

                    props={};
                    props=[props,...
                    'Data Type',...
                    'Min',...
                    'Max',...
                    'Dimensions',...
                    'Complexity',...
                    'Sample Time',...
                    ];
                end
            case 'Simulink:studio:DataViewPerspective_Computed'
                props={'Data Type  ',...
                'Min  ',...
                'Max  ',...
                'Dimensions  ',...
                'Complexity  ',...
                'Sample Time  ',...
                'Unit  ',...
                };
            otherwise
                props={};
            end
        end
    end

end




