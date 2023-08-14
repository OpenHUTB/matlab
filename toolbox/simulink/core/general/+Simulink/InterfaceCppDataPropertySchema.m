classdef InterfaceCppDataPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:CppDataSettings');
        end
    end

    methods
        function this=InterfaceCppDataPropertySchema(h)
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
        function isHierarchical=useHierarchicalSpreadsheet(~,~)
            isHierarchical=true;
        end
        function needsRefresh=needsRefreshForMappingChange(~,~)
            needsRefresh=false;
        end
        function isVisible=isTabVisible(obj,bd)%#ok<INUSL>
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(bd.Handle);
            if strcmp(mappingType,'CppModelMapping')&&...
                (modelMapping.DeploymentType=="Unset"||...
                modelMapping.DeploymentType=="Component"||...
                modelMapping.DeploymentType=="Subcomponent")
                isVisible=true;
            else
                isVisible=false;
            end
        end

        function handleHelp(~,~)
            helpview(fullfile(docroot,'ecoder','helptargets.map'),'cpp_code_mappings_data');
        end
    end


    methods(Access=protected)

        function props=getCommonProperties(~,~,~)
            props={DAStudio.message('coderdictionary:mapping:DataCategoryColumnName')};
        end

        function props=getPerspectiveProperties(obj,perspective,~)
            switch(perspective)
            case 'Simulink:studio:DataViewPerspective_CodeGen'
                props={};
                if~isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                else
                    model=bdroot(obj.Source.m_Source.Handle);
                end
                [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(mappingType,'CppModelMapping')
                    props=[props,...
                    DAStudio.message('coderdictionary:mapping:CppMethodVisibilityColumnName'),...
                    DAStudio.message('coderdictionary:mapping:CppAccessColumnName')];
                end
                if~isa(obj.Source,'DataView')
                    props=[props,...
                    DAStudio.message('coderdictionary:mapping:CppDataPropertyKind')];
                else

                    props{end+1}=obj.mappingInspectorColumnName;
                end
            otherwise
                props={};
            end
        end
    end

end


