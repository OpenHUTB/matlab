classdef InterfaceFunctionsSettingsPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:FunctionsDefaultsSettings');
        end
    end

    methods
        function this=InterfaceFunctionsSettingsPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,~)
            props={'Simulink:studio:DataViewPerspective_CodeGen'};
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={'Name',true};
        end
        function needsRefresh=needsRefreshForMappingChange(~,~)
            needsRefresh=false;
        end
        function isVisible=isTabVisible(obj,bd)%#ok<INUSL>
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(bd.Handle);
            if strcmp(mappingType,'CoderDictionary')&&...
                ~modelMapping.isFunctionPlatform
                if slfeature('DefaultsSSInCMapping')==1
                    if strcmp(obj.Source.m_ssComponent.ID,'GLUE2:SpreadSheet/CodeProperties')
                        isVisible=false;
                    elseif strcmp(obj.Source.m_ssComponent.ID,'GLUE2:SpreadSheet/DefaultsProperties')
                        isVisible=true;
                    end
                else
                    isVisible=true;
                end
            else
                isVisible=false;
            end
        end
        function handleHelp(~,~)
            helpview(fullfile(docroot,'ecoder','helptargets.map'),'code_mappings');
        end
    end


    methods(Access=protected)

        function props=getCommonProperties(~,~,~)
            props={DAStudio.message('coderdictionary:mapping:FunctionCategoryColumnName')};
        end

        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                props={};
                if isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.m_Source.Handle);
                else
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                end
                [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(mappingType,'CoderDictionary')
                    props=[props,...
                    DAStudio.message('coderdictionary:mapping:FunctionClassColumnName')];
                    if~isa(obj.Source,'DataView')

                        props=[props,...
                        DAStudio.message('coderdictionary:mapping:MemorySectionColumnName')];
                    end
                end
                if isa(obj.Source,'DataView')

                    props{end+1}=obj.mappingInspectorColumnName;
                end
            otherwise
                props={};
            end
        end
    end

end


