











classdef TerminationConditionHistogram<SimBiology.fit.internal.plots.liveplots.AbstractPlot

    properties(Access=public)
Index
ExitFlag
Groups
FunctionName
BarConverged
BarFailed
TextLabels
SingleConditionText
BarSelected
Legend
    end

    properties(Access=private)
TextObj
    end

    methods

        function obj=TerminationConditionHistogram(info,varargin)

            obj@SimBiology.fit.internal.plots.liveplots.AbstractPlot(varargin{:});

            obj.FunctionName=info.FunctionName;


            obj.TextLabels=containers.Map('KeyType','double','ValueType','any');

            obj.BarFailed=bar(0,0,'Parent',obj.Axes,'FaceColor',SimBiology.fit.internal.plots.liveplots.DashboardHelper.FailedBarColor,'FaceAlpha',0.8,'EdgeAlpha',0.3,'Visible','off','Tag','LivePlots_TerminationCondition_HistogramFailed');
            hold(obj.Axes,'on');
            obj.BarConverged=bar(0,0,'Parent',obj.Axes,'FaceColor',SimBiology.fit.internal.plots.liveplots.DashboardHelper.LineColor,'FaceAlpha',0.8,'EdgeAlpha',0.3,'Visible','off','Tag','LivePlots_TerminationCondition_HistogramConverged');


            obj.BarSelected=bar(0,0,'Parent',obj.Axes,'FaceColor',SimBiology.fit.internal.plots.liveplots.DashboardHelper.OverlayBarColor,'FaceAlpha',1,'EdgeAlpha',0.3,'Visible','off','Tag','LivePlots_TerminationCondition_HistogramSelected');

            hold(obj.Axes,'off');




            obj.Axes.Title.Interpreter='none';
            obj.Axes.Title.String=getString(message('SimBiology:fitplots:LivePlots_TerminationConditionHistogram_Title'));


            obj.SingleConditionText=text('Parent',obj.Axes,'HorizontalAlignment','center','Visible','off','Position',[0.5,0.5,0],'Tag','LivePlots_TerminationCondition_SingleExitCondition_Text');



            obj.TextObj=uicontrol(varargin{4},'Style','text','Visible','off','HorizontalAlignment','center');


            obj.Axes.YTickLabel=[];


            obj.Axes.Tag='LivePlots_TerminationConditionHistogram';


            failedText=getString(message('SimBiology:fitplots:LivePlots_TerminationConditionHistogram_Legend_Failed'));
            convergedText=getString(message('SimBiology:fitplots:LivePlots_TerminationConditionHistogram_Legend_Converged'));

            obj.Legend=legend(obj.Axes,{failedText,convergedText},'Location','northeastoutside');
            obj.Legend.Visible='off';
            obj.Legend.Units='pixels';
            obj.figureResized();
        end

        function updateContent(~,~)
        end

        function addContent(~,~)
        end

        function fadeContent(~,~)
        end




        function setExitFlag(obj,index,exitFlag)
            if~isempty(exitFlag)
                obj.Index(end+1)=index;
                obj.ExitFlag(end+1)=exitFlag;



                [obj.ExitFlag,SortIndex]=sort(obj.ExitFlag);
                obj.Index=obj.Index(SortIndex);
                uniqueExitFlags=unique(obj.ExitFlag);


                p=getpixelposition(obj.Axes);
                axesWidth=p(3);



                if numel(uniqueExitFlags)==1
                    numFits=numel(obj.ExitFlag);
                    tempStr=SimBiology.fit.internal.plots.liveplots.DashboardHelper.getExitConditionString(numFits,obj.FunctionName,obj.ExitFlag(1),false);



                    obj.TextObj.Position(3)=max(30,axesWidth-30);
                    obj.SingleConditionText.String=textwrap(obj.TextObj,{tempStr});
                    obj.SingleConditionText.Visible='on';
                else
                    obj.BarConverged.Visible='on';
                    obj.BarFailed.Visible='on';

                    obj.SingleConditionText.Visible='off';



                    [binCount,~,~]=histcounts(obj.ExitFlag,(min(uniqueExitFlags):max(uniqueExitFlags)+1));



                    yData=binCount(binCount>0);

                    xData=(1:numel(uniqueExitFlags));


                    convergedXData=xData(uniqueExitFlags>0);
                    convergedYData=yData(uniqueExitFlags>0);

                    failedXData=xData(uniqueExitFlags<=0);
                    failedYData=yData(uniqueExitFlags<=0);


                    obj.BarConverged.XData=convergedXData;
                    obj.BarConverged.YData=convergedYData;

                    obj.BarFailed.XData=failedXData;
                    obj.BarFailed.YData=failedYData;


                    obj.Axes.YTickLabel=obj.Axes.YTick;


                    obj.Axes.XTick=xData;
                    obj.Axes.XTickLabel=obj.getXTickLabels(uniqueExitFlags);


                    if axesWidth/numel(uniqueExitFlags)<SimBiology.fit.internal.plots.liveplots.DashboardHelper.LongestTickWidth

                        obj.Axes.XTickLabelRotation=45;
                    end


                    obj.Legend.Visible='on';



                end
            end
        end

        function cleanup(~)
        end



        function out=getLineIndexForSelection(obj,position)
            out=[];
            convergedXData=obj.BarConverged.XData;
            failedXData=obj.BarFailed.XData;

            convergedYData=obj.BarConverged.YData;
            failedYData=obj.BarFailed.YData;

            convergedMask=convergedXData>=position(1)&convergedXData<=position(2)&convergedYData>=position(3);
            failedMask=failedXData>=position(1)&failedXData<=position(2)&failedYData>=position(3);

            selectedIndex=[convergedXData(convergedMask),failedXData(failedMask)];
            exitCond=unique(obj.ExitFlag);

            [~,indices]=ismember(obj.ExitFlag,exitCond(selectedIndex));

            indices=find(indices);
            if~isempty(indices)
                out=obj.Index(indices);
            end
        end

        function setSelectedLines(obj,indices)
            if~isempty(indices)


                uniqueExitFlags=unique(obj.ExitFlag);
                [origBinCount,edges,~]=histcounts(obj.ExitFlag,(min(uniqueExitFlags):max(uniqueExitFlags)+1));


                selectedExitFlags=obj.ExitFlag(ismember(obj.Index,indices));


                [binCount,~,~]=histcounts(selectedExitFlags,edges);




                obj.BarSelected.YData=binCount(origBinCount>0);
                obj.BarSelected.XData=obj.Axes.XTick;
                obj.BarSelected.Visible='on';
            else
                obj.clearSelectedLines();
            end
        end

        function clearSelectedLines(obj)
            obj.BarSelected.XData=[];
            obj.BarSelected.YData=[];
            obj.BarSelected.Visible='off';
        end

        function figureResized(obj,~)
            p=getpixelposition(obj.Axes);
            obj.Legend.Position(1)=p(1)+p(3)+10;
            obj.Legend.Position(2)=p(2)+p(4)-obj.Legend.Position(4);
        end
    end

    methods(Access=private)
        function addTextLabelsToBar(obj)
            yData=[obj.BarFailed.YData,obj.BarConverged.YData];
            xData=[obj.BarFailed.XData,obj.BarConverged.XData];


            for i=1:numel(xData)

                if yData(i)>0
                    key=xData(i);
                    if obj.TextLabels.isKey(key)
                        textObj=obj.TextLabels(key);
                    else
                        textObj=text('Parent',obj.Axes,'HorizontalAlignment','center');
                        obj.TextLabels(key)=textObj;
                    end

                    numGroups=sum(obj.ExitFlag==xData(i));

                    textObj.String=num2str(numGroups);
                    textObj.Position=[xData(i),yData(i)-0.02,0];
                end
            end
        end


        function out=getXTickLabels(obj,uniqueExitFlags)
            out=cell(1,numel(uniqueExitFlags));

            for i=1:numel(uniqueExitFlags)
                out{i}=SimBiology.fit.internal.plots.liveplots.DashboardHelper.getExitConditionSummary(obj.FunctionName,uniqueExitFlags(i));
            end
        end
    end
end
