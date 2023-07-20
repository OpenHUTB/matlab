classdef SBioSensitivityPlot<SimBiology.internal.plotting.sbioplot.SBioPlotObject

    properties(Access=private)
        inputStrings={};
        outputStrings={};
    end




    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.SENSITIVITY;
        end
    end

    methods(Access=private)
        function numberOfFactors=getNumberOfInputs(obj)
            numberOfFactors=numel(obj.inputStrings);
        end

        function numberOfFactors=getNumberOfOutputs(obj)
            numberOfFactors=numel(obj.outputStrings);
        end
    end




    methods(Access=protected)
        function setPlotArguments(obj,plotArgs)
            if plotArgs.supportsSensitivities()
                setPlotArguments@SimBiology.internal.plotting.sbioplot.SBioPlotObject(obj,plotArgs);
            else
                setPlotArguments@SimBiology.internal.plotting.sbioplot.SBioPlotObject(obj,SimBiology.internal.plotting.sbioplot.PlotArgument.empty);
            end
        end

        function setupAxes(obj)
            obj.numTrellisCols=1;
            obj.numTrellisRows=1;
            obj.figure.props.Column=obj.numTrellisCols;
            obj.figure.props.Row=obj.numTrellisRows;
            obj.resetAxes();
        end

        function createPlot(obj)

            warningState=warning('off','MATLAB:ui:javaframe:PropertyToBeRemoved');
            cleanupObj=onCleanup(@()warning(warningState));

            results=getDataToPlot(obj);

            ax=obj.axes.handle;
            lineWidth=get(ax,'LineWidth');

            numInputs=obj.getNumberOfInputs();
            numOutputs=obj.getNumberOfOutputs();
            if numInputs==1&&numOutputs>1
                obj.createHorizontalBarPlot(results,ax);
            elseif numOutputs==1
                obj.createVerticalBarPlot(results,ax);
            else
                obj.create3DBarPlot(results,ax);
            end

            obj.restoreAxesSettings(ax,lineWidth);

            obj.addUserDataToAxes(ax);
        end

        function label(obj)
            if~obj.preserveLabels
                obj.resetLabels();

                numInputs=obj.getNumberOfInputs();
                numOutputs=obj.getNumberOfOutputs();
                if numInputs==1&&numOutputs>1
                    obj.labelHorizontalBarPlot();
                elseif numOutputs==1
                    obj.labelVerticalBarPlot();
                else
                    obj.label3DBarPlot();
                end
            end
        end

        function layout(obj)
            layout@SimBiology.internal.plotting.sbioplot.SBioPlotObject(obj);

            drawnow;
        end
    end

    methods(Access=private)
        function result=getDataToPlot(obj)
            [result,obj.inputStrings,obj.outputStrings]=getIntegratedSensitivities(obj.getPlotArguments(),obj.getProps().Inputs,obj.getProps().Outputs);
        end

        function createHorizontalBarPlot(obj,result,ax)
            barh(ax,result);


            set(ax,'ytick',1:obj.getNumberOfOutputs());
            set(ax,'yticklabel',obj.outputStrings);
        end

        function labelHorizontalBarPlot(obj)
            obj.axes.setProperty('XLabel',sprintf('Sensitivity relative to %s',obj.inputStrings{1}));
        end

        function createVerticalBarPlot(obj,result,ax)
            bar(ax,result);


            set(ax,'xtick',1:obj.getNumberOfInputs());
            set(ax,'xticklabel',obj.inputStrings);

        end

        function labelVerticalBarPlot(obj)
            obj.axes.setProperty('YLabel',sprintf('Sensitivity of %s',obj.outputStrings{1}));
        end

        function create3DBarPlot(obj,result,ax)

            allBars=bar3(ax,result);
            view(ax,2);

            set(ax,'PlotBoxAspectRatioMode','auto')
            set(obj.figure.handle,'Renderer','zbuffer')


            set(ax,'xtick',1:obj.getNumberOfInputs());
            set(ax,'xticklabel',obj.inputStrings);

            set(ax,'ytick',1:obj.getNumberOfOutputs());
            set(ax,'yticklabel',obj.outputStrings);


            for j=1:length(allBars)
                zd=get(allBars(j),'zdata');
                for i=1:6:size(zd,1)
                    zd(i+[0,3,4],2:3)=zd(i+1,2);
                    zd(i+[1,2],[1,4])=zd(i+1,2);
                end
                set(allBars(j),'cdata',zd);
            end

            colorbar(ax);
        end

        function label3DBarPlot(obj)
            obj.axes.setProperty('XLabel','Inputs');
            obj.axes.setProperty('YLabel','Outputs');
        end

        function restoreAxesSettings(obj,ax,lineWidth)


            set(ax,'TickLabelInterpreter','none');
            set(ax,'LineWidth',lineWidth);
            set(ax,'XLimMode','auto');
            set(ax,'YLimMode','auto');
        end

        function addUserDataToAxes(obj,ax)


            sensOptions=struct;
            sensOptions.Inputs=obj.inputStrings;
            sensOptions.Outputs=obj.outputStrings;

            if isempty(ax.UserData)||~isstruct(ax.UserData)
                ax.UserData=struct('SensitivityArgs',sensOptions);
            else
                ax.UserData.SensitivityArgs=sensOptions;
            end
        end
    end


    methods(Access=protected)
        function updateTrellisTickLabels(obj)

        end
    end
end