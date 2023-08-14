classdef PercentileDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.CategoricalDefinitionProps




    methods(Static)
        function const=AUTO_TIMEPOINTS()
            const='auto';
        end

        function const=PERCENTILE()
            const='Percentiles';
        end

        function const=MEAN()
            const='Mean';
        end

        function const=RAWDATA()
            const='Raw Data';
        end
    end

    properties(Access=public)
        PercentilesOptions=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.getPercentilesOptions();
        MeanOptions=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionProps.getMeanOptions();
        DataOptions=SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions.empty;

    end




    methods(Access=public)
        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.CategoricalDefinitionProps(obj);
            info.PercentilesOptions=obj.PercentilesOptions;
            info.MeanOptions=obj.MeanOptions;
            info.DataOptions=obj.DataOptions.getStruct();
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.CategoricalDefinitionProps(obj,input);
            set(obj,'PercentilesOptions',input.PercentilesOptions);
            set(obj,'MeanOptions',input.MeanOptions);
            set(obj,'DataOptions',SimBiology.internal.plotting.sbioplot.definition.PercentileDefinitionPropsDataOptions(input.DataOptions));
        end
    end

    methods(Static,Access=private)
        function options=getPercentilesOptions()
            options=struct;
            options.Percentiles='5, 25, 75, 95';
            options.Median=true;
            options.Lines=false;
            options.Shading=true;
        end

        function options=getMeanOptions()
            options=struct;
            options.Mean=true;
            options.StandardDeviation=true;
            options.MinMax=false;
            options.Lines=false;
            options.Markers=true;
        end
    end

end