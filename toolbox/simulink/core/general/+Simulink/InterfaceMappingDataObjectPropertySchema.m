classdef InterfaceMappingDataObjectPropertySchema<Simulink.InterfaceDataObjectPropertySchema





    properties(Access=protected)
    end

    methods(Static)
        function name=getTabName()
            name=DAStudio.message('Simulink:studio:DataViewDataObjects');
        end
    end

    methods
        function this=InterfaceMappingDataObjectPropertySchema(h,proxy)
            this@Simulink.InterfaceDataObjectPropertySchema(h,proxy);
        end

        function mode=rootNodeViewMode(~,~)
            mode='TreeView';
        end

        function props=getPerspectives(obj,viewType)
            props=getPerspectives@Simulink.InterfaceDataObjectPropertySchema(obj,viewType);
            if isequal(props{end},'Simulink:studio:DataViewPerspective_Other')
                props{end}='Simulink:studio:DataViewPerspective_CodeGen';
                props{end+1}='Simulink:studio:DataViewPerspective_Other';
            else
                props{end+1}='Simulink:studio:DataViewPerspective_CodeGen';
            end
        end

        function subprops=subProperties(obj,prop)
            subprops=subProperties@Simulink.InterfaceDataObjectPropertySchema(obj,prop);
        end

        function name=getObjectName(obj)
            name=getObjectName@Simulink.InterfaceDataObjectPropertySchema(obj);
        end

        function label=getObjectType(obj)
            label=getObjectType@Simulink.InterfaceDataObjectPropertySchema(obj);
        end

        function value=getPropValue(obj,prop)
            value=getPropValue@Simulink.InterfaceDataObjectPropertySchema(obj,prop);
        end

        function setPropValue(obj,prop,value)
            setPropValue@Simulink.InterfaceDataObjectPropertySchema(obj,prop,value);
        end

        function allowed=isCSBAllowed(~)
            allowed=true;
        end
        function defaultSort=getDefaultSort(~)

            defaultSort={' ',true};
        end
        function props=getPerInstanceProperties(obj,perspective)
            props=getPerInstanceProperties@Simulink.InterfaceDataObjectPropertySchema(obj,perspective);
        end
        function handleHelp(obj,perspective)
            handleHelp@Simulink.InterfaceDataObjectPropertySchema(obj,perspective);
        end
        function retVal=getContextMenu(obj,ssComponent,item)
            retVal=getContextMenu@Simulink.InterfaceDataObjectPropertySchema(obj,ssComponent,item);
        end

        function isHierarchical=useHierarchicalSpreadsheet(obj,arg1)
            isHierarchical=useHierarchicalSpreadsheet@Simulink.InterfaceDataObjectPropertySchema(obj,arg1);
        end

    end



    methods(Access=protected)

        function result=isRootNodeProperty(obj,prop)
            result=isRootNodeProperty@Simulink.InterfaceDataObjectPropertySchema(obj,prop);
        end

        function props=getCommonProperties(obj,perspective,includeHidden)
            props=getCommonProperties@Simulink.InterfaceDataObjectPropertySchema(obj,perspective,includeHidden);
        end

        function props=getPerspectiveProperties(obj,perspective,includeHidden)
            props=getPerspectiveProperties@Simulink.InterfaceDataObjectPropertySchema(obj,perspective,includeHidden);
        end
    end

end

