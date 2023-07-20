classdef SysarchStateflowBehaviorSchema<handle



    properties
        archSchema;
        chartSchema;
        source;
        handle;
    end

    methods
        function obj=SysarchStateflowBehaviorSchema(h)
            obj.source=h;
            obj.handle=sfprivate('chart2block',h.Id);
            slobject=get_param(obj.handle,'Object');
            obj.archSchema=systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema(slobject);
            obj.chartSchema=Stateflow.PropertyInspector.Chart(h);
        end
    end

    methods
        function s=getObjectName(obj)
            s='';
        end

        function s=getObjectType(obj)
            s=DAStudio.message('SystemArchitecture:PropertyInspector:Component');
        end

        function out=delegateToRelevantSchemaObject(obj,fcnName,propName)


            if isKey(obj.chartSchema.propNameToPropMap,propName)
                owner=obj.chartSchema;
            else
                owner=obj.archSchema;
            end
            out=feval(fcnName,owner,propName);
        end

        function out=setProperties(obj,fcnName,propName,varargin)


            if contains(propName,keys(obj.archSchema.PropertySpecMap))
                owner=obj.archSchema;
                out=feval(fcnName,owner,varargin{1});
            else
                owner=obj.chartSchema;
                out=feval(fcnName,owner,varargin{1},varargin{2});
            end
        end

        function hasSub=hasSubProperties(obj,propName)
            hasSub=obj.delegateToRelevantSchemaObject('hasSubProperties',propName);
        end

        function subpropNames=subProperties(obj,propName)
            if isempty(propName)

                ArchsubpropNames='Sysarch:root';
                ChartsubpropNames=obj.chartSchema.subProperties(propName);
                subpropNames=horzcat(ArchsubpropNames,ChartsubpropNames);
            else
                subpropNames=obj.delegateToRelevantSchemaObject('subProperties',propName);
            end
        end

        function label=propertyDisplayLabel(obj,propName)
            label=obj.delegateToRelevantSchemaObject('propertyDisplayLabel',propName);
        end

        function mode=propertyRenderMode(obj,propName)
            mode=obj.delegateToRelevantSchemaObject('propertyRenderMode',propName);
        end

        function enabled=isPropertyEnabled(obj,propName)
            enabled=obj.delegateToRelevantSchemaObject('isPropertyEnabled',propName);
        end

        function value=propertyValue(obj,propName)
            value=obj.delegateToRelevantSchemaObject('propertyValue',propName);
        end

        function error=setPropertyValues(obj,propNameValuePair,isBatchMode)
            propName=propNameValuePair{1};
            error=obj.setProperties('setPropertyValues',propName,propNameValuePair,isBatchMode);
        end

        function editor=propertyEditor(obj,propName)
            editor=obj.delegateToRelevantSchemaObject('propertyEditor',propName);
        end

        function out=supportTabView(~)
            out=true;
        end

        function out=rootNodeViewMode(obj,propName)
            out=obj.delegateToRelevantSchemaObject('rootNodeViewMode',propName);
        end

        function out=propertyTooltip(obj,propName)
            out=obj.delegateToRelevantSchemaObject('propertyTooltip',propName);
        end

        function out=implicityGroupPropertySet(~)
            out=true;
        end
    end

    methods(Static)
        function refreshPropertyInspector(handle)
            chartID=sfprivate('block2chart',handle);
            systemcomposer.internal.arch.internal.propertyinspector.SysarchPropertySchema.refresh(handle);
            Stateflow.PropertyInspector.SFObject.propertySetEvent(chartID);
        end
    end

end
