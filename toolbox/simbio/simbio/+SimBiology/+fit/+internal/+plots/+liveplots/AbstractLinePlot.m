










classdef(Abstract)AbstractLinePlot<SimBiology.fit.internal.plots.liveplots.AbstractPlot

    properties(Access=protected)
PendingExitFlags
Lines
    end

    methods

        function obj=AbstractLinePlot(varargin)
            obj@SimBiology.fit.internal.plots.liveplots.AbstractPlot(varargin{:});


            obj.PendingExitFlags=containers.Map('KeyType','double','ValueType','any');


            obj.Lines=gobjects(0);
        end


        function cleanup(obj)
            currentLines=findobj(obj.Lines,'Type','AnimatedLine');
            for i=1:numel(currentLines)
                tag=currentLines(i).UserData;
                obj.fadeLine(currentLines(i));



                if obj.PendingExitFlags.isKey(tag)
                    exitFlag=obj.PendingExitFlags(tag);
                    obj.setExitFlag(tag,exitFlag);
                end
            end
        end


        function addContent(obj,info)
            lineObj=animatedline('Parent',obj.Axes,'Color',obj.getDefaultLineColor(),'UserData',info.Tag,'LineWidth',2);
            obj.Lines(info.Tag)=lineObj;
        end


        function fadeContent(obj,info)


            if numel(obj.Lines)>=info.Tag
                obj.fadeLine(obj.Lines(info.Tag));
            end



            if obj.PendingExitFlags.isKey(info.Tag)
                exitFlag=obj.PendingExitFlags(info.Tag);
                obj.setExitFlag(info.Tag,exitFlag);
            end
        end


        function setExitFlag(obj,index,exitFlag)
            lineObj=obj.getPrimitiveLineObject(index);
            if~isempty(lineObj)
                if exitFlag<=0
                    lineObj.Color=SimBiology.fit.internal.plots.liveplots.DashboardHelper.FailedLineColor;
                end


                if index<=numel(obj.PendingExitFlags)
                    obj.PendingExitFlags(index)=[];
                end
            else


                obj.PendingExitFlags(index)=exitFlag;
            end
        end


        function newLine=fadeLine(obj,lineObj)
            if isa(lineObj,'matlab.graphics.animation.AnimatedLine')
                [x,y]=getpoints(lineObj);
                tag=lineObj.UserData;
                newLine=line('Parent',obj.Axes,'Color',lineObj.Color,'XData',x,'YData',y,'UserData',tag);
                newLine.Color(4)=0.3;
                newLine.LineWidth=lineObj.LineWidth;
                obj.Lines(tag)=newLine;
                delete(lineObj);

                if numel(x)==1
                    newLine.Marker='.';
                end
            else
                newLine=[];
            end
        end



        function clearSelectedLines(obj)
            lines=findobj(obj.Lines,'Type','Line');
            for i=1:numel(lines)
                lineObj=lines(i);
                lineObj.LineWidth=1;
                lineObj.Color(4)=0.3;
            end
        end


        function out=getLineIndexForSelection(obj,pos)
            out=[];
            lines=findobj(obj.Lines,'Type','Line');
            for i=1:numel(lines)
                lineObj=lines(i);
                xdata=lineObj.XData;
                ydata=lineObj.YData;

                mask=xdata>=pos(1)&xdata<=pos(2)&ydata>=pos(3)&ydata<=pos(4);

                if~isempty(find(mask,1))
                    out(end+1)=lineObj.UserData;%#ok<AGROW>
                end
            end
        end


        function selectedLines=setSelectedLines(obj,indices)
            selectedLines=gobjects(0);
            lines=findobj(obj.Lines,'Type','Line');

            for i=1:numel(lines)
                lineObj=lines(i);
                index=lineObj.UserData;
                if find(ismember(indices,index),1)
                    lineObj.LineWidth=2;
                    lineObj.Color(4)=1;
                    selectedLines(end+1)=lineObj;%#ok<AGROW>
                else
                    lineObj.LineWidth=1;
                    lineObj.Color(4)=0.3;
                end
            end
        end



        function out=getPrimitiveLineObject(obj,index)
            out=[];
            if numel(obj.Lines)>=index
                lineObj=obj.Lines(index);
                if isa(lineObj,'matlab.graphics.primitive.Line')
                    out=lineObj;
                end
            end
        end

        function out=getDefaultLineColor(~)
            out=SimBiology.fit.internal.plots.liveplots.DashboardHelper.LineColor;
        end


        function figureResized(~,~)
        end
    end
end

