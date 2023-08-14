










classdef StaticCuboid<handle
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

        function this=StaticCuboid(rois,hAx,color,labelName,sublabelName,selfUID,parentUID,showLabel,roiVisibility)















            rois(:,1:3)=rois(:,1:3)-0.5*rois(:,4:6);
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
                constructCuboidView(this,n);
                addLabel(this,n,showLabel);
            end
        end


        function constructCuboidView(this,n)


            pointsPerInch=72;
            pixelsPerInch=get(0,'ScreenPixelsPerInch');
            lineWidth=pointsPerInch/pixelsPerInch;

            positions=this.ROIPositions(n,:);
            x=positions(1);
            y=positions(2);
            z=positions(3);
            w=positions(4);
            h=positions(5);
            d=positions(6);

            X=[x;x;x+w;x+w;x;x;x;x+w;...
            x+w;x;x;x;x;x+w;x+w;x+w;x+w;x+w];
            Y=[y;y+h;y+h;y;y;y;y+h;...
            y+h;y;y;y+h;y+h;y+h;y+h;...
            y+h;y+h;y;y];
            Z=[z;z;z;z;z;z+d;z+d;z+d;z+d;...
            z+d;z+d;z;z+d;z+d;z;z+d;z+d;z];



            if positions(9)~=0
                yaw=positions(9);
                R=[cosd(yaw),-sind(yaw);sind(yaw),cosd(yaw)];
                centerX=x+w*0.5;
                centerY=y+h*0.5;
                coords=horzcat((X-centerX),(Y-centerY));

                rotatedCoords=R*coords';
                X=(rotatedCoords(1,:)+centerX);
                Y=(rotatedCoords(2,:)+centerY);
            end

            this.hStaticLine{n}=line(X,Y,Z,'Parent',this.Group,...
            'Color',this.Color,...
            'LineWidth',1.5*lineWidth,...
            'Tag','staticRectangeROI',...
            'Visible',this.ROIVisibility,...
            'HandleVisibility','off');
        end


        function addLabel(this,n,showLabel)

            roiPositions=this.ROIPositions(n,:);
            if isempty(char(this.SublabelName))
                labelName=this.Label;
            else
                labelName=this.SublabelName;
            end
            this.hLabelIcons{n}=text('Parent',this.Group,...
            'BackgroundColor',this.Color,'String',labelName,...
            'Tag','category','Interpreter','none','Clipping','on',...
            'Margin',1,'VerticalAlignment','bottom');
            labelPos=[roiPositions(1),...
            roiPositions(2),roiPositions(3)];
            this.hLabelIcons{n}.Position=labelPos;
            if showLabel
                this.hLabelIcons{n}.Visible='on';
            else
                this.hLabelIcons{n}.Visible='off';
            end
        end
    end
end