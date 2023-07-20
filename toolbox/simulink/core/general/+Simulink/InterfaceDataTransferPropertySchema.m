classdef InterfaceDataTransferPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:DataViewDataTransfers');
        end
    end

    methods
        function this=InterfaceDataTransferPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(~,~)
            props={'Simulink:studio:DataViewPerspective_CodeGen'...
            };
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

                isVisible=false;
            elseif(strcmp(mappingType,'AutosarTarget')&&~isempty(modelMapping)&&~modelMapping.IsSubComponent)...
                ||(strcmp(mappingType,'CoderDictionary')&&...
                (modelMapping.isFunctionPlatform&&isequal(modelMapping.DeploymentType,'Component'))&&...
                slfeature('DataTransfersInCMapping')>0)
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
                [~,mappingType]=Simulink.CodeMapping.getCurrentMapping(model);
                if strcmp(mappingType,'AutosarTarget')
                    mc=metaclass(Simulink.AutosarTarget.InterRunnableVariable);
                    for ii=1:numel(mc.PropertyList)
                        prop=mc.PropertyList(ii);
                        if strcmp(prop.GetAccess,'public')&&~prop.Hidden
                            props{end+1}=prop.Name;%#ok<AGROW>
                        end
                    end
                elseif strcmp(mappingType,'CoderDictionary')
                    props{end+1}=DAStudio.message('coderdictionary:mapping:DataTransfersMode');
                end
            otherwise
                props={};
            end
        end
    end

end


