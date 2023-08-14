classdef GSABarDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.GSAPlotDefinitionProps




    methods(Access=protected)
        function options=getDefaultMPGSAOptions(obj)
            options=getDefaultMPGSAOptions@SimBiology.internal.plotting.sbioplot.definition.GSAPlotDefinitionProps(obj);

            colorOrder=SimBiology.internal.plotting.categorization.BinSettings.COLOR_ORDER();
            options.KStatColor=colorOrder{1};
            options.PValueColor='#808080';
        end
    end
end