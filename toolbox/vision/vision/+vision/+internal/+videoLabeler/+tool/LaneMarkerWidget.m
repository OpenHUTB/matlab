classdef LaneMarkerWidget<handle




    events
Move
Delete
Copy
Cut
VertexAdded
VertexRemoved
Selected
    end

    properties
FigureHandle
AxesHandle
ShowLabel
LabelName
    end

    properties(Hidden)
ParentName
SelfUID
ParentUID
    end

    properties

XMin
XMax
YMin
YMax
    end

    properties(GetAccess=public,SetAccess=private)
Position
    end

    properties(Access=private)
NumPoints
OldWindowButtonMotionFcn
OldFigurePointer
LineHandle
PointHandle
ButtonDownEvt
LabelIconHandle
TransparentOverlay

VertexContextMenu
WidgetContextMenu
Color
IsWidgetSelected
StartLocation
    end

    properties(Access=private)

start_position
new_position
drag_motion_callback_id
drag_up_callback_id
currentPointIdx


start_all_positions
MaxXShiftToRight
MaxXShiftToLeft
MaxYShiftToTop
MaxYShiftToBot
IsNormalXDir
IsNormalYDir
    end

    properties(Dependent)
IsSelected
CopiedData
IsValid
    end

    methods
        function this=LaneMarkerWidget(hFig,hAxes,hImage,color,label,...
            parentName,...
            selfUID,parentUID,...
            showLabel,~)
            this.FigureHandle=hFig;
            this.AxesHandle=hAxes;

            this.NumPoints=0;
            this.Color=color;
            this.IsWidgetSelected=false;
            this.ShowLabel=showLabel;
            this.LabelName=label;
            this.ParentName=parentName;
            this.SelfUID=selfUID;
            this.ParentUID=parentUID;





            imageLimits=size(get(hImage,'CData'));
            xLim=[1,imageLimits(2)];
            yLim=[1,imageLimits(1)];

            this.StartLocation=getCurrentAxesPoint(this);

            this.XMin=xLim(1);
            this.XMax=xLim(2);
            this.YMin=yLim(1);
            this.YMax=yLim(2);
        end

        function isValid=get.IsValid(this)

            isValid=~isempty(this.Position)&&(this.NumPoints>1)&&all(isvalid(this.PointHandle));
        end

        function copiedData=get.CopiedData(this)
            copiedData.Position=this.Position;
            copiedData.categoryID=1;
            copiedData.categoryName=this.LabelName;
            copiedData.parentName=this.ParentName;
            copiedData.color=this.Color;
            copiedData.shape='line';
            copiedData.selfUID=this.SelfUID;
            copiedData.parentUID=this.ParentUID;
        end

        function enhance(this)

            createLabelIcon(this);
        end

        function createLabelIcon(this)
            labelPos=this.getEnhancedIconPositions();

            this.LabelIconHandle=text('parent',this.AxesHandle,...
            'backgroundcolor',this.getCurrentColor(),'string',this.LabelName,...
            'tag','category','Interpreter','none',...
            'Clipping','on',...
            'Position',labelPos,...
            'ButtonDownFcn',@(~,~)determineSelectionStatus(this));
            if this.ShowLabel
                this.LabelIconHandle.Visible='on';
            else
                this.LabelIconHandle.Visible='off';
            end
        end


        function setTextLabelVisible(this,showLabel)
            this.ShowLabel=showLabel;
            if this.IsValid
                if this.ShowLabel
                    this.LabelIconHandle.Visible='on';
                else
                    this.LabelIconHandle.Visible='off';
                end
            end
        end

        function setColor(this,color)
            this.Color=color;
            lineH=getInteractiveLine(this);
            lineH.Color=color;
            set(this.PointHandle,'MarkerFaceColor',color);
        end

        function setPosition(this,pos)
            assert(size(pos,2)==2,'n x 2 array of points is expected');


            cleanupGraphics(this);
            this.NumPoints=0;
            this.Position=[];

            numPoints=size(pos,1);
            X=pos(:,1);
            Y=pos(:,2);
            for inx=1:numPoints
                addVertex(this,X(inx),Y(inx));
            end
            this.updateView();
            makeLineDraggable(this);
        end

        function delete(this)

            if~isempty(this.ButtonDownEvt)&&isvalid(this.ButtonDownEvt)
                delete(this.ButtonDownEvt);
            end
            cleanupGraphics(this);
        end

        function beginInteractivePlacement(this)




            hParent=this.AxesHandle;
            this.TransparentOverlay=axes('Parent',get(hParent,'Parent'),...
            'Units',get(hParent,'Units'),'Position',get(hParent,'Position'),...
            'Visible','off','HitTest','on',...
            'XLim',get(hParent,'XLim'),'YLim',get(hParent,'YLim'),...
            'YDir',get(hParent,'YDir'));








            funcUpdatePosition=@(hobj,evt)set(this.TransparentOverlay,'Position',get(hParent,'Position'));

            positionChangedListener=event.proplistener(hParent,...
            hParent.findprop('Position'),'PostSet',funcUpdatePosition);



            setappdata(this.TransparentOverlay,'PostSetListener',positionChangedListener);

            this.ButtonDownEvt=event.listener(this.FigureHandle,...
            'WindowMousePress',@(src,evt)onAxesClick(this));
            this.OldWindowButtonMotionFcn=this.FigureHandle.WindowButtonMotionFcn;
            this.OldFigurePointer=this.FigureHandle.Pointer;
            this.FigureHandle.WindowButtonMotionFcn=@(src,~)animateConnectionLine(this);


            uistack(this.TransparentOverlay,'top');

            this.TransparentOverlay.PickableParts='all';


            this.addVertex(this.StartLocation(1),this.StartLocation(2));

            iptPointerManager(this.FigureHandle);
            iptSetPointerBehavior(this.TransparentOverlay,@(~,~)set(this.FigureHandle,'Pointer','crosshair'));
            uiwait(this.FigureHandle);
        end

        function endInteractivePlacement(this)
            updateView(this);

            makeLineDraggable(this);

            delete(this.ButtonDownEvt);
            delete(this.TransparentOverlay);
            this.FigureHandle.Pointer=this.OldFigurePointer;
            this.FigureHandle.WindowButtonMotionFcn=this.OldWindowButtonMotionFcn;
            uiresume(this.FigureHandle);
        end

        function cMenu=getVertexContextMenu(this,pointHandle)
            cMenu=uicontextmenu(this.FigureHandle);
            uimenu(cMenu,'Label','Delete','Callback',@(~,evt)deleteVertex(this,pointHandle));
        end

        function cMenu=getWidgetContextMenu(this)
            if isempty(this.WidgetContextMenu)
                cMenu=uicontextmenu(this.FigureHandle);
                uimenu(cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuAddPoint'),'Callback',...
                @(~,~)onLineClickAddVertex(this),...
                'tag','contextAddPoint');
                uimenu(cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCopy'),...
                'Callback',@(~,~)selectAndNotify(this,'Copy'),...
                'Accelerator','C');
                uimenu(cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuCut'),...
                'Callback',@(~,~)selectAndNotify(this,'Cut'),...
                'Accelerator','X');
                uimenu(cMenu,'Label',vision.getMessage('vision:labeler:ContextMenuDelete'),...
                'Callback',@(~,~)this.doDeleteROI);
                this.WidgetContextMenu=cMenu;
            end
            cMenu=this.WidgetContextMenu;
        end

        function tf=get.IsSelected(this)
            tf=this.IsWidgetSelected;
        end

        function set.IsSelected(this,val)

            if val
                if~this.IsWidgetSelected
                    this.doHighlight();
                end
            else
                if this.IsWidgetSelected
                    this.undoHighlight();
                end
            end
            this.IsWidgetSelected=val;
        end

        function[labelPos,deletePos]=getEnhancedIconPositions(this)
            [labelPos,deletePos]=this.getIconPos(this.Position);
        end
    end

    methods(Access='protected')
        function toggleWidgetSelection(this)
            this.IsSelected=~this.IsSelected;
        end

        function selectAndNotify(this,eventName)
            this.IsSelected=true;
            notify(this,eventName);
        end

        function[constrainedX,constrainedY]=getConstrainedPosition(this,X,Y)
            constrainedX=min(max(X,this.XMin),this.XMax);
            constrainedY=min(max(Y,this.YMin),this.YMax);
        end

        function initializeMinMaxDeltaPositions(this)
            startPositions=this.start_all_positions;
            isNormalXDir=strcmp(this.AxesHandle.XDir,'normal');
            isNormalYDir=strcmp(this.AxesHandle.YDir,'normal');

            if isNormalXDir
                leftmostPoint=min(startPositions(:,1));
                rightmostPoint=max(startPositions(:,1));
                this.MaxXShiftToRight=abs(rightmostPoint-this.XMax);
                this.MaxXShiftToLeft=abs(leftmostPoint-this.XMin);
            else
                leftmostPoint=max(startPositions(:,1));
                rightmostPoint=min(startPositions(:,1));
                this.MaxXShiftToRight=abs(rightmostPoint-this.XMin);
                this.MaxXShiftToLeft=abs(leftmostPoint-this.XMax);
            end

            if isNormalYDir
                topmostPoint=max(startPositions(:,2));
                bottommostPoint=min(startPositions(:,2));
                this.MaxYShiftToTop=abs(topmostPoint-this.YMax);
                this.MaxYShiftToBot=abs(bottommostPoint-this.YMin);
            else
                topmostPoint=min(startPositions(:,2));
                bottommostPoint=max(startPositions(:,2));
                this.MaxYShiftToTop=abs(topmostPoint-this.YMin);
                this.MaxYShiftToBot=abs(bottommostPoint-this.YMax);
            end

            this.IsNormalXDir=isNormalXDir;
            this.IsNormalYDir=isNormalYDir;
        end

        function[constrainedDeltaX,constrainedDeltaY]=getConstrainedDeltaPosition(this,deltaX,deltaY)


            isShiftRight=deltaX>0&&this.IsNormalXDir||...
            deltaX<0&&~this.IsNormalXDir;

            isShiftUp=deltaY>0&&this.IsNormalYDir||...
            deltaY<0&&~this.IsNormalYDir;

            if isShiftRight
                constrainedDeltaX=min(this.MaxXShiftToRight,abs(deltaX));
            else
                constrainedDeltaX=min(this.MaxXShiftToLeft,abs(deltaX));
            end
            constrainedDeltaX=sign(deltaX)*constrainedDeltaX;

            if isShiftUp
                constrainedDeltaY=min(this.MaxYShiftToTop,abs(deltaY));
            else
                constrainedDeltaY=min(this.MaxYShiftToBot,abs(deltaY));
            end
            constrainedDeltaY=sign(deltaY)*constrainedDeltaY;
        end

        function doDeleteROI(this)
            cleanupGraphics(this);
            this.Position=[];
            this.NumPoints=0;
            evtData=vision.internal.videoLabeler.tool.LaneMarkerDeletedEvent(this.IsSelected);
            notify(this,'Delete',evtData);
        end

        function clickPos=getCurrentAxesPoint(this)
            cP=this.AxesHandle.CurrentPoint;
            clickPos=[cP(1,1),cP(1,2)];
        end

        function[new_ind,x_line,y_line]=getInsertVertex(this,mouse_pos)

            xPoints=this.LineHandle.XData;
            yPoints=this.LineHandle.YData;

            numVertices=this.NumPoints;

            pos=[xPoints',yPoints'];


            if numVertices<2

                new_ind=numVertices+1;
                x_line=xPoints(new_ind-1:new_ind);
                y_line=yPoints(new_ind-1:new_ind);
            else




                lineSegVector=diff(pos);
                pointVectorFromSegmentStartPoint=mouse_pos-pos(1:end-1,:);
                lineSegNormSquared=sum(lineSegVector.^2,2);
                projectionDotProduct=sum(lineSegVector.*pointVectorFromSegmentStartPoint,2);
                projDistance=projectionDotProduct./lineSegNormSquared;



                projVector=lineSegVector.*[projDistance,projDistance];
                normalVectorFromPointToLineProj=mouse_pos-projVector;
                normVectorDistances=sum(normalVectorFromPointToLineProj.^2,2);



                normVectorDistances(projDistance<0|projDistance>1)=Inf;
                [~,new_ind]=min(normVectorDistances);
                new_ind=new_ind+1;
                x_line=xPoints(new_ind-1:new_ind);
                y_line=yPoints(new_ind-1:new_ind);
            end
        end

        function insertPos=getPositionOnLine(~,x_line,y_line,mouse_pos)










            v1=[diff(x_line),diff(y_line)];


            v2=[mouse_pos(1)-x_line(1),mouse_pos(2)-y_line(1)];



            insertPos=(dot(v1,v2)./dot(v1,v1)).*v1+[x_line(1),y_line(1)];

        end

        function makeLineDraggable(this)

            set(this.LineHandle,'ButtonDownFcn',@(~,~)startLineDrag(this));

            iptPointerManager(this.FigureHandle);
            iptSetPointerBehavior(this.LineHandle,@(~,~)set(this.FigureHandle,'Pointer','fleur'));
        end

        function doHighlight(this)
            lineH=getInteractiveLine(this);
            lineH.Color='y';
            set(this.PointHandle,'MarkerFaceColor','y');
            if~isempty(this.LabelIconHandle)
                set(this.LabelIconHandle,'backgroundcolor','y');
            end
        end

        function undoHighlight(this)

            lineH=getInteractiveLine(this);
            lineH.Color=this.Color;
            set(this.PointHandle,'MarkerFaceColor',this.Color);
            if~isempty(this.LabelIconHandle)
                set(this.LabelIconHandle,'backgroundcolor',this.Color);
            end
        end

        function cleanupGraphics(this)
            pointH=this.PointHandle;
            for inx=1:length(pointH)
                if ishandle(pointH(inx))&&isvalid(pointH(inx))
                    delete(pointH(inx));
                end
            end
            this.PointHandle=[];
            if~isempty(this.LineHandle)&&ishandle(this.LineHandle)&&...
                isvalid(this.LineHandle)
                delete(this.LineHandle);
            end
            this.LineHandle=[];

            if~isempty(this.LabelIconHandle)&&ishandle(this.LabelIconHandle)&&...
                isvalid(this.LabelIconHandle)
                delete(this.LabelIconHandle);
            end
        end

        function deleteVertex(this,pointH)

            idx=this.PointHandle==pointH;
            this.Position(idx,:)=[];
            this.PointHandle(idx)=[];
            delete(pointH);
            this.NumPoints=this.NumPoints-1;

            if this.NumPoints<=1
                doDeleteROI(this);
                return;
            end
            this.updateView();
            evtData=vision.internal.videoLabeler.tool.LaneMarkerDeletedEvent(this.IsSelected);
            notify(this,'VertexRemoved',evtData);
        end

        function onLineClickAddVertex(this)
            clickPos=getCurrentAxesPoint(this);
            x=clickPos(1);
            y=clickPos(2);
            mouse_pos=[x,y];
            [new_ind,x_line,y_line]=getInsertVertex(this,mouse_pos);
            insertPos=getPositionOnLine(this,x_line,y_line,mouse_pos);
            addVertex(this,insertPos(1),insertPos(2),new_ind);
            updateView(this);
            notify(this,'VertexAdded');
        end

        function completed=onAxesClick(this)
            h_fig=this.FigureHandle;
            is_double_click=strcmp(get(h_fig,'SelectionType'),'open');
            is_right_click=strcmp(get(h_fig,'SelectionType'),'alt');
            is_left_click=strcmp(get(h_fig,'SelectionType'),'normal');

            if~is_left_click&&isempty(this.Position)
                completed=false;
                return
            end

            completed=is_double_click||is_right_click;



            if completed
                this.endInteractivePlacement();
            else
                clickPos=getCurrentAxesPoint(this);
                addVertex(this,clickPos(1),clickPos(2));
            end
        end

        function addVertex(this,x,y,vertexNum)


            [constrainedX,constrainedY]=this.getConstrainedPosition(x,y);
            if nargin<4

                vertexNum=this.NumPoints+1;
                this.Position(vertexNum,:)=[constrainedX,constrainedY];
            else

                xPos=this.Position(:,1);
                yPos=this.Position(:,2);
                xPos=[xPos(1:vertexNum-1);constrainedX;xPos(vertexNum:end)];
                yPos=[yPos(1:vertexNum-1);constrainedY;yPos(vertexNum:end)];
                this.Position=[xPos,yPos];
            end
            this.NumPoints=this.NumPoints+1;
            drawPoint(this,x,y,vertexNum);
        end

        function color=getCurrentColor(this)
            if this.IsSelected
                color='y';
            else
                color=this.Color;
            end
        end

        function hPoint=drawPoint(this,x,y,vertexNum)
            hPoint=line(x,y,...
            'Parent',this.AxesHandle,...
            'Marker','o',...
            'MarkerFaceColor',this.getCurrentColor(),...
            'Clipping','on',...
            'MarkerSize',this.getCircleSize(),...
            'Tag','circle',...
            'ButtonDownFcn',@(src,~)startVertexDrag(this,src));
            set(hPoint,'UIContextMenu',this.getVertexContextMenu(hPoint));

            if nargin<4

                this.PointHandle(end+1)=hPoint;
            else

                pointHandles=this.PointHandle;
                this.PointHandle=[pointHandles(1:vertexNum-1),hPoint,pointHandles(vertexNum:end)];
            end

            iptSetPointerBehavior(hPoint,@(~,~)set(this.FigureHandle,'Pointer','circle'));
        end

        function animateConnectionLine(this)


            if~isempty(this.Position)
                pos=get(this.AxesHandle,'CurrentPoint');
                x=[this.Position(:,1);pos(1,1)];
                y=[this.Position(:,2);pos(1,2)];
                lineH=getInteractiveLine(this);
                set(lineH,'XData',x,'YData',y);
            end
        end

        function lineH=getInteractiveLine(this)
            if isempty(this.LineHandle)
                this.LineHandle=line('Parent',this.AxesHandle,...
                'Color',this.getCurrentColor(),...
                'LineWidth',this.getLineSize(),...
                'Tag','lineROI',...
                'UIContextMenu',this.getWidgetContextMenu());
            end
            lineH=this.LineHandle;
        end

        function updateView(this)

            if~isempty(this.Position)
                lineH=getInteractiveLine(this);
                X=this.Position(:,1);
                Y=this.Position(:,2);
                set(lineH,'XData',X,'YData',Y);
            end
        end

        function startVertexDrag(this,hPoint)
            h_fig=this.FigureHandle;
            if strcmp(get(h_fig,'SelectionType'),'normal')


                iptPointerManager(h_fig,'disable');


                currentPoint=getCurrentAxesPoint(this);
                start_x=currentPoint(1);
                start_y=currentPoint(2);

                this.start_position=[start_x,start_y];
                this.new_position=[start_x,start_y];

                this.currentPointIdx=find(this.PointHandle==hPoint);

                this.drag_motion_callback_id=iptaddcallback(h_fig,...
                'WindowButtonMotionFcn',...
                @(~,~)dragVertexMotion(this,hPoint));

                this.drag_up_callback_id=iptaddcallback(h_fig,...
                'WindowButtonUpFcn',...
                @(~,~)stopVertexDrag(this,hPoint));
            end
        end

        function dragVertexMotion(this,hPoint)
            currentPoint=getCurrentAxesPoint(this);
            new_x=currentPoint(1);
            new_y=currentPoint(2);
            delta_x=new_x-this.start_position(1,1);
            delta_y=new_y-this.start_position(1,2);

            candidate_position=this.start_position+[delta_x,delta_y];
            [newX,newY]=this.getConstrainedPosition(candidate_position(1),candidate_position(2));
            new_pos=[newX,newY];

            if~isequal(new_pos,this.start_position)
                set(hPoint,'XData',newX,'YData',newY);
                this.Position(this.currentPointIdx,:)=new_pos;
                this.updateView();
                updateEnhancedIconPositions(this);
                this.new_position=new_pos;
            end
        end

        function stopVertexDrag(this,~)
            h_fig=this.FigureHandle;
            iptremovecallback(h_fig,'WindowButtonMotionFcn',...
            this.drag_motion_callback_id);
            iptremovecallback(h_fig,'WindowButtonUpFcn',...
            this.drag_up_callback_id);


            iptPointerManager(h_fig,'enable');

            if~isequal(this.new_position,this.start_position)
                notify(this,'Move');
            else


                toggleWidgetSelection(this);
            end
        end

        function startLineDrag(this)
            h_fig=this.FigureHandle;
            if strcmp(get(h_fig,'SelectionType'),'normal')


                iptPointerManager(h_fig,'disable');


                currentPoint=getCurrentAxesPoint(this);
                start_x=currentPoint(1);
                start_y=currentPoint(2);

                this.start_position=[start_x,start_y];
                this.start_all_positions=this.Position;
                initializeMinMaxDeltaPositions(this);
                this.new_position=[start_x,start_y];

                this.drag_motion_callback_id=iptaddcallback(h_fig,...
                'WindowButtonMotionFcn',...
                @(~,~)dragLineMotion(this));

                this.drag_up_callback_id=iptaddcallback(h_fig,...
                'WindowButtonUpFcn',...
                @(~,~)stopLineDrag(this));
            end
            determineSelectionStatus(this);
        end

        function dragLineMotion(this)
            currentPoint=getCurrentAxesPoint(this);
            new_x=currentPoint(1);
            new_y=currentPoint(2);
            delta_x=new_x-this.start_position(1,1);
            delta_y=new_y-this.start_position(1,2);

            candidate_position=this.start_position+[delta_x,delta_y];
            [newX,newY]=this.getConstrainedPosition(candidate_position(1),candidate_position(2));
            new_pos=[newX,newY];
            if~isequal(new_pos,this.start_position)
                [cdelta_x,cdelta_y]=getConstrainedDeltaPosition(this,delta_x,delta_y);
                delta_pos=[cdelta_x,cdelta_y];
                newPositions=this.start_all_positions+repmat(delta_pos,[this.NumPoints,1]);
                this.Position=newPositions;
                for inx=1:length(newPositions)
                    set(this.PointHandle(inx),'XData',newPositions(inx,1),'YData',newPositions(inx,2));
                end
                this.updateView();
                updateEnhancedIconPositions(this);
                this.new_position=this.start_position+delta_pos;
            end
        end

        function stopLineDrag(this,~)
            h_fig=this.FigureHandle;
            iptremovecallback(h_fig,'WindowButtonMotionFcn',...
            this.drag_motion_callback_id);
            iptremovecallback(h_fig,'WindowButtonUpFcn',...
            this.drag_up_callback_id);


            iptPointerManager(h_fig,'enable');

            if~isequal(this.new_position,this.start_position)
                notify(this,'Move');
            end
        end

        function updateEnhancedIconPositions(this)
            labelPos=this.getEnhancedIconPositions();
            if~isempty(this.LabelIconHandle)
                this.LabelIconHandle.Position=labelPos;
            end

        end

        function determineSelectionStatus(this)


            figH=this.FigureHandle;
            clickType=get(figH,'SelectionType');
            leftClick=strcmp(clickType,'normal');
            ctrlPressed=strcmp(get(figH,'CurrentModifier'),'control');
            rightClick=strcmp(clickType,'alt')&isempty(ctrlPressed);
            ctrlClick=strcmp(clickType,'alt')&~isempty(ctrlPressed);

            if leftClick||rightClick
                if~this.IsSelected




                    this.IsSelected=true;
                    notify(this,'Selected');
                end
            elseif ctrlClick
                toggleWidgetSelection(this);
            end
        end
    end

    methods(Static)
        function circle_size_points=getCircleSize()
            points_per_inch=72;
            pixels_per_inch=get(0,'ScreenPixelsPerInch');
            circle_diameter_pixels=5;
            points_per_screen_pixel=points_per_inch/pixels_per_inch;
            circle_size_points=2*circle_diameter_pixels*points_per_screen_pixel;
        end

        function line_size_points=getLineSize()
            points_per_inch=72;
            pixels_per_inch=get(0,'ScreenPixelsPerInch');
            points_per_screen_pixel=points_per_inch/pixels_per_inch;
            line_size_points=3*points_per_screen_pixel;
        end

        function[labelPos,deletePos]=getIconPos(pos)
            minPos=pos(1,:);
            xMin=minPos(1);yMin=minPos(2);
            maxPos=pos(end,:);
            xMax=maxPos(1);yMax=maxPos(2);
            labelPos=[xMin+10,yMin+5];
            deletePos=[xMax+15,yMax];
        end
    end

end

