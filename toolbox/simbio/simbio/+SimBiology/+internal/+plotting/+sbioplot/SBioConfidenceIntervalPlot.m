classdef SBioConfidenceIntervalPlot<SimBiology.internal.plotting.sbioplot.SBioPlotObject




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.CONFIDENCE_INTERVAL;
        end
    end

    methods(Access=private)
        function flag=supportsProfileLikelihood(obj)
            flag=obj.definition.props.SupportsProfileLikelihood;
        end

        function setSupportsProfileLikelihood(obj,flag)
            set(obj.definition.props,'SupportsProfileLikelihood',flag);
        end

        function flag=getProfileLikelihood(obj)
            flag=strcmp(obj.definition.props.ProfileLikelihood,'curve');
        end

        function layoutOption=getLayout(obj)
            layoutOption=obj.definition.props.Layout;
        end
    end




    methods(Access=protected)
        function processAdditionalArguments(obj,definitionProps)
            obj.setSupportsProfileLikelihood(obj.getPlotArguments().supportsProfileLikelihood());


            set(obj.figure.props,'LinkedX',false,'LinkedY',false);
        end

        function setupAxes(obj)
            obj.resetFigure;
        end

        function createPlot(obj)
            if obj.getPlotArguments().isParameterConfidenceInterval()
                obj.createParameterCIPlot();
            else
                obj.createPredictionCIPlot();
            end


            set(obj.figure.handle,'SizeChangedFcn',@SimBiology.web.internal.PlotHandler.handleFigureSizeChange);

            obj.updateAxesFromFigure();
        end

        function format(obj)
            obj.formatForPreconfiguredPlots();
        end
    end

    methods(Access=private)
        function confidenceIntervalObj=getDataToPlot(obj)
            confidenceIntervalObj=obj.getPlotArguments().data.getConfidenceIntervalObject();
        end

        function createParameterCIPlot(obj)
            confidenceIntervalObj=obj.getDataToPlot();
            if obj.getProfileLikelihood
                confidenceIntervalObj.plot(obj.figure.handle,'ProfileLikelihood',true);
            else
                confidenceIntervalObj.plot(obj.figure.handle,'Layout',obj.getLayout());
            end
        end

        function createPredictionCIPlot(obj)
            confidenceIntervalObj=obj.getDataToPlot();
            confidenceIntervalObj.plot(obj.figure.handle);
        end
    end


    methods(Access=protected)
        function updateTrellisTickLabels(obj)

        end
    end


    methods(Access=protected)
        function flag=isObjectSupportedForDataTip(obj,h)
            flag=~isempty(h)&&~isa(h,'matlab.graphics.axis.Axes')&&isfield(struct(h),'UserData')&&isstruct(h.UserData);
        end

        function showDataTip(obj,h,dataSpaceCoordinates)
            datatip(h,dataSpaceCoordinates.x,dataSpaceCoordinates.y,'Interpreter','none');
            dataTipRows=dataTipTextRow(h.UserData.GroupLabel,[]);
            h.DataTipTemplate.DataTipRows=dataTipRows;
        end
    end
end