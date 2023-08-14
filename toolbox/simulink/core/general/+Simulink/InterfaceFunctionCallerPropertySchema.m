classdef InterfaceFunctionCallerPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:FunctionCallers');
        end
    end

    methods
        function this=InterfaceFunctionCallerPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(obj,~)
            props={'Simulink:studio:DataViewPerspective_CodeGen'...
            };
            if isa(obj.Source,'DataView')
                model=bdroot(obj.Source.m_Source.Handle);
            else
                model=bdroot(obj.Source.getForwardedObject.Handle);
            end
            [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
            if slfeature('AdaptiveMethodsTimeoutErrorHandling')&&...
                strcmp(mappingType,'AutosarTargetCPP')
                props{end+1}='RTW:autosar:uiQOSLabel';
            end
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={'Source',true};
        end
        function needsRefresh=needsRefreshForMappingChange(~,perspective)
            needsRefresh=false;
            if strcmp(perspective,DAStudio.message('Simulink:studio:DataViewPerspective_CodeGen'))
                needsRefresh=true;
            end
        end
        function isVisible=isTabVisible(obj,bd)%#ok<INUSL>
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(bd.Handle);
            if strcmp(mappingType,'AutosarTargetCPP')
                isVisible=true;
            elseif(strcmp(mappingType,'AutosarTarget')&&~isempty(modelMapping)&&~modelMapping.IsSubComponent)...
                ||(~strcmp(mappingType,'AutosarTarget')&&slfeature('FunctionCallersTabInCMappingUI')>0)
                isVisible=true;
            else
                isVisible=false;
            end
        end
        function out=needsRefresh(~,eventData)
            if(contains(eventData.EventName,'EPFMappingEntity'))
                out=true;
            else
                out=false;
            end
        end

        function toolTip=propertyTooltip(~,prop)
            if strcmp(prop,DAStudio.message('RTW:autosar:MethodTimeoutLabel'))
                toolTip=DAStudio.message('RTW:autosar:MethodTimeoutTooltip');
            elseif strcmp(prop,'RTW:autosar:uiQOSLabel')||...
                strcmp(prop,'Simulink:studio:DataViewPerspective_CodeGen')


                toolTip=DAStudio.message(prop);
            else
                toolTip=prop;
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
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                end
                [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
                if any(strcmp(mappingType,{'AutosarTarget','AutosarTargetCPP'}))
                    if strcmp(mappingType,'AutosarTarget')
                        mc=metaclass(Simulink.AutosarTarget.PortOperation);
                    elseif strcmp(mappingType,'AutosarTargetCPP')
                        mc=metaclass(Simulink.AutosarTarget.PortMethod);
                    end
                    for ii=1:numel(mc.PropertyList)
                        prop=mc.PropertyList(ii);
                        if strcmp(prop.GetAccess,'public')&&~prop.Hidden
                            props{end+1}=prop.Name;%#ok<AGROW>
                        end
                    end


                    props=setdiff(props,'Timeout','stable');
                    if slfeature('AUTOSARMethodsFireAndForgetMapping')&&...
                        strcmp(mappingType,'AutosarTargetCPP')
                        props{end+1}='FireAndForget';
                    end
                    if isa(obj.Source,'DataView')&&(slfeature('AdaptiveMethodsTimeoutErrorHandling'))&&...
                        strcmp(mappingType,'AutosarTargetCPP')

                        props{end+1}=obj.mappingInspectorColumnName;
                    end
                elseif strcmp(mappingType,'CoderDictionary')||strcmp(mappingType,'CppModelMapping')
                    props{end+1}=DAStudio.message('coderdictionary:mapping:FunctionNameColumnName');
                    props{end+1}=DAStudio.message('coderdictionary:mapping:FunctionClassColumnName');
                end
            case 'RTW:autosar:uiQOSLabel'
                assert(slfeature('AdaptiveMethodsTimeoutErrorHandling'),...
                'Expected feature to be on');
                props{end+1}=DAStudio.message('RTW:autosar:MethodTimeoutLabel');
            otherwise

            end
        end
    end

end


