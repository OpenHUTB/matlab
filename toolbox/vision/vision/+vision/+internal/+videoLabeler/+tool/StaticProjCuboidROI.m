











classdef StaticProjCuboidROI<handle
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





hStaticLine_solid
hStaticLine_dashed
hLabelIcons
    end

    properties(Dependent)
Visible
    end




    methods

        function this=StaticProjCuboidROI(rois,hAx,color,labelName,sublabelName,selfUID,parentUID,showLabel,roiVisibility)
















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

            drawStaticProjCuboidROIs(this,showLabel);
        end


        function delete(this)
            if ishghandle(this.Group)
                delete(this.Group);
            end
        end


        function set.Visible(this,onOff)

            for n=1:numel(this.hStaticLine_solid)
                set(this.hStaticLine_solid{n},'Visible',onOff);
                set(this.hStaticLine_dashed{n},'Visible',onOff);
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

        function drawStaticProjCuboidROIs(this,showLabel)

            for n=1:size(this.ROIPositions,1)
                constructRectView(this,n);
                addLabel(this,n,showLabel);
            end
        end


        function constructRectView(this,n)

...
...
...
...
...
...
...
...
...
...
...
...
...
...
...

            pointsPerInch=72;
            pixelsPerInch=get(0,'ScreenPixelsPerInch');
            lineWidth=pointsPerInch/pixelsPerInch;

            positions=this.ROIPositions(n,:);

            positions(1)=positions(1)-0.5;
            positions(2)=positions(2)-0.5;
            positions(5)=positions(5)-0.5;
            positions(6)=positions(6)-0.5;
            [x,y,~,numSolidPts]=getLineData(this,positions);

            xSolid=x(1:numSolidPts);
            ySolid=y(1:numSolidPts);
            xDashed=x((numSolidPts+1):end);
            yDashed=y((numSolidPts+1):end);

            this.hStaticLine_solid{n}=line(xSolid,ySolid,'Parent',this.Group,...
            'Color',this.Color,...
            'LineWidth',3*lineWidth,...
            'LineStyle','-',...
            'Tag','staticRectangeROI',...
            'Visible',this.ROIVisibility,...
            'HandleVisibility','off');

            this.hStaticLine_dashed{n}=line(xDashed,yDashed,'Parent',this.Group,...
            'Color',this.Color,...
            'LineWidth',3*lineWidth,...
            'LineStyle','--',...
            'Tag','staticRectangeROI',...
            'Visible',this.ROIVisibility,...
            'HandleVisibility','off');
        end


        function addLabel(this,n,showLabel)

            roiPositions=this.ROIPositions(n,:)-[0.5,0.5,0,0,0.5,0.5,0,0];
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

    methods(Access=private)
        function[a,b,c,d,e,f,g,h]=get8Points(~,pos)

            if isempty(pos)
                a=[];
                b=[];
                c=[];
                d=[];
                e=[];
                f=[];
                g=[];
                h=[];
                return;
            end

            posFace1=pos(1:4);
            posFace2=pos(5:8);

            if(posFace1(1)==posFace2(1))&&...
                (posFace1(2)==posFace2(2))


                posFace2(3)=posFace1(3);
                posFace2(4)=posFace1(4);
            end


            x8=posFace1(1);
            x7=x8;
            x6=x8+posFace1(3);
            x5=x6;

            y8=posFace1(2);
            y7=y8+posFace1(4);
            y6=y7;
            y5=y8;

            a=[x8,y8];
            b=[x7,y7];
            c=[x6,y6];
            d=[x5,y5];


            x13=posFace2(1);
            x14=x13+posFace2(3);
            x15=x14;
            x16=x13;

            y13=posFace2(2);
            y14=y13;
            y15=y14+posFace2(4);
            y16=y15;

            e=[x13,y13];
            f=[x16,y16];
            g=[x15,y15];
            h=[x14,y14];
        end


        function[x,y,z,numSolidPts]=getLineData(this,pos)

            if isempty(pos)
                x=[];
                y=[];
                z=[];
                numSolidPts=0;
            else

                [a,b,c,d,e,f,g,h]=get8Points(this,pos);

                linePtsSolid=[a;b;c;d;h;e;a;d];
                isRightSolid=(h(1)>d(1));
                isLeftSolid=(e(1)<a(1));
                if isRightSolid&&isLeftSolid
                    linePtsSolid=[linePtsSolid;c;g;h;e;f;b];
                    linePtsDotted=[f;g];
                elseif isRightSolid&&~isLeftSolid
                    linePtsSolid=[linePtsSolid;c;g;h];
                    linePtsDotted=[b;f;e;f;g];
                elseif~isRightSolid&&isLeftSolid
                    linePtsSolid=[linePtsSolid;a;b;f;e];
                    linePtsDotted=[c;g;h;g;f];
                elseif~isRightSolid&&~isLeftSolid
                    linePtsDotted=[b;f;e;f;g;h;g;c];
                end



                xSolid=linePtsSolid(:,1);
                ySolid=linePtsSolid(:,2);
                zSolid=zeros(size(xSolid));

                xDotted=linePtsDotted(:,1);
                yDotted=linePtsDotted(:,2);
                zDotted=zeros(size(xDotted));

                x=[xSolid;xDotted];
                y=[ySolid;yDotted];
                z=[zSolid;zDotted];

                numSolidPts=length(xSolid);
            end
        end

    end
end
