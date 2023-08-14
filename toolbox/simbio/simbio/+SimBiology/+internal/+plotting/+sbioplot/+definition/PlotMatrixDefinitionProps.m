classdef PlotMatrixDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.DefinitionProps

    properties(Access=public)
        SingleInput=false;
        XParameters=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps.getDefaultUseStruct({});
        YParameters=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps.getDefaultUseStruct({});
    end




    methods(Access=public)
        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj);
            info.SingleInput=obj.SingleInput;
            info.XParameters=obj.XParameters;
            info.YParameters=obj.YParameters;
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj,input);

            set(obj,'SingleInput',input.SingleInput,...
            'XParameters',obj.importUseStruct(input.XParameters),...
            'YParameters',obj.importUseStruct(input.YParameters));
        end
    end




    methods(Access=public)
        function updateParameters(obj,xParameterNames,yParameterNames)
            obj.updateFromParameterNames(xParameterNames,true);
            obj.updateFromParameterNames(yParameterNames,false);
        end
    end

    methods(Access=private)
        function updateFromParameterNames(obj,parameterNames,isX)
            if isX
                obj.XParameters=obj.updateUseStruct(parameterNames,obj.XParameters);
            else
                obj.YParameters=obj.updateUseStruct(parameterNames,obj.YParameters);
            end
        end
    end
end