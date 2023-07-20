classdef InterfaceMappingStatePropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('Simulink:studio:DataViewStates');
        end
    end

    methods
        function this=InterfaceMappingStatePropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,~)
            props={'Simulink:studio:DataViewPerspective_CodeGen',...
            'RTW:autosar:CalibrationParametersTitle'};
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
            sid=obj.Source.getPropValue('BlockSID');
            identifier=str2double(obj.Source.getPropValue('StateIdentifier'));
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
            if~isempty(modelMapping)
                mappedStates=modelMapping.States.findobj('BlockSID',sid);
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
                        end
                    end
                    break;
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
            elseif strcmp(target,'CoderDictionary')
                isVisible=true;
            end
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
            props={'Source','Name'};
        end
        function props=getPerspectiveProperties(obj,perspective,~)
            props={};
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                if isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.m_Source.Handle);
                else
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                end
                [~,target]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(target,'AutosarTarget')
                    props{end+1}=DAStudio.message('coderdictionary:mapping:MappedToColumnName');
                elseif strcmp(target,'CoderDictionary')
                    props{end+1}=DAStudio.message('coderdictionary:mapping:StorageClassColumnName');
                    if~isa(obj.Source,'DataView')

                        props{end+1}=DAStudio.message('coderdictionary:mapping:CodeIdentifierColumnName');
                    end
                end
                props{end+1}='Path';
            otherwise
                props={};
            end
        end
    end

end


