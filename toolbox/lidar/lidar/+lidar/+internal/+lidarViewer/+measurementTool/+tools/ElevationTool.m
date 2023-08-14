





classdef ElevationTool<lidar.internal.lidarViewer.measurementTool.AbstractTool

    properties(Constant)


        ToolName='Elevation Tool'

    end

    properties(Access=private)
AxesHandle


Elevation
    end

    properties

        AllTools=[]
    end

    events
ROIClicked
ObjectAdded
ObjectDeleted
UpdateUndoRedoStack
DeleteFromUndoRedoStack
    end



    methods

        function createToolObj(this,pos,axesHandle)


            this.AllTools{end+1}(1)=create3DlineObj(this,axesHandle,0);
            this.AllTools{end}(1).Position=pos;
            this.AllTools{end}(1).setSnapToPoints(axesHandle.Children(end));

            this.AxesHandle=axesHandle;
            this.drawLines(pos,axesHandle,numel(this.AllTools));


            cMenu=this.AllTools{end}(1).UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteElevationMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);


            this.installListenersElevation();
            this.AllTools{end}(1).Selected=true;


            elevation=calculateElevation(this,pos);
            this.AllTools{end}(1).Label=[num2str(elevation),' m'];
            set(this.AllTools{end}(1),'Layer','front');

        end

        function deleteToolObj(this,~)
            notify(this,'UndoRedoObjectDeleted');
        end


        function doMeasureMetric(this,axesHandle,cMap,~)


            this.AxesHandle=axesHandle;
            this.AllTools{end+1}(1)=create3DlineObj(this,axesHandle,cMap);


            if isempty(axesHandle.Toolbar.Tag)
                this.updateAllInteractions(true,axesHandle);
            else
                this.updateAllInteractions(false,axesHandle);
            end


            cMenu=this.AllTools{end}(1).UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteElevationMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);


            this.installListenersElevation();


            this.AllTools{end}(1).Selected=true;
            this.AllTools{end}(1).SelectedColor=[1,1,0];
            this.AllTools{end}(1).draw(axesHandle.Children(end));

            if~isvalid(axesHandle)
                return;
            end

            if~isvalid(this.AllTools{end}(1))
                delete(this.AllTools{end});
                evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
                notify(this,'ObjectDeleted',evt);
                return;
            end

            figure=axesHandle.Parent;

            if size(this.AllTools{end}(1).Position,1)==1
                uialert(figure,getString(message('lidar:lidarViewer:ElevationToolWarning')),'warning');
                delete(this.AllTools{end});
                evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
                notify(this,'ObjectDeleted',evt);
                return;
            end
        end


        function stopMeasuringMetric(this,isUserMeasuring)


            for i=1:numel(this.AllTools)
                if isUserMeasuring
                    this.AllTools{i}(1).stopDrawing();
                end

                delete(this.AllTools{i}(1));
                delete(this.AllTools{i}(2));
                delete(this.AllTools{i}(3));
            end
            this.AllTools={};
        end
    end




    methods(Access=private)


        function installListenersElevation(this,~,~)


            addlistener(this.AllTools{end}(1),'VertexAdded',@(src,~)this.vertexAdd(src,numel(this.AllTools)));
            addlistener(this.AllTools{end}(1),'MovingROI',@(src,~)this.movingROI(src,numel(this.AllTools)));
            addlistener(this.AllTools{end}(1),'DeletingROI',@(src,~)this.vertexDeleted(src));
            addlistener(this.AllTools{end}(1),'ROIClicked',@(src,~)this.roiClicked(src));
            addlistener(this.AllTools{end}(1),'ROIMoved',@(~,evt)this.updateUndoRedoStack(evt));

        end


        function movingROI(this,src,i)



            delete(this.AllTools{i}(2));
            delete(this.AllTools{i}(3));


            elevation=this.calculateElevation(src.Position);

            this.drawLines(src.Position,this.AxesHandle,i);


            src.Label=[num2str(elevation),' m'];
            set(src,'Layer','front');
        end


        function updateUndoRedoStack(this,evt)



            if~isempty(evt.PreviousPosition)
                evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
                this.AllTools{end}(1).Position,this.AllTools{end}(1).Parent,evt.PreviousPosition);

                notify(this,'UpdateUndoRedoStack',evt);
            end
        end


        function vertexDeleted(this,src)


            for i=1:numel(this.AllTools)
                if src.Position==this.AllTools{i}(1).Position
                    toolNum=i;
                end
            end

            evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
            this.AllTools{end}(1).Position,this.AllTools{end}(1).Parent);

            notify(this,'DeleteFromUndoRedoStack',evt);

            delete(src);
            delete(this.AllTools{toolNum}(2));
            delete(this.AllTools{toolNum}(3));

            evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
            notify(this,'ObjectDeleted',evt);
        end


        function vertexAdd(this,src,i)


            numberOfPoints=size(src.Position);


            elevation=this.calculateElevation(src.Position);


            src.Label=[num2str(elevation),' m'];

            if numberOfPoints(1)>2
                src=this.deleteVertex(src);
            end

            if numberOfPoints(1)>1


                this.AllTools{i}(1).stopDrawing();
                notify(this,'UserDrawingFinished');

                elevation=this.calculateElevation(src.Position);

                this.drawLines(src.Position,this.AxesHandle,i);

                src.Label=[num2str(elevation),' m'];
                set(src,'Layer','front');
            end
        end


        function drawLines(this,pos,axesHandle,i)

            x=pos(:,1);
            y=pos(:,2);
            z=pos(:,3);

            if(z(1)>z(2))
                this.AllTools{i}(2)=line(axesHandle,[x(1),x(1)],[y(1),y(1)],z,'Color','green');
                this.AllTools{i}(3)=line(axesHandle,x,y,[z(2),z(2)],'Color','green');
            else
                this.AllTools{i}(2)=line(axesHandle,[x(2),x(2)],[y(2),y(2)],z,'Color','green');
                this.AllTools{i}(3)=line(axesHandle,x,y,[z(1),z(1)],'Color','green');
            end
        end


        function roiClicked(this,src)

            for i=1:numel(this.AxesHandle.Children)
                if isequal(class(this.AxesHandle.Children(i)),'images.roi.Cuboid')||...
                    isequal(class(this.AxesHandle.Children(i)),'vision.roi.Polyline3D')||...
                    isequal(class(this.AxesHandle.Children(i)),'lidar.roi.Point3D')
                    this.AxesHandle.Children(i).Selected=false;
                    this.AxesHandle.Children(i).SelectedColor=[0,1,0];
                end
            end

            src.Selected=true;
            src.SelectedColor=[1,1,0];

        end


        function elevation=calculateElevation(~,pos)

            numberOfPoints=size(pos);


            if isempty(pos)||numberOfPoints(1)<2
                elevation=0;
                return;
            end


            difference=diff(pos);
            elevation=round(abs(difference(3)),2);
        end


        function src=deleteVertex(~,src)
            src.Position=[src.Position(1,:);src.Position(3,:)];
        end
    end
end
