











classdef StaticROI<handle
    properties(GetAccess=public,SetAccess=private)
ROIPositions
AxesHandle
Color
Label
SublabelName
ParentUID
SelfUID
ROIVisibility
    end

    properties(Access=private)


Group





hStaticLine
hLabelIcons
    end

    properties(Dependent)
Visible
    end




    methods

        function this=StaticROI(rois,hAx,color,labelName,sublabelName,selfUID,parentUID,showLabel,roiVisibility)
















            this.ROIPositions=rois;
            this.AxesHandle=hAx;
            this.Color=color;
            this.Label=labelName;
            this.SublabelName=sublabelName;
            this.ParentUID=parentUID;
            this.SelfUID=selfUID;
            this.ROIVisibility=roiVisibility;


            this.Group=hggroup('Parent',this.AxesHandle,'Tag','staticroi');


            warnState=warning('off','images:imuitoolsgate:undocumentedFunction');


            cleanupObj=onCleanup(@()warning(warnState));

            drawStaticROIs(this,showLabel);
        end


        function delete(this)
            if ishghandle(this.Group)
                delete(this.Group);
            end
        end


        function set.Visible(this,onOff)

            for n=1:numel(this.hStaticLine)
                set(this.hStaticLine{n},'Visible',onOff);
                set(this.hLabelIcons{n},'Visible',onOff);
            end

        end


        function setTextLabelVisible(this,showLabel)
            for n=1:numel(this.hLabelIcons)
                if showLabel
                    this.hLabelIcons{n}.Visible='on';
                else
                    this.hLabelIcons{n}.Visible='off';
                end
            end
        end
    end

    methods(Access=private)

        function drawStaticROIs(this,showLabel)

            for n=1:size(this.ROIPositions,1)
                constructRectView(this,n);
                addLabel(this,n,showLabel);
            end
        end


        function constructRectView(this,n)


            pointsPerInch=72;
            pixelsPerInch=get(0,'ScreenPixelsPerInch');
            lineWidth=pointsPerInch/pixelsPerInch;

            positions=this.ROIPositions(n,:);
            positions(1)=positions(1)-0.5;
            positions(2)=positions(2)-0.5;
            x=[positions(1);positions(1);...
            positions(1)+positions(3);...
            positions(1)+positions(3);...
            positions(1)];
            y=[positions(2);...
            positions(2)+positions(4);...
            positions(2)+positions(4);...
            positions(2);positions(2)];

            this.hStaticLine{n}=line(x,y,'Parent',this.Group,...
            'Color',this.Color,...
            'LineWidth',3*lineWidth,...
            'Tag','staticRectangeROI',...
            'Visible',this.ROIVisibility,...
            'HandleVisibility','off');
        end


        function addLabel(this,n,showLabel)

            roiPositions=this.ROIPositions(n,:)-[0.5,0.5,0,0];
            if isempty(this.SublabelName)
                labelName=this.Label;
            else
                labelName=this.SublabelName;
            end
            this.hLabelIcons{n}=text('Parent',this.Group,...
            'BackgroundColor',this.Color,'String',labelName,...
            'Tag','category','Interpreter','none','Clipping','on',...
            'Margin',1,'VerticalAlignment','bottom');
            labelPos=[roiPositions(1),...
            roiPositions(2)+roiPositions(4)];
            this.hLabelIcons{n}.Position=labelPos;
            if showLabel
                this.hLabelIcons{n}.Visible='on';
            else
                this.hLabelIcons{n}.Visible='off';
            end
        end
    end
end
