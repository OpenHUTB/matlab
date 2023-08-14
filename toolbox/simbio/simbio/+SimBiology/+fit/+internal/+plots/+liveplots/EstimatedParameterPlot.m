










classdef EstimatedParameterPlot<SimBiology.fit.internal.plots.liveplots.AbstractLinePlot

    properties(Access=public)
Index
HistAxes
Histogram
ScaleButton
        LogScale=false;
SelectedHistogram
YRange
LowerBoundLine
UpperBoundLine
Bounds
    end

    properties(Access=private)


Iterations
        BoundMargin=20;
    end

    methods

        function obj=EstimatedParameterPlot(index,showYLabel,showHistLabel,info,varargin)

            obj@SimBiology.fit.internal.plots.liveplots.AbstractLinePlot(varargin{:});


            obj.Index=index;

            obj.Axes.Title.Interpreter='none';
            obj.Axes.Title.String=info.EstimatedParameters{index};
            if showYLabel
                obj.Axes.YLabel.String=getString(message('SimBiology:fitplots:LivePlots_EstimatedParameterPlot_YLabel'));
            end

            obj.Axes.Tag=sprintf('LivePlots_EstimatedParameterPlot_%s',info.EstimatedParameters{index});


            obj.Lines=gobjects(0);


            if info.ShowHistogram
                obj.initHistogram(showHistLabel);
            end



            linearString=getString(message('SimBiology:fitplots:LivePlots_EstimatedParameterPlot_Linear_Button'));
            obj.ScaleButton=uicontrol('Style','pushbutton','String',linearString,'Position',[10,10,50,25],'Parent',obj.Axes.Parent,'Visible','off');
            obj.ScaleButton.Tag=sprintf('LivePlots_ScaleButton_%s',info.EstimatedParameters{index});
            obj.setPositionForButton();
            obj.ScaleButton.Visible='on';


            obj.ScaleButton.Callback=@(button,eventdata,handles)scale_Callback(obj,button);



            if~ismember(info.FunctionName,{'fminunc','fminsearch'})&&numel(info.Bounds)>=index&&~isempty(info.Bounds{index})
                obj.Bounds=info.Bounds{index};
            end




            obj.Iterations(1:info.NumGroups)=-1;
        end

        function initHistogram(obj,showHistLabel)

            availWidth=obj.Axes.Position(3);
            obj.Axes.Position(3)=0.6*availWidth;
            axesPos=obj.Axes.Position;

            obj.HistAxes=axes('Parent',obj.Axes.Parent,'Visible','off');
            obj.HistAxes.Position(1)=axesPos(1)+axesPos(3)+0.02;
            obj.HistAxes.Position(2)=axesPos(2);
            obj.HistAxes.Position(3)=0.4*availWidth-0.02;
            obj.HistAxes.Position(4)=axesPos(4);
            obj.Histogram=histogram(obj.HistAxes,[],'Visible','off','EdgeAlpha',0.5,'FaceColor',SimBiology.fit.internal.plots.liveplots.DashboardHelper.HistogramColor,'Tag','Histogram');
            hold(obj.HistAxes,'on');
            obj.SelectedHistogram=histogram(obj.HistAxes,[],'Visible','off','EdgeAlpha',0.5,'Tag','SelectedHistogram');
            part1=getString(message('SimBiology:fitplots:LivePlots_EstimatedParameterPlot_Histogram_Title_Part1'));
            part2=getString(message('SimBiology:fitplots:LivePlots_EstimatedParameterPlot_Histogram_Title_Part2'));
            obj.HistAxes.Title.String={part1;part2};
            obj.HistAxes.YAxisLocation='right';
            obj.HistAxes.Visible='on';


            obj.HistAxes.Tag=sprintf('%s_Histogram',obj.Axes.Tag);

            if showHistLabel
                obj.HistAxes.YLabel.String=getString(message('SimBiology:fitplots:LivePlots_EstimatedParameterPlot_Histogram_YLabel'));
            end
        end

        function updateContent(obj,info)
            lineObj=obj.Lines(info.Tag);


            iteration=obj.Iterations(info.Tag);
            iteration=iteration+1;
            obj.Iterations(info.Tag)=iteration;

            val=info.ParameterEstimates{info.Iteration+1};
            addpoints(lineObj,iteration,val(obj.Index));



            obj.drawBoundsLines(val(obj.Index),iteration);
        end


        function fadeContent(obj,info)
            fadeContent@SimBiology.fit.internal.plots.liveplots.AbstractLinePlot(obj,info);


            if~isempty(obj.LowerBoundLine)
                obj.fadeLine(obj.LowerBoundLine);
            end
            if~isempty(obj.UpperBoundLine)
                obj.fadeLine(obj.UpperBoundLine);
            end


            obj.updateHistogram();
        end

        function setSelectedLines(obj,indices)
            selectedLines=setSelectedLines@SimBiology.fit.internal.plots.liveplots.AbstractLinePlot(obj,indices);

            if isgraphics(obj.Histogram)&&~isempty(selectedLines)&&all(isgraphics(selectedLines))
                histPoints=obj.getHistPoints(selectedLines);


                obj.SelectedHistogram.Data=histPoints;
                obj.SelectedHistogram.NumBins=obj.Histogram.NumBins;
                obj.SelectedHistogram.BinEdges=obj.Histogram.BinEdges;
                obj.SelectedHistogram.BinWidth=obj.Histogram.BinWidth;
                obj.SelectedHistogram.BinLimits=obj.Histogram.BinLimits;
                obj.SelectedHistogram.FaceAlpha=0.4;
                obj.SelectedHistogram.Visible='on';
            else
                obj.SelectedHistogram.Visible='off';
            end
        end

        function clearSelectedLines(obj)
            clearSelectedLines@SimBiology.fit.internal.plots.liveplots.AbstractLinePlot(obj);
            if isgraphics(obj.SelectedHistogram)
                obj.SelectedHistogram.Visible='off';
            end
        end


        function figureResized(obj,~)
            obj.setPositionForButton();
            if~isempty(obj.LowerBoundLine)&&obj.LowerBoundLine.XData(end)~=obj.Axes.XLim(2)
                obj.LowerBoundLine.XData=obj.Axes.XLim;
            end

            if~isempty(obj.UpperBoundLine)&&obj.UpperBoundLine.XData(end)~=obj.Axes.XLim(2)
                obj.UpperBoundLine.XData=obj.Axes.XLim;
            end
        end
    end

    methods(Access=private)
        function setPositionForButton(obj)
            p=getpixelposition(obj.Axes);
            obj.ScaleButton.Position(1:2)=[p(1),(p(2)+p(4)+20)];


            obj.ScaleButton.Position(1)=obj.ScaleButton.Position(1)-obj.ScaleButton.Position(3)/2;
        end

        function updateHistogram(obj)


            allConvergedLines=findobj(obj.Lines,'Type','Line');
            histPoints=obj.getHistPoints(allConvergedLines);




            try
                obj.Histogram.Visible='on';
                obj.Histogram.Data=histPoints;
                obj.Histogram.BinMethod='auto';
            catch
            end
        end

        function histPoints=getHistPoints(obj,lines)
            histPoints=[];
            if~isempty(obj.HistAxes)
                numLines=numel(lines);
                histPoints=zeros(numLines,1);

                for i=1:numLines
                    lineObj=lines(i);
                    histPoints(i)=lineObj.YData(end);
                end
            end
        end

        function out=getLastPointForLine(~,lineObj)
            if isa(lineObj,'matlab.graphics.primitive.Line')
                out=lineObj.YData(end);
            end
        end

        function scale_Callback(obj,scaleButton)


            scaleButton.Enable='off';
            enableButton=onCleanup(@()set(scaleButton,'Enable','on'));

            obj.LogScale=~obj.LogScale;

            if obj.LogScale
                scaleButton.String=getString(message('SimBiology:fitplots:LivePlots_EstimatedParameterPlot_Log_Button'));
                obj.Axes.YScale='log';
                obj.updateYLim();
            else
                scaleButton.String=getString(message('SimBiology:fitplots:LivePlots_EstimatedParameterPlot_Linear_Button'));
                obj.Axes.YScale='linear';
                obj.updateYLim();
            end
        end




        function drawBoundsLines(obj,val,iter)
            if~isempty(obj.Bounds)
                updateYLim=false;
                origYRange=obj.YRange;
                if isempty(obj.YRange)
                    obj.YRange=[val,val];
                    updateYLim=true;
                else
                    obj.YRange=[min(val,obj.YRange(1)),max(val,obj.YRange(2))];
                    if obj.YRange(1)~=origYRange(1)||obj.YRange(2)~=origYRange(2)
                        updateYLim=true;
                    end
                end


                if updateYLim
                    obj.updateYLim();
                end


                obj.addLowerBoundLine(iter);
                obj.addUpperBoundLine(iter);


                if~isempty(obj.LowerBoundLine)
                    if iter>obj.LowerBoundLine.XData(2)
                        xlim=obj.Axes.XLim;
                        obj.LowerBoundLine.XData=xlim;
                    end
                end


                if~isempty(obj.UpperBoundLine)
                    if iter>obj.UpperBoundLine.XData(2)
                        xlim=obj.Axes.XLim;
                        obj.UpperBoundLine.XData=xlim;
                    end
                end
            end
        end

        function updateYLim(obj)
            if~isempty(obj.Bounds)&&~isempty(obj.YRange)
                ymin=obj.YRange(1);
                ymax=obj.YRange(2);














                n=0;


                if isfinite(obj.Bounds(1))
                    y1=obj.Bounds(1);
                    n=n+1;
                else
                    y1=ymin;
                end


                if isfinite(obj.Bounds(2))
                    y2=obj.Bounds(2);
                    n=n+1;
                else
                    y2=ymax;
                end


                pixelHeight=getpixelposition(obj.Axes);
                pixelHeight=pixelHeight(4);




                if strcmp(obj.Axes.YScale,'log')
                    obj.Axes.YLimMode='auto';
                    yLim=obj.Axes.YLim;
                    ymin=yLim(1);
                    ymax=yLim(2);



                    delta=log(y2/y1)/(pixelHeight/obj.BoundMargin-n);

                    if isfinite(obj.Bounds(1))
                        ymin=ymin*exp(-delta);
                    end

                    if isfinite(obj.Bounds(2))
                        ymax=ymax*exp(delta);
                    end
                else
                    delta=(y2-y1)/(pixelHeight/obj.BoundMargin-n);



                    if isfinite(obj.Bounds(1))
                        ymin=ymin-delta;
                    end



                    if isfinite(obj.Bounds(2))
                        ymax=ymax+delta;
                    end
                end

                obj.Axes.YLimMode='manual';
                obj.Axes.YLim=[ymin,ymax];
            end
        end

        function addLowerBoundLine(obj,iter)
            iter=iter+1;

            if isempty(obj.LowerBoundLine)
                if obj.Axes.YLim(1)<=obj.Bounds(1)
                    obj.LowerBoundLine=line([0,iter],[obj.Bounds(1),obj.Bounds(1)],'Parent',obj.Axes,'HitTest','off','Color',[0.5,0.5,0.5,0.5],'LineStyle','--','LineWidth',1.5,'Tag','LowerBoundLine');
                end
            end
        end

        function addUpperBoundLine(obj,iter)
            iter=iter+1;

            if isempty(obj.UpperBoundLine)
                if obj.Axes.YLim(2)>=obj.Bounds(2)
                    obj.UpperBoundLine=line([0,iter],[obj.Bounds(2),obj.Bounds(2)],'Parent',obj.Axes,'HitTest','off','Color',[0.5,0.5,0.5,0.5],'LineStyle','--','LineWidth',1.5,'Tag','UpperBoundLine');
                end
            end
        end
    end
end

