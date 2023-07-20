





classdef AngleTool<lidar.internal.lidarViewer.measurementTool.AbstractTool



    properties(Constant)


        ToolName='Angle Tool'

    end

    properties(Access=private)


TrianglePositions

AxesHandle
    end

    properties

        AllTools=[]
    end

    events
ROIClicked
ObjectAdded
ObjectDeleted
DisableToolstrip
UpdateUndoRedoStack
DeleteFromUndoRedoStack
    end




    methods

        function createToolObj(this,pos,axesHandle)

            this.AllTools{end+1}(1)=create3DlineObj(this,axesHandle,0);
            this.AllTools{end}(1).Position=pos([1,2],:);
            this.AllTools{end}(1).setSnapToPoints(axesHandle.Children(end));

            this.AllTools{end}(2)=create3DlineObj(this,axesHandle,0);
            this.AllTools{end}(2).Position=pos([2,3],:);
            this.AllTools{end}(2).setSnapToPoints(axesHandle.Children(end));

            this.AllTools{end}(3)=create3DlineObj(this,axesHandle,0);
            this.AllTools{end}(3).Position=pos([3,1],:);
            this.AllTools{end}(3).setSnapToPoints(axesHandle.Children(end));

            this.AxesHandle=axesHandle;


            cMenu=this.AllTools{end}(1).UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteAngleMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);

            cMenu=this.AllTools{end}(2).UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteAngleMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);

            cMenu=this.AllTools{end}(3).UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteAngleMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);


            this.installListenersMeasureAngle(1);

            this.installListenersMeasureAngle(2);

            this.installListenersMeasureAngle(3);


            this.TrianglePositions=[pos(1,:);pos(2,:);pos(3,:)];
            this.calculateAngle(this.TrianglePositions,numel(this.AllTools));
            set(this.AllTools{end}(1:3),'Layer','front');

        end


        function doMeasureMetric(this,axesHandle,cMap,~)


            this.AllTools{end+1}(1)=create3DlineObj(this,axesHandle,cMap);

            this.AllTools{end}(2)=create3DlineObj(this,axesHandle,cMap);

            this.AllTools{end}(3)=create3DlineObj(this,axesHandle,cMap);

            this.AxesHandle=axesHandle;


            if isempty(axesHandle.Toolbar.Tag)
                this.updateAllInteractions(true,axesHandle);
            else
                this.updateAllInteractions(false,axesHandle);
            end


            cMenu=this.AllTools{end}(1).UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteAngleMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);

            cMenu=this.AllTools{end}(2).UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteAngleMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);

            cMenu=this.AllTools{end}(3).UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteAngleMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);


            this.installListenersMeasureAngle(1);
            this.AllTools{end}(1).draw(axesHandle.Children(end));
            if~isvalid(axesHandle)
                return;
            end

            notify(this,'DisableToolstrip');

            if~isvalid(this.AllTools{end}(1))
                delete(this.AllTools{end});
                evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
                notify(this,'ObjectDeleted',evt);
                return;
            end


            if size(this.AllTools{end}(1).Position,1)==1
                dialogueBoxPopUp(this,axesHandle);
                return;
            end

            this.installListenersMeasureAngle(2);
            beginDrawingFromPoint(this.AllTools{end}(2),this.AllTools{end}(1).Position(2,:));

            if~isvalid(this.AllTools{end}(2))
                return;
            end

            if isempty(this.AllTools{end}(2).Position)
                delete(this.AllTools{end});
                evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
                notify(this,'ObjectDeleted',evt);
                return;
            end

            this.AllTools{end}(2).setSnapToPoints(axesHandle.Children(end));
            this.installListenersMeasureAngle(3);


            if size(this.AllTools{end}(2).Position,1)==1
                dialogueBoxPopUp(this,axesHandle);
                return;
            end

            this.AllTools{end}(3).Position=[this.AllTools{end}(2).Position(2,:);...
            this.AllTools{end}(1).Position(1,:)];
            this.AllTools{end}(3).setSnapToPoints(axesHandle.Children(end));


            this.TrianglePositions=[this.AllTools{end}(1).Position;...
            this.AllTools{end}(2).Position(2,:)];
            this.calculateAngle(this.TrianglePositions,numel(this.AllTools));

            for i=1:3
                this.AllTools{end}(i).Parent=axesHandle;
                this.AllTools{end}(i).Selected=true;
            end
        end


        function stopMeasuringMetric(this,isUserMeasuring)


            for i=1:numel(this.AllTools)
                if isUserMeasuring
                    this.AllTools{i}(1).stopDrawing();
                    this.AllTools{i}(2).stopDrawing();
                    this.AllTools{i}(3).stopDrawing();
                end

                delete(this.AllTools{i}(1));
                delete(this.AllTools{i}(2));
                delete(this.AllTools{i}(3));
            end
            this.AllTools={};
        end
    end




    methods(Access=private)


        function installListenersMeasureAngle(this,j)


            addlistener(this.AllTools{end}(j),'VertexAdded',@(src,~)this.vertexAdd(src));
            addlistener(this.AllTools{end}(j),'MovingROI',@(src,evt)this.movingROI(src,evt,numel(this.AllTools)));
            addlistener(this.AllTools{end}(j),'DeletingROI',@(src,evt)this.vertexDeleted(src));
            addlistener(this.AllTools{end}(j),'ROIClicked',@(~,~)this.roiClicked(numel(this.AllTools)));
            addlistener(this.AllTools{end}(j),'ROIMoved',@(src,evt)this.updateUndoRedoStack(src,evt));
        end


        function movingROI(this,src,evt,toolNum)


            for i=1:3
                if isequal(evt.PreviousPosition(1,:),this.TrianglePositions(i,:))
                    this.TrianglePositions(i,:)=evt.CurrentPosition(1,:);
                    switch i
                    case 1
                        this.AllTools{toolNum}(3).Position(2,:)=evt.CurrentPosition(1,:);
                        this.AllTools{toolNum}(2).Position(1,:)=evt.CurrentPosition(2,:);
                    case 2
                        this.AllTools{toolNum}(1).Position(2,:)=evt.CurrentPosition(1,:);
                        this.AllTools{toolNum}(3).Position(1,:)=evt.CurrentPosition(2,:);

                    case 3
                        this.AllTools{toolNum}(2).Position(2,:)=evt.CurrentPosition(1,:);
                        this.AllTools{toolNum}(1).Position(1,:)=evt.CurrentPosition(2,:);
                    end
                end
                if isequal(evt.PreviousPosition(2,:),this.TrianglePositions(i,:))
                    this.TrianglePositions(i,:)=evt.CurrentPosition(2,:);
                end
            end

            if isequal(this.AllTools{toolNum}(2).Position(2,:),evt.PreviousPosition(2,:))
                this.AllTools{toolNum}(1).Position(2,:)=evt.CurrentPosition(1,:);
                this.AllTools{toolNum}(2).Position(2,:)=evt.CurrentPosition(2,:);
            elseif isequal(this.AllTools{toolNum}(2).Position(1,:),evt.PreviousPosition(1,:))
                this.AllTools{toolNum}(3).Position(1,:)=evt.CurrentPosition(2,:);
                this.AllTools{toolNum}(2).Position(1,:)=evt.CurrentPosition(1,:);
            elseif isequal(this.AllTools{toolNum}(1).Position(2,:),evt.PreviousPosition(2,:))
                this.AllTools{toolNum}(1).Position(2,:)=evt.CurrentPosition(2,:);
                this.AllTools{toolNum}(3).Position(2,:)=evt.CurrentPosition(1,:);
            end


            this.calculateAngle(this.TrianglePositions,toolNum);
            set(src,'Layer','front');

        end


        function updateUndoRedoStack(this,src,evt)



            if~isempty(evt.PreviousPosition)
                pos1=this.AllTools{end}(1).Position;
                pos2=this.AllTools{end}(2).Position;
                pos3=this.AllTools{end}(3).Position;

                pos=[pos1(1,:);pos2(1,:);pos3(1,:)];

                if isequal(src.Position,this.AllTools{end}(1).Position)
                    oldPos=[evt.PreviousPosition;pos3(1,:)];
                elseif isequal(src.Position,this.AllTools{end}(2).Position)
                    oldPos=[pos1(1,:);evt.PreviousPosition];
                elseif isequal(src.Position,this.AllTools{end}(3).Position)
                    oldPos=[evt.PreviousPosition(2,:);pos2(1,:);evt.PreviousPosition(1,:)];
                end

                evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
                pos,this.AllTools{end}(1).Parent,oldPos);

                notify(this,'UpdateUndoRedoStack',evt);
            end
        end


        function vertexDeleted(this,src)


            pos1=this.AllTools{end}(1).Position;
            pos2=this.AllTools{end}(2).Position;
            pos3=this.AllTools{end}(3).Position;

            pos=[pos1(1,:);pos2(1,:);pos3(1,:)];

            evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
            pos,this.AllTools{end}(1).Parent);

            notify(this,'DeleteFromUndoRedoStack',evt);

            for i=1:numel(this.AllTools)
                if isequal(src.Position,this.AllTools{i}(1).Position)||...
                    isequal(src.Position,this.AllTools{i}(2).Position)||...
                    isequal(src.Position,this.AllTools{i}(3).Position)
                    toolNum=i;
                end
            end

            for j=1:3
                delete(this.AllTools{toolNum}(j));
            end

            evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
            notify(this,'ObjectDeleted',evt);
        end


        function vertexAdd(this,src)


            numberOfPoints=size(src.Position,1);

            if numberOfPoints(1)>2
                src=deleteVertex(this,src);
            end

            if(numberOfPoints>1)

                src.stopDrawing();
                set(src,'Layer','front');
                notify(this,'UserDrawingFinished');
            end
        end


        function roiClicked(this,toolNum)


            for i=1:numel(this.AxesHandle.Children)
                if isequal(class(this.AxesHandle.Children(i)),'images.roi.Cuboid')||...
                    isequal(class(this.AxesHandle.Children(i)),'vision.roi.Polyline3D')||...
                    isequal(class(this.AxesHandle.Children(i)),'lidar.roi.Point3D')
                    this.AxesHandle.Children(i).Selected=false;
                    this.AxesHandle.Children(i).SelectedColor=[0,1,0];
                end
            end

            for i=1:numel(this.AllTools{toolNum})
                this.AllTools{toolNum}(i).Selected=true;
                this.AllTools{toolNum}(i).SelectedColor=[1,1,0];
            end
        end


        function calculateAngle(this,pos,toolNum)

            numberOfPoints=size(pos);


            if isempty(pos)||numberOfPoints(1)<3
                return;
            end


            A=pos(1,:);
            B=pos(2,:);
            C=pos(3,:);


            dotProduct=dot((C-B),(A-B));
            mag=norm(C-B)*norm(A-B);

            angleB=acosd(dotProduct/mag);
            this.AllTools{toolNum}(2).Label=[num2str(angleB),char(176)];


            dotProduct=dot((C-A),(B-A));
            mag=norm(C-A)*norm(B-A);

            angleA=acosd(dotProduct/mag);
            this.AllTools{toolNum}(1).Label=[num2str(angleA),char(176)];

            angleC=180-angleB-angleA;
            this.AllTools{toolNum}(3).Label=[num2str(angleC),char(176)];
        end


        function src=deleteVertex(~,src)
            src.Position=[src.Position(1,:);src.Position(3,:)];
        end


        function dialogueBoxPopUp(this,axesHandle)
            figure=axesHandle.Parent;
            uialert(figure,getString(message('lidar:lidarViewer:AngleToolWarning')),'warning');
            delete(this.AllTools{end});
            evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
            notify(this,'ObjectDeleted',evt);
        end
    end

    methods(Access={?tAngleTool})
        function createAngleTool(this,pos,axesHandle)
            createToolObj(this,pos,axesHandle);
        end
    end
end
