classdef SBioPlotMatrixPlot<SimBiology.internal.plotting.sbioplot.SBioPlotObject

    properties(Access=private)
        d=0.15;
    end



    methods(Access=public)
        function plotStyle=getPlotStyle(obj)
            plotStyle=SimBiology.internal.plotting.sbioplot.definition.PlotDefinition.PLOTMATRIX;
        end

        function flag=isSingleInput(obj)
            flag=obj.definition.getProperty('SingleInput');
        end
    end

    methods(Access=private)
        function setSingleInput(obj,flag)
            obj.definition.setProperty('SingleInput',flag);
        end

        function value=getUsedXParameters(obj)
            value=obj.definition.getProperty('XParameters');
            idx=[value.use];
            value=value(idx);
        end

        function value=getUsedYParameters(obj)
            value=obj.definition.getProperty('YParameters');
            idx=[value.use];
            value=value(idx);
        end

        function idx=getUsedXParametersIndex(obj)
            value=obj.definition.getProperty('XParameters');
            idx=[value.use];
        end

        function idx=getUsedYParametersIndex(obj)
            value=obj.definition.getProperty('YParameters');
            idx=[value.use];
        end

        function numParams=getNumberOfUsedXParameters(obj)
            numParams=numel(obj.getUsedXParameters());
        end

        function numParams=getNumberOfUsedYParameters(obj)
            if obj.isSingleInput
                numParams=obj.getNumberOfUsedXParameters();
            else
                numParams=numel(obj.getUsedYParameters());
            end
        end
    end




    methods(Access=protected)
        function setPlotArguments(obj,plotArgs)



            if~plotArgs.supportsPlotMatrixPlot()
                plotArgs=SimBiology.internal.plotting.sbioplot.PlotArgument.empty;
            end
            setPlotArguments@SimBiology.internal.plotting.sbioplot.SBioPlotObject(obj,plotArgs);
        end

        function processAdditionalArguments(obj,definitionProps)

            set(obj.figure.props,'LinkedX',true,'LinkedY',true);

            obj.setSingleInput(obj.getPlotArguments().hasSingleInput());

            xParameterNames=obj.getPlotArguments().getIndependentParameterNames();
            if obj.isSingleInput()
                yParameterNames={};
            else
                yParameterNames=obj.getPlotArguments().getDependentParameterNames();
            end
            obj.definition.props.updateParameters(xParameterNames,yParameterNames);
        end

        function setupAxes(obj)
            obj.numTrellisCols=obj.getNumberOfUsedXParameters();
            obj.numTrellisRows=obj.getNumberOfUsedYParameters();

            obj.figure.props.Column=obj.numTrellisCols;
            obj.figure.props.Row=obj.numTrellisRows;
            obj.resetAxes();
        end

        function resetAxes(obj)
            resetAxes@SimBiology.internal.plotting.sbioplot.SBioPlotObject(obj);

            if~obj.preserveFormats&&obj.hasData()

                obj.axes.setProperty('XGrid','off');
                obj.axes.setProperty('YGrid','off');
            end
        end

        function createPlot(obj)

            [xData,yData]=getDataToPlot(obj);


            obj.createScatterplots(xData,yData);


            obj.createHistograms(xData);
        end

        function label(obj)
            if~obj.preserveLabels
                obj.resetLabels();

                xParams=obj.getUsedXParameters();
                if obj.isSingleInput()
                    yParams=xParams;
                else
                    yParams=obj.getUsedYParameters();
                end
                obj.getAxesForRow(obj.numTrellisRows).setProperty('XLabel',transpose({xParams.name}));
                obj.getAxesForColumn(1).setProperty('YLabel',transpose({yParams.name}));
            end
        end
    end

    methods(Access=private)
        function[xData,yData]=getDataToPlot(obj)
            useIdx=obj.getUsedXParametersIndex();
            xData=obj.getPlotArguments().getIndependentParameterTable();
            xData=xData(:,useIdx);

            if obj.isSingleInput()
                yData=xData;
            else
                useIdx=obj.getUsedYParametersIndex();
                yData=obj.getPlotArguments().getDependentParameterTable();
                yData=yData(:,useIdx);
            end
        end

        function createScatterplots(obj,xData,yData)
            singleInput=obj.isSingleInput();

            for col=1:obj.getNumberOfUsedXParameters()
                x=xData{:,col};
                for row=1:obj.getNumberOfUsedYParameters()
                    y=yData{:,row};

                    if~(singleInput&&(row==col))
                        ax=obj.getAxesForSubplot(row,col);
                        plot(ax.handle,x,y,'.','MarkerSize',15);
                    end
                end
            end
        end

        function createHistograms(obj,xData)

            if obj.isSingleInput()
                for i=1:obj.getNumberOfUsedXParameters()

                    ax=obj.getAxesForSubplot(i,i);

                    x=[xData{:,i}];

                    if iscategorical(x)
                        binLimits=[NaN,NaN];
                    else
                        binLimits=[min(x),max(x)];

                        if diff(binLimits)==0
                            binLimits=[binLimits(1)*(1-0.5*obj.d),binLimits(2)*(1+0.5*obj.d)];
                        end
                    end

                    if all(~isnan(binLimits))
                        histogram(ax.handle,x,'BinLimits',binLimits);
                    else
                        histogram(ax.handle,x);
                    end
                end
            end
        end
    end


    methods
        function zoom(obj,changedAxesHandle,xLim,yLim)
            changedAxes=obj.axes.selectByHandle(changedAxesHandle);

            [axesToZoomX,axesToZoomY]=getAxesToModify(obj,changedAxes);

            if~isempty(xLim)

                idx=arrayfun(@(a)~SimBiology.internal.plotting.sbioplot.SBioPlotMatrixPlot.isHistogramAxes(a),axesToZoomX);
                obj.setAxesLimits(axesToZoomX(idx),true,xLim);
            end

            if~isempty(yLim)

                idx=arrayfun(@(a)~SimBiology.internal.plotting.sbioplot.SBioPlotMatrixPlot.isHistogramAxes(a),axesToZoomY);
                obj.setAxesLimits(axesToZoomY(idx),true,yLim);
            end

            obj.layout();
        end
    end

    methods(Access=protected)
        function updateLink(obj,useX)
            numAxes=numel(obj.axes);


            if numAxes==1&&obj.axes.isHistogramAxes()

                h=obj.axes.handle.Children;
                dy=calculateDx(obj,[0,max(h.Values)]);
                yLimits=[0,max(h.Values)+dy];
                set(obj.axes.handle,'Ylim',yLimits);


                if obj.axes.isNumericHistogramAxes()
                    binLimits=h.BinLimits;
                    dx=calculateDx(obj,[binLimits(1),binLimits(2)]);
                    xLimits=[binLimits(1)-dx,binLimits(2)+dx];
                    set(obj.axes.handle,'XLim',xLimits);
                end
                return;
            end


            if useX
                limitParam='XLim';
                modeParam='XLimMode';
                scaleParam='XScale';
                numParams=obj.numTrellisCols;
                getAxesToLink=@(c)obj.getAxesForColumn(c);

            else
                limitParam='YLim';
                modeParam='YLimMode';
                scaleParam='YScale';
                numParams=obj.numTrellisRows;
                getAxesToLink=@(c)obj.getAxesForRow(c);
            end

            for i=1:numParams
                axesToLink=getAxesToLink(i);


                idx=axesToLink.isHistogramAxes();
                axesForCalculation=[axesToLink(~idx).handle];


                if~useX
                    axesToLink=axesToLink(~idx);
                end


                scale=get(axesForCalculation(1),scaleParam);
                set([axesToLink.handle],scaleParam,scale);


                axLim=obj.calculateAxesLimit(axesToLink,useX);
                set([axesToLink.handle],modeParam,'manual',limitParam,axLim);
            end


            if~useX&&obj.isSingleInput
                idx=[obj.axes.isHistogramAxes()];
                histogramAxes=obj.axes(idx);
                axLim=calculateHistogramYLimits(obj,histogramAxes);
                set([histogramAxes.handle],modeParam,'manual',limitParam,axLim);
            end
        end

        function axLim=calculateAxesLimit(obj,axesInfo,useX)

            if useX
                dataParam='XData';
            else
                dataParam='YData';
            end

            idx=axesInfo.isHistogramAxes();
            axesToUse=[axesInfo(~idx).handle];


            axLim=[min(axesToUse(1).Children.(dataParam)),max(axesToUse(1).Children.(dataParam))];
            if isnumeric(axLim)&&isnan(axLim(1))
                axLim=[0,inf];
            end

            d=obj.calculateDx(axLim);
            if~isnan(d)
                axLim=[axLim(1)-d,axLim(2)+d];
            end
        end


        function axLim=calculateHistogramYLimits(obj,axesInfo)
            maxCount=0;
            for i=1:obj.getNumberOfUsedXParameters
                maxCount=max(maxCount,max(axesInfo(i).handle.Children.BinCounts));
            end
            dy=calculateDx(obj,[0,maxCount]);
            axLim=[0,maxCount+dy];
        end

        function dx=calculateDx(obj,axLim)
            xmin=axLim(1);
            xmax=axLim(2);

            if iscategorical(xmin)
                dx=NaN;
            elseif isinf(xmax)
                dx=0;
            else
                delta=xmax-xmin;
                if delta==0
                    if xmax==0
                        dx=1;
                    else
                        dx=obj.d*xmax;
                    end
                else
                    dx=obj.d*delta;
                end
            end
        end


        function[axesToResetX,axesToResetY]=getAxesToModify(obj,changedAxes)
            if obj.figure.props.LinkedX
                axesToResetX=obj.getAxesForColumn(obj.getColumnForAxes(changedAxes));
            else
                axesToResetX=changedAxes;
            end

            if obj.figure.props.LinkedY
                axesToResetY=obj.getAxesForRow(obj.getRowForAxes(changedAxes));
            else
                axesToResetY=changedAxes;
            end
        end

        function updateTrellisTickLabels(obj)
            if obj.isSingleInput()



                upperRightAxes=obj.getAxesForSubplot(1,obj.numTrellisCols).handle;
                upperLeftAxes=obj.getAxesForSubplot(1,1).handle;
                lowerRightAxes=obj.getAxesForSubplot(obj.numTrellisRows,obj.numTrellisCols).handle;

                xTickLabel=get(upperRightAxes,'XTickLabel');
                yTickLabel=get(upperRightAxes,'YTickLabel');
                xTick=get(upperRightAxes,'XTick');
                yTick=double(get(upperRightAxes,'YTick'));



                rangeHist=upperLeftAxes.YLim;
                rangeParam=upperRightAxes.YLim;
                if iscategorical(rangeParam)
                    rangeParam=[0.5,double(rangeParam(2))+0.5];
                end
                rangeRatio=diff(rangeHist)/diff(rangeParam);
                yTick=(yTick-rangeParam(1))*rangeRatio+rangeHist(1);
            end

            updateTrellisTickLabels@SimBiology.internal.plotting.sbioplot.SBioPlotObject(obj);


            if(obj.isSingleInput&&all(~isinf(rangeHist))&&all(~isinf(rangeParam)))


                set(upperLeftAxes,'YTick',yTick);
                set(lowerRightAxes,'XTick',xTick);
            end
        end
    end


    methods(Access=private)
        function axesInfo=getScatterplotAxes(obj)
            axesInfo=obj.selectAxesByType(obj.axes,false);
        end

        function axesInfo=getHistogramAxes(obj)
            axesInfo=obj.selectAxesByType(obj.axes,false);
        end
    end

    methods(Static,Access=private)
        function axesInfo=selectAxesByType(axesInfo,isHistogram)

            idx=axesInfo.isHistogramAxes;
            if isHistogram
                axesInfo=axesInfo(idx);
            else
                axesInfo=axesInfo(~idx);
            end
        end
    end
end