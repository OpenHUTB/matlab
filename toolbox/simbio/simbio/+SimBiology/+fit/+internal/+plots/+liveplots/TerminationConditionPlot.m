









classdef TerminationConditionPlot<SimBiology.fit.internal.plots.liveplots.AbstractPlot

    properties(Access=public)
Index
ExitFlag
Groups
FunctionName
Lines
    end

    methods

        function obj=TerminationConditionPlot(info,varargin)

            obj@SimBiology.fit.internal.plots.liveplots.AbstractPlot(varargin{:});


            obj.FunctionName=info.FunctionName;


            obj.Axes.Title.Interpreter='none';
            obj.Axes.Title.String='Termination Conditions';
            obj.Axes.XLabel.String='Group Index';
            obj.Axes.YLabel.String='Exit Flag';


            obj.Lines=containers.Map('KeyType','double','ValueType','any');
        end

        function updateContent(~,~)
        end

        function addContent(~,~)
        end

        function fadeContent(~,~)
        end

        function figureResized(~,~)
        end

        function setExitFlag(obj,index,exitFlag)
            if~isempty(exitFlag)
                obj.Index(end+1)=index;
                obj.ExitFlag(end+1)=exitFlag;



                [obj.ExitFlag,SortIndex]=sort(obj.ExitFlag);
                obj.Index=obj.Index(SortIndex);

                uniqueVals=unique(obj.ExitFlag);

                pointIndex=1;
                for i=1:numel(uniqueVals)
                    lineObj=obj.getLine(uniqueVals(i));
                    yVals=obj.ExitFlag(obj.ExitFlag==uniqueVals(i));
                    numVals=numel(yVals);
                    xVals=linspace(pointIndex,pointIndex+numVals-1,numVals);
                    pointIndex=pointIndex+numel(xVals);

                    lineObj.XData=xVals;
                    lineObj.YData=yVals;
                    lineObj.Visible='on';
                end

                obj.Axes.YLim=[uniqueVals(1)-1,uniqueVals(end)+1];
                xticks=sort(obj.Index);
                obj.Axes.XLim=[xticks(1)-1,xticks(end)+1];
                obj.Axes.XTick=xticks;
                obj.Axes.XTickLabel=obj.Index;
            end
        end

        function cleanup(~)
        end

        function setSelectedLines(~,~)
        end

        function clearSelectedLines(~)
        end
    end

    methods(Access='private')
        function out=getLine(obj,exitFlag)
            if obj.Lines.isKey(exitFlag)
                out=obj.Lines(exitFlag);
            else
                out=line('Visible','off','Parent',obj.Axes);
                out.LineStyle='none';
                out.MarkerSize=7;
                out.Marker='o';
                out.MarkerEdgeColor='none';
                out.MarkerFaceColor=obj.getMarkerColor(exitFlag);
                obj.Lines(exitFlag)=out;
            end
        end

        function out=getMarkerColor(~,exitFlag)
            colorMap=hsv;
            if exitFlag<=0
                hsvInt=5+exitFlag;
            else
                hsvInt=23+exitFlag;
            end

            out=colorMap(hsvInt,:);
        end
    end
end
