











classdef StaticLineROI<handle
    properties(GetAccess=public,SetAccess=private)
ROIPositions
AxesHandle
Color
Label
SublabelName
SelfUID
ParentUID
ShowDeleteIcon
ROIVisibility
    end

    properties(Access=protected)





hLine
hPoints
hDeleteIcon
hLabelIcon
    end

    properties(Dependent)
Visible
    end




    methods

        function this=StaticLineROI(rois,hAx,color,labelName,sublabelName,selfUID,parentUID,showLabel,roiVisibility)

















            this.ROIPositions=rois;
            this.AxesHandle=hAx;
            this.Color=color;
            this.Label=labelName;
            this.SublabelName=sublabelName;
            this.SelfUID=selfUID;
            this.ParentUID=parentUID;
            this.ROIVisibility=roiVisibility;


            warnState=warning('off','images:imuitoolsgate:undocumentedFunction');


            cleanupObj=onCleanup(@()warning(warnState));

            drawStaticROI(this,showLabel);
        end


        function delete(this)
            delete(this.hLine);
            delete(this.hPoints);
            delete(this.hLabelIcon);
        end


        function set.Visible(this,onOff)
            set(this.hLine,'Visible',onOff);
            set(this.hPoints,'Visible',onOff);
            set(this.hLabelIcon,'Visible',onOff);
        end


        function setTextLabelVisible(this,showLabel)
            if showLabel
                this.hLabelIcon.Visible='on';
            else
                this.hLabelIcon.Visible='off';
            end
        end
    end

    methods(Access=private)

        function drawStaticROI(this,showLabel)
            constructLineView(this);
            constructVertices(this);
            addLabel(this,showLabel);
        end


        function constructVertices(this)
            pos=this.ROIPositions;
            markerSize=vision.internal.videoLabeler.tool.LaneMarkerWidget.getCircleSize();
            for inx=1:size(pos,1)
                this.hPoints(inx)=line(pos(inx,1),pos(inx,2),...
                'Parent',this.AxesHandle,...
                'Marker','o',...
                'MarkerFaceColor',this.Color,...
                'HitTest','off',...
                'Clipping','on',...
                'MarkerSize',markerSize,...
                'Visible',this.ROIVisibility,...
                'Tag','circle');
            end
        end


        function constructLineView(this)
            pos=this.ROIPositions;
            lineSize=vision.internal.videoLabeler.tool.LaneMarkerWidget.getLineSize();
            this.hLine=line(pos(:,1),pos(:,2),...
            'Parent',this.AxesHandle,...
            'Color',this.Color,...
            'LineWidth',lineSize,...
            'HitTest','off',...
            'Visible',this.ROIVisibility,...
            'Tag','lanemarkerline');
        end


        function addLabel(this,showLabel)
            labelPos=vision.internal.videoLabeler.tool.LaneMarkerWidget.getIconPos(this.ROIPositions);
            if isempty(this.SublabelName)
                labelName=this.Label;
            else
                labelName=this.SublabelName;
            end
            this.hLabelIcon=text('Parent',this.AxesHandle,...
            'Position',labelPos,...
            'BackgroundColor',this.Color,'String',labelName,...
            'Tag','category','Interpreter','none','Clipping','on');
            if showLabel
                this.hLabelIcon.Visible='on';
            else
                this.hLabelIcon.Visible='off';
            end
        end
    end
end