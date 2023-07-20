classdef GSAPlotDefinitionProps<SimBiology.internal.plotting.sbioplot.definition.DefinitionProps

    properties(Access=public)
        Parameters=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps.getDefaultUseStruct({});
        Observables=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps.getDefaultUseStruct({});
        MPGSAOptions=[];
        SobolOptions=[];
        EEOptions=[];
    end




    methods(Access=public)
        function obj=GSAPlotDefinitionProps(input)
            obj@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(input);


            if isempty(input)
                obj.MPGSAOptions=obj.getDefaultMPGSAOptions();
                obj.SobolOptions=obj.getDefaultSobolOptions();
                obj.EEOptions=obj.getDefaultEEOptions();
            end
        end

        function info=getStruct(obj)
            info=getStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj);
            info.Parameters=obj.Parameters;
            info.Observables=obj.Observables;
            info.MPGSAOptions=obj.MPGSAOptions;
            info.SobolOptions=obj.SobolOptions;
            info.EEOptions=obj.EEOptions;
        end
    end

    methods(Access=?SimBiology.internal.plotting.sbioplot.definition.DefinitionProps)
        function configureSingleObjectFromStruct(obj,input)
            configureSingleObjectFromStruct@SimBiology.internal.plotting.sbioplot.definition.DefinitionProps(obj,input);
            set(obj,'MPGSAOptions',input.MPGSAOptions);
            set(obj,'SobolOptions',input.SobolOptions);
            set(obj,'EEOptions',input.EEOptions);
            set(obj,'Parameters',obj.importUseStruct(input.Parameters));
            set(obj,'Observables',obj.importUseStruct(input.Observables));
            obj.MPGSAOptions.Classifiers=obj.importUseStruct(input.MPGSAOptions.Classifiers);
        end
    end

    methods(Access=public)
        function updateParameters(obj,names)
            obj.Parameters=obj.updateUseStruct(names,obj.Parameters);
        end

        function updateObservables(obj,names)
            obj.Observables=obj.updateUseStruct(names,obj.Observables);
        end

        function updateClassifiers(obj,names)
            obj.MPGSAOptions.Classifiers=obj.updateUseStruct(names,obj.MPGSAOptions.Classifiers);
        end
    end




    methods(Access=protected)
        function options=getDefaultMPGSAOptions(~)
            options=struct;
            options.Classifiers=SimBiology.internal.plotting.sbioplot.definition.DefinitionProps.getDefaultUseStruct({});

            colorOrder=SimBiology.internal.plotting.categorization.BinSettings.COLOR_ORDER();
            options.AcceptedSamplesColor=colorOrder{1};
            options.RejectedSamplesColor=colorOrder{2};
        end

        function options=getDefaultSobolOptions(~)
            options=struct;

            colorOrder=SimBiology.internal.plotting.categorization.BinSettings.COLOR_ORDER();
            options.FirstOrderColor=colorOrder{1};
            options.TotalOrderColor=colorOrder{2};
        end

        function options=getDefaultEEOptions(~)
            options=struct;

            colorOrder=SimBiology.internal.plotting.categorization.BinSettings.COLOR_ORDER();
            options.MeanColor=colorOrder{1};
            options.StandardDeviationColor=colorOrder{2};

            options.ShowMean=true;
            options.ShowStandardDeviation=true;
            options.UseAbsoluteEffects=[];
        end
    end
end