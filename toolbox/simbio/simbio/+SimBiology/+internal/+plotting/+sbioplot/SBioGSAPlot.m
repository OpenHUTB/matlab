classdef SBioGSAPlot<SimBiology.internal.plotting.sbioplot.SBioPlotObject




    methods(Access=protected)
        function flag=isMPGSA(obj)
            flag=obj.getPlotArguments().isMPGSA();
        end

        function flag=isSobol(obj)
            flag=obj.getPlotArguments().isSobol();
        end

        function flag=isElementaryEffects(obj)
            flag=obj.getPlotArguments().isElementaryEffects();
        end

        function params=getParameters(obj)
            params=obj.definition.props.Parameters;
            idx=arrayfun(@(p)p.use,params);
            params=arrayfun(@(p)p.name,params(idx),'UniformOutput',false);
        end

        function observables=getObservables(obj)
            observables=obj.definition.props.Observables;
            idx=arrayfun(@(p)p.use,observables);
            observables=arrayfun(@(p)p.name,observables(idx),'UniformOutput',false);
        end

        function classifiers=getClassifiers(obj)
            classifiers=obj.definition.props.MPGSAOptions.Classifiers;
            idx=arrayfun(@(p)p.use,classifiers);
            classifiers=arrayfun(@(p)p.name,classifiers(idx),'UniformOutput',false);
        end

        function flag=getUseAbsoluteEffects(obj,gsaObj)
            flag=obj.definition.props.EEOptions.UseAbsoluteEffects;

            if isempty(flag)
                obj.definition.props.EEOptions.UseAbsoluteEffects=gsaObj.AbsoluteEffects;
                flag=gsaObj.AbsoluteEffects;
            end
        end
    end




    methods(Access=protected)
        function setPlotArguments(obj,plotArgs)

            if~isempty(plotArgs)&&plotArgs.isEmptyGSAResults()
                warning(message('SimBiology:Plotting:EMPTY_GSA_RESULTS'));
                plotArgs=SimBiology.internal.plotting.sbioplot.PlotArgument.empty;
            end
            setPlotArguments@SimBiology.internal.plotting.sbioplot.SBioPlotObject(obj,plotArgs);
        end

        function processAdditionalArguments(obj,definitionProps)
            parameterNames=obj.getPlotArguments().getParameterNames();
            obj.definition.props.updateParameters(parameterNames);

            observableNames=obj.getPlotArguments().getObservableNames();
            obj.definition.props.updateObservables(observableNames);

            if obj.isMPGSA()
                classifierNames=obj.getPlotArguments().getClassifierNames();
                obj.definition.props.updateClassifiers(classifierNames);
            end


            set(obj.figure.props,'LinkedX',false,'LinkedY',false);
        end

        function setupAxes(obj)
            obj.resetFigure;
        end

        function createPlot(obj)
            gsaObj=obj.getDataToPlot();
            if obj.isMPGSA()
                obj.createMPGSAPlot(gsaObj);
            elseif obj.isSobol()
                obj.createSobolPlot(gsaObj);
            elseif obj.isElementaryEffects()
                obj.createElementaryEffectsPlot(gsaObj);
            end


            legends=findobj(obj.figure.handle,'type','legend');
            delete(legends);

            obj.updateAxesFromFigure();
        end

        function format(obj)
            obj.formatForPreconfiguredPlots();
        end

        function gsaObj=getDataToPlot(obj)
            gsaObj=obj.getPlotArguments().data.getGSAObject();
        end

        function createMPGSAPlot(obj,gsaObj)

        end

        function createSobolPlot(obj,gsaObj)

        end

        function createElementaryEffectsPlot(obj,gsaObj)

        end
    end


    methods(Access=protected)
        function updateTrellisTickLabels(obj)

        end
    end




    methods(Access=protected)
        function[legendArray,dummyAxes]=getLegendArrayForExport(obj,destinationFigure)
            if obj.isMPGSA()
                [legendArray,dummyAxes]=obj.getLegendArrayForExportForMPGSA(destinationFigure);
            elseif obj.isSobol()
                [legendArray,dummyAxes]=obj.getLegendArrayForExportForSobol(destinationFigure);
            elseif obj.isElementaryEffects()
                [legendArray,dummyAxes]=obj.getLegendArrayForExportForElementaryEffects(destinationFigure);
            end
        end

        function[legendArray,dummyAxes]=getLegendArrayForExportForMPGSA(obj,destinationFigure)
            legendArray=matlab.graphics.illustration.Legend.empty;
            dummyAxes=matlab.graphics.axis.Axes.empty;
        end

        function[legendArray,dummyAxes]=getLegendArrayForExportForSobol(obj,destinationFigure)
            legendArray=matlab.graphics.illustration.Legend.empty;
            dummyAxes=matlab.graphics.axis.Axes.empty;
        end

        function[legendArray,dummyAxes]=getLegendArrayForExportForElementaryEffects(obj,destinationFigure)
            legendArray=matlab.graphics.illustration.Legend.empty;
            dummyAxes=matlab.graphics.axis.Axes.empty;
        end

        function[legendArray,dummyAxes]=getLegendArrayForExportHelper(obj,destinationFigure,name,createDummyLinesFunction)
            tiledLayoutObj=findobj(destinationFigure,'-depth',1,'type','tiledLayout');
            dummyAxes=axes(tiledLayoutObj,'Visible','off','Position',[.1,.1,.01,.01],'tag','dummyAxesForLegend');%#ok<CPROP,CPROPLC>
            dummyAxes.Toolbar.Visible='off';

            dummyLines=createDummyLinesFunction(dummyAxes);


            legendArray=legend(dummyLines,'tag','gsaPlotLegend');
            legendArray.Title.String=name;
            legendArray.Interpreter='none';
        end
    end
end