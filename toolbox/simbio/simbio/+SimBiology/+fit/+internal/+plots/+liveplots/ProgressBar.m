classdef ProgressBar<handle

    properties(Access=private)
CompletedBar
RunningBar
TotalBar
CompletedText
RunningText
NotRunText
TotalText
Total
Position
        NumRunning=0;
        NumCompleted=0;
Panel
TextWidth
TextHeight
    end

    properties(Access=public)
        Type=''
    end


    methods

        function obj=ProgressBar(parent,units,position,total,varargin)


            nVarargs=length(varargin);
            if nVarargs>2
                error(message('SimBiology:fitplots:LivePlots_ProgressBar_Arguments_Check'));
            end

            colors='';
            for i=1:nVarargs
                switch i
                case 1
                    colors=varargin{i};
                case 2
                    obj.Type=varargin{i};
                end
            end

            notRunningColor=[1,1,1];
            runningColor=SimBiology.fit.internal.plots.liveplots.DashboardHelper.LineColor;
            completedColor=SimBiology.fit.internal.plots.liveplots.DashboardHelper.HistogramColor;

            if strcmp(obj.Type,'BaT')&&~isempty(colors)&&numel(colors)~=3
                error(message('SimBiology:fitplots:LivePlots_ProgressBar_Color_Check'));
            end

            if strcmp(obj.Type,'BaT')&&numel(colors)==3
                notRunningColor=colors{1};
                runningColor=colors{2};
                completedColor=colors{3};
            end

            if~strcmp(obj.Type,'BaT')&&numel(colors)>0
                completedColor=colors;
            end


            obj.Total=total;


            obj.Panel=uipanel('Parent',parent,'Units',units,'Position',position,'BorderType','none','Tag','LivePlots_ProgressBar');


            obj.TotalBar=uicontrol('Parent',obj.Panel,'Style','text','BackgroundColor',notRunningColor,'Visible','off');


            obj.CompletedBar=uicontrol('Parent',obj.Panel,'Style','text','BackgroundColor',completedColor,'Visible','off');



            obj.TotalText=uicontrol('Parent',obj.Panel,'Style','text','Visible','off','HorizontalAlignment','right');



            if strcmp(obj.Type,'BaT')

                obj.RunningBar=uicontrol('Parent',obj.Panel,'Style','text','BackgroundColor',runningColor,'Visible','off');
                uistack(obj.RunningBar,'down',2);

                obj.CompletedText=uicontrol('Parent',obj.Panel,'Style','text','Visible','off','HorizontalAlignment','center');
                obj.NotRunText=uicontrol('Parent',obj.Panel,'Style','text','Visible','off','HorizontalAlignment','center');
                obj.RunningText=uicontrol('Parent',obj.Panel,'Style','text','Visible','on','HorizontalAlignment','right');





                [~,pos]=textwrap(obj.CompletedText,{sprintf('%d',total)});
                obj.CompletedText.Position(3:4)=pos(3:4);
                obj.NotRunText.Position(3:4)=pos(3:4);
                obj.RunningText.Position(3:4)=pos(3:4);
                obj.TotalText.Position(3:4)=pos(3:4);
            else



                [~,pos]=textwrap(obj.TotalText,{'100.00%'});
                obj.TotalText.Position(3:4)=pos(3:4);
            end

            obj.TextWidth=obj.TotalText.Position(3);
            obj.TextHeight=obj.TotalText.Position(4);


            obj.layout();
        end

        function figureResized(obj,hObject)
            position=hObject.Position;
            obj.Panel.Position(1)=position(3)-obj.Panel.Position(3)-50;
        end


        function setVisible(obj,visible)
            if visible
                obj.Panel.Visible='on';
            else
                obj.Panel.Visible='off';
            end
        end

        function layout(obj)


            obj.Panel.Units='pixels';
            bounds=obj.Panel.Position;


            if strcmp(obj.Type,'BaT')




                obj.TotalBar.Position(1:2)=[obj.TextWidth/2,obj.TextHeight];
                obj.TotalBar.Position(3:4)=[bounds(3)-obj.TextWidth*1.5,bounds(4)-2*obj.TextHeight];


                obj.RunningBar.Position=obj.TotalBar.Position;
                obj.RunningBar.Position(3)=0;


                obj.setText(obj.NotRunText,obj.Total);
                obj.setText(obj.CompletedText,0);
                obj.setText(obj.RunningText,0);
                obj.setText(obj.TotalText,obj.Total);


                obj.CompletedText.Position(1:2)=[0,0];

                obj.NotRunText.Position(1:2)=[obj.TotalBar.Position(3),0];
                obj.RunningText.Position(1:2)=[0,obj.TotalBar.Position(2)+obj.TotalBar.Position(4)];


                obj.NotRunText.Visible='on';
                obj.RunningText.Visible='on';
                obj.CompletedText.Visible='on';
                obj.RunningBar.Visible='on';
            else


                obj.TotalBar.Position=[0,0,bounds(3)-obj.TextWidth,bounds(4)];


                obj.setText(obj.TotalText,0);
            end


            obj.TotalText.Position(1:2)=[obj.TotalBar.Position(3)+obj.TotalBar.Position(1),obj.TotalBar.Position(2)+obj.TotalBar.Position(4)/2-obj.TotalText.Position(4)/2];



            obj.CompletedBar.Position=obj.TotalBar.Position;
            obj.CompletedBar.Position(3)=0;


            obj.TotalBar.Visible='on';
            obj.CompletedBar.Visible='on';
            obj.TotalText.Visible='on';
        end

        function close(obj)

            delete(obj.TotalBar);
            delete(obj.TotalText);
            delete(obj.CompletedBar);


            if strcmp(obj.Type,'BaT')
                delete(obj.RunningText);
                delete(obj.NotRunText);
                delete(obj.TotalBar);
                delete(obj.RunningBar);
            end
        end


        function addRunning(obj)
            obj.NumRunning=obj.NumRunning+1;
            obj.update(obj.NumRunning,obj.NumCompleted);
        end


        function addCompleted(obj)
            obj.NumCompleted=obj.NumCompleted+1;
            obj.NumRunning=obj.NumRunning-1;
            obj.update(obj.NumRunning,obj.NumCompleted);
        end


        function update(obj,running,completed)
            runningPct=running/obj.Total;
            completedPct=completed/obj.Total;

            if strcmp(obj.Type,'BaT')
                obj.RunningBar.Position(3)=obj.TotalBar.Position(3)*(completedPct+runningPct);
                obj.setText(obj.RunningText,running);
                obj.setText(obj.NotRunText,(obj.Total-(completed+running)));
                obj.setText(obj.CompletedText,completed);


                obj.RunningText.Position(1)=obj.RunningBar.Position(3)+obj.RunningBar.Position(1)-obj.RunningText.Position(3)/2-4;
            else
                obj.setText(obj.TotalText,completedPct*100);
            end

            obj.CompletedBar.Position(3)=obj.TotalBar.Position(3)*completedPct;
        end
    end

    methods(Access=private)
        function setText(obj,textObj,text)
            if strcmp(obj.Type,'BaT')
                textObj.String=sprintf('%d',text);
            else
                textObj.String=sprintf('%.2f%%',text);
            end
        end
    end
end