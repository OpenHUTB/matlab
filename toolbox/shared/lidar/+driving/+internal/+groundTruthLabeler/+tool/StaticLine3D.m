











classdef StaticLine3D<handle
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
hStaticPoints
hLabelIcons
    end

    properties(Dependent)
Visible
    end




    methods

        function this=StaticLine3D(rois,hAx,color,labelName,sublabelName,selfUID,parentUID,showLabel,roiVisibility)















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
            delete(this.hStaticLine);
            delete(this.hStaticPoints);
            delete(this.hLabelIcons);
        end


        function set.Visible(this,onOff)
            set(this.hStaticLine,'Visible',onOff);
            set(this.hStaticPoints,'Visible',onOff);
            set(this.hLabelIcons,'Visible',onOff);
        end


        function setTextLabelVisible(this,showLabel)
            if showLabel
                this.hLabelIcons.Visible='on';
            else
                this.hLabelIcons.Visible='off';
            end

        end
    end

    methods(Access=private)

        function drawStaticROIs(this,showLabel)
            constructLine3DView(this);
            constructVertices(this);
            addLabel(this,showLabel);
        end


        function constructLine3DView(this)

            pos=this.ROIPositions;
            lineSize=vision.internal.videoLabeler.tool.LaneMarkerWidget.getLineSize();
            this.hStaticLine=line(pos(:,1),pos(:,2),pos(:,3),...
            'Parent',this.AxesHandle,...
            'Color',this.Color,...
            'LineWidth',lineSize,...
            'HitTest','off',...
            'Visible',this.ROIVisibility,...
            'Tag','lanemarkerline');
        end


        function constructVertices(this)
            pos=this.ROIPositions;
            markerSize=vision.internal.videoLabeler.tool.LaneMarkerWidget.getCircleSize();
            for inx=1:size(pos,1)
                this.hStaticPoints(inx)=line(pos(inx,1),pos(inx,2),pos(inx,3),...
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


        function addLabel(this,showLabel)
            labelPos=vision.internal.videoLabeler.tool.LaneMarkerWidget.getIconPos(this.ROIPositions);
            if isempty(this.SublabelName)
                labelName=this.Label;
            else
                labelName=this.SublabelName;
            end
            this.hLabelIcons=text('Parent',this.AxesHandle,...
            'Position',labelPos,...
            'BackgroundColor',this.Color,'String',labelName,...
            'Tag','category','Interpreter','none','Clipping','on');
            if showLabel
                this.hLabelIcons.Visible='on';
            else
                this.hLabelIcons.Visible='off';
            end
        end
    end
end