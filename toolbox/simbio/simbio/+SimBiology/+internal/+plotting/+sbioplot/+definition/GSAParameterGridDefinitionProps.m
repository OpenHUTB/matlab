classdef GSAParameterGridDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.GSAPlotDefinitionProps




    methods(Access=protected)
        function options=getDefaultEEOptions(obj)
            options=getDefaultEEOptions@SimBiology.internal.plotting.sbioplot.definition.GSAPlotDefinitionProps(obj);
            options.GridColor='#0072BD';
        end
    end
end