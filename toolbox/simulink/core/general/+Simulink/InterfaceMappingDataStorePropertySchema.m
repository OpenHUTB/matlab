classdef InterfaceMappingDataStorePropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:DataViewDataStores');
        end
    end

    methods
        function this=InterfaceMappingDataStorePropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(obj,panel)
            if strcmp(panel,'propertyInspector')
                names=obj.getStereotypeNames('DataStores');
                props={'Simulink:studio:DataViewPerspective_Design',...
                'Simulink:studio:DataViewPerspective_CodeGen',...
                'RTW:autosar:uiNvBlockNeedsTitle',...
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
            sid=obj.Source.getPropValue('BlockSID');
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
            if~isempty(modelMapping)
                if isempty(sid)
                    uuid=obj.Source.getPropValue('UUID');
                    if strcmp(mappingType,'AutosarTarget')
                        mappedDataStore=modelMapping.SynthesizedDataStores.findobj('UUID',uuid);
                    elseif strcmp(mappingType,'CoderDictionary')
                        mappedDataStore=modelMapping.SynthesizedLocalDataStores.findobj('UUID',uuid);
                    else

                        assert(false,['An empty block SID found for ',obj.Source.getPropValue('Source')])
                    end
                else
                    mappedDataStore=modelMapping.DataStores.findobj('BlockSID',sid);
                end
                if strcmp(perspective,'Simulink:studio:DataViewPerspective_CodeGen')
                    if strcmp(mappingType,'CoderDictionary')
                        if~isempty(mappedDataStore)&&~isempty(mappedDataStore.MappedTo)
                            props=mappedDataStore.MappedTo.getCSCAttributeNames(model)';
                        end
                    elseif strcmp(mappingType,'AutosarTarget')||strcmp(mappingType,'AutosarTargetCPP')
                        if~isempty(mappedDataStore)&&~isempty(mappedDataStore.MappedTo)
                            useLocalizedNames=true;
                            if strcmp(mappingType,'AutosarTarget')
                                props=[props...
                                ,autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(...
                                mappedDataStore,useLocalizedNames)];
                            elseif strcmp(mappingType,'AutosarTargetCPP')
                                props=[props...
                                ,autosar.api.getSimulinkMapping.getValidCodePerInstanceProperties(...
                                mappedDataStore,useLocalizedNames)];
                            end
                        end
                    end
                elseif strcmp(perspective,'RTW:autosar:CalibrationParametersTitle')
                    if strcmp(mappingType,'AutosarTarget')
                        if~isempty(mappedDataStore)&&~isempty(mappedDataStore.MappedTo)
                            useLocalizedNames=true;
                            props=[props...
                            ,autosar.api.getSimulinkMapping.getValidCalibrationPerInstanceProperties(...
                            mappedDataStore,useLocalizedNames)];
                        end
                    end
                elseif strcmp(perspective,'RTW:autosar:uiNvBlockNeedsTitle')
                    if strcmp(mappingType,'AutosarTarget')
                        if~isempty(mappedDataStore)&&~isempty(mappedDataStore.MappedTo)
                            useLocalizedNames=true;
                            if strcmp(mappedDataStore.MappedTo.ArDataRole,'ArTypedPerInstanceMemory')
                                if strcmp(obj.Source.getPropValue(DAStudio.message('RTW:autosar:uiNeedsNVRAMAccess')),'true')
                                    props=[props...
                                    ,autosar.api.getSimulinkMapping.getValidNvBlockNeedsPerInstanceProperties(...
                                    mappedDataStore,useLocalizedNames)];
                                end
                            end
                        end
                    end
                else
                    stereotypeNames=obj.getStereotypeNames('DataStores');
                    if any(strcmp(perspective,stereotypeNames))
                        if any(strcmp(mappingType,{'CoderDictionary','SimulinkCoderCTarget'}))
                            props=coder.internal.ProfileStereotypeUtils.getStereotypeProperties('Calibration',perspective,'getVisbleProps');
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
                model=obj.getOwnerGraphHandle();
            end
            [modelMapping,target]=Simulink.CodeMapping.getCurrentMapping(model);
            if strcmp(target,'AutosarTargetCPP')

                isVisible=true;
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
            if(contains(eventData.EventName,'DataStoreMappingEntity'))
                out=true;
            else
                out=false;
            end
        end

        function toolTip=propertyTooltip(obj,prop)
            if strcmp(prop,'RTW:autosar:CalibrationParametersTitle')
                toolTip=DAStudio.message('RTW:autosar:CalibrationParametersTitle');
            elseif strcmp(prop,'RTW:autosar:uiNvBlockNeedsTitle')
                toolTip=DAStudio.message('RTW:autosar:uiNvBlockNeedsTitle');
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
            props={};
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                if isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.m_Source.Handle);
                else
                    model=obj.getOwnerGraphHandle();
                    sid=obj.Source.getPropValue('BlockSID');
                    if~isempty(sid)

                        props{end+1}='Shared';
                    end
                end
                [mapping,target]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(target,'AutosarTarget')||strcmp(target,'AutosarTargetCPP')
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
                if~strcmp(obj.Source.getPropValue('BlockSID'),'')
                    props={};
                    props{end+1}='Shared';
                    props=[props,...
                    'Initial Value',...
                    'Data Type',...
                    'Min',...
                    'Max',...
                    'Dimensions',...
                    'Complexity',...
'Sample Time'
                    ];
                end
            otherwise
                props={};
            end
        end
    end

end



