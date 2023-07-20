classdef InterfaceLookupPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:LookupTables');
        end
    end

    methods
        function this=InterfaceLookupPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,~)
            props={'Simulink:studio:DataViewPerspective_CodeGen'};
        end
        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)
            defaultSort={' ',true};
        end
        function needsRefresh=needsRefreshForMappingChange(~,perspective)
            needsRefresh=false;
            if strcmp(perspective,DAStudio.message('Simulink:studio:DataViewPerspective_CodeGen'))
                needsRefresh=true;
            end
        end
        function props=getPerInstanceProperties(~,~)
            props={};
        end
        function isVisible=isTabVisible(obj,bd)%#ok<INUSL>
            [modelMapping,mappingType]=Simulink.CodeMapping.getCurrentMapping(bd.Handle);
            if strcmp(mappingType,'AutosarTargetCPP')

                isVisible=false;
            elseif strcmp(mappingType,'AutosarTarget')&&~isempty(modelMapping)&&~modelMapping.IsSubComponent
                isVisible=true;
            else
                isVisible=false;
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
                props={};
                if isa(obj.Source,'DataView')
                    model=bdroot(obj.Source.m_Source.Handle);
                else
                    model=bdroot(obj.Source.getForwardedObject.Handle);
                end
                [~,target]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(target,'AutosarTarget')
                    mc=metaclass(Simulink.AutosarTarget.ARParameter);
                    for ii=1:numel(mc.PropertyList)
                        prop=mc.PropertyList(ii);
                        if strcmp(prop.GetAccess,'public')&&~prop.Hidden
                            props{end+1}=prop.Name;%#ok<AGROW>
                        end
                    end
                end
            otherwise
                props={};
            end
        end
    end

end


