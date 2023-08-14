









classdef LogLikelihoodPlot<SimBiology.fit.internal.plots.liveplots.AbstractLinePlot

    properties(Access=private)
MaxIterLine
MaxIterText
YRange
SingleFit
FunctionName
    end

    methods

        function obj=LogLikelihoodPlot(singleFit,functionName,varargin)

            obj@SimBiology.fit.internal.plots.liveplots.AbstractLinePlot(varargin{:});


            obj.Axes.YScale='linear';
            obj.Axes.Title.Interpreter='none';
            obj.Axes.Title.String=getString(message('SimBiology:fitplots:LivePlots_LogLikelihood_Title'));
            obj.Axes.XLabel.String=getString(message('SimBiology:fitplots:LivePlots_LogLikelihood_XLabel'));



            obj.SingleFit=singleFit;


            obj.FunctionName=functionName;


            obj.Axes.Tag=sprintf('LivePlots_LogLikelihoodPlot_%s',functionName);
        end

        function updateContent(obj,info)

            lineObj=obj.Lines(info.Tag);
            val=info.LogLikelihoodValue{info.Iteration+1};
            addpoints(lineObj,info.Iteration,val);


            obj.updateMaxIterLine(info.MaxIter,info.Iteration,val);
        end


        function setExitFlag(obj,index,exitFlag)
            lineObj=getPrimitiveLineObject(obj,index);
            if~isempty(lineObj)
                if exitFlag<=0
                    lineObj.Color=[1,0,0,0.3];
                end


                if obj.SingleFit
                    xData=lineObj.XData(end);
                    yData=lineObj.YData(end);

                    exitCond=SimBiology.fit.internal.plots.liveplots.DashboardHelper.getExitConditionString(1,obj.FunctionName,exitFlag,true);
                    text(xData,yData,exitCond,'VerticalAlignment','bottom','HorizontalAlignment','right','Parent',obj.Axes,'Tag','LivePlots_LogLikelihoodPlot_ExitCondition_Text');


                    yLim=obj.Axes.YLim;
                    delta=yLim(2)-yLim(1);
                    if~isnan(delta)
                        obj.Axes.YLim=[yLim(1),yLim(2)+(delta*0.05)];
                    end
                end


                obj.PendingExitFlags(index)=[];
            else


                obj.PendingExitFlags(index)=exitFlag;
            end
        end


        function figureResized(obj,~)

            obj.updateMaxIterLineRange(obj.Axes.YLim);
        end
    end

    methods(Access=private)
        function updateMaxIterLine(obj,maxIter,iter,val)
            origYRange=obj.YRange;
            if isempty(obj.YRange)
                obj.YRange=[val,val];
                drawMaxIterLine(obj,maxIter);
            else
                obj.YRange=[min(val,obj.YRange(1)),max(val,obj.YRange(2))];
                if obj.YRange(1)~=origYRange(1)||obj.YRange(2)~=origYRange(2)||maxIter<=iter
                    drawMaxIterLine(obj,maxIter);
                end
            end
        end



        function drawMaxIterLine(obj,maxIter)
            yLim=obj.Axes.YLim;
            if isempty(obj.MaxIterLine)&&~isempty(maxIter)
                xLim=obj.Axes.XLim;

                if maxIter>=xLim(1)&&maxIter<=xLim(2)

                    obj.MaxIterLine=line([maxIter,maxIter],yLim,'Parent',obj.Axes,'Color','r','LineWidth',2.5,'HitTest','off','Tag','LivePlots_LogLikelihoodPlot_MaxIterLine');
                    maxIterStr=getString(message('SimBiology:fitplots:LivePlots_Log_LikeLihood_MaxIter'));
                    obj.MaxIterText=text(maxIter,obj.Axes.XLabel.Position(2)+obj.Axes.XLabel.Position(3),maxIterStr,'Parent',obj.Axes,'HorizontalAlignment','Center','Tag','LivePlots_LogLikelihoodPlot_MaxIterText');
                end
            else
                obj.updateMaxIterLineRange(yLim)
            end
        end

        function updateMaxIterLineRange(obj,yLim)
            if~isempty(obj.MaxIterLine)
                obj.MaxIterLine.YData=yLim;
                obj.MaxIterText.Position(2)=obj.Axes.XLabel.Position(2)+obj.Axes.XLabel.Position(3);
            end
        end
    end
end

