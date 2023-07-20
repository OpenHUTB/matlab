classdef GSATimeDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.GSAPlotDefinitionProps




    methods(Access=protected)
        function options=getDefaultSobolOptions(obj)
            options=getDefaultSobolOptions@SimBiology.internal.plotting.sbioplot.definition.GSAPlotDefinitionProps(obj);
            options.VarianceColor='#000000';
            options.DelimiterColor='#000000';
        end
    end
end