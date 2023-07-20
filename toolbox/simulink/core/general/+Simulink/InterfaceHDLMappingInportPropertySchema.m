classdef InterfaceHDLMappingInportPropertySchema<Simulink.InterfaceMappingPropertySchema






    methods(Static)
        function name=getTabName()
            name=DAStudio.message('coderdictionary:mapping:DataViewInports');
        end
    end

    methods
        function this=InterfaceHDLMappingInportPropertySchema(h)
            this.Source=h;
        end

        function props=getPerspectives(obj,panel)
            if strcmp(panel,'propertyInspector')
                names=obj.getStereotypeNames('Inports');
                props={'Simulink:studio:DataViewPerspective_Design',...
                'Simulink:studio:DataViewPerspective_CodeGen'};
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
            if strcmp(perspective,'Simulink:studio:DataViewPerspective_CodeGen')

                props=hdlcoder.mapping.internal.ui.getPerInstancePropertyList(blockH,0);
            end
        end
        function isVisible=isTabVisible(~,~)%#ok<INUSL>
            if slfeature('HDLTargetModelMapping')
                isVisible=true;
            else
                isVisible=false;
            end

        end
        function out=needsRefresh(~,eventData)
            if(contains(eventData.EventName,'InportMappingEntity'))
                out=true;
            else
                out=false;
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
                if slfeature('HDLTargetModelMapping')>0
                    mmgr=get_param(model,'MappingManager');
                    hm=mmgr.getActiveMappingFor('HDLTarget');
                    if contains(hm.Name,'HDLTarget')
                        props{end+1}=DAStudio.message('codemapping_hdl:mapping:InterfaceLabel');
                        props{end+1}=DAStudio.message('codemapping_hdl:mapping:InterfaceElementLabel');
                    end
                end
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
            otherwise
                props={};
            end
        end
    end

end



