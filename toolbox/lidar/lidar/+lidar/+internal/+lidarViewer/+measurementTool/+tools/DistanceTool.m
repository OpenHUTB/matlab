





classdef DistanceTool<lidar.internal.lidarViewer.measurementTool.AbstractTool

    properties(Constant)


        ToolName='Distance Tool'

    end

    properties

        AllTools=[]
    end

    properties(Access=private)

Distance
AxesHandle
vertexAddListener
    end

    events
ROIClicked
NewObjectAdded
ObjectAdded
ObjectDeleted
UpdateUndoRedoStack
DeleteFromUndoRedoStack
    end



    methods


        function createToolObj(this,pos,axesHandle)


            this.AllTools{end+1}=create3DlineObj(this,this.AxesHandle,0);
            this.AllTools{end}.Position=pos;
            this.AllTools{end}.setSnapToPoints(axesHandle.Children(end));
            this.AllTools{end}.Parent=axesHandle;
            this.AxesHandle=axesHandle;


            cMenu=this.AllTools{end}.UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteDistanceMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);


            this.installLinstenersDistanceTool();
            this.AllTools{end}.Selected=true;


            this.calculateDistance(pos);
            this.AllTools{end}.Label=num2str(this.Distance);
            set(this.AllTools{end},'Layer','front');

        end


        function doMeasureMetric(this,axesHandle,cMap,~)


            this.AllTools{end+1}=create3DlineObj(this,axesHandle,cMap);
            this.AxesHandle=axesHandle;


            if isempty(axesHandle.Toolbar.Tag)
                this.updateAllInteractions(true,axesHandle);
            else
                this.updateAllInteractions(false,axesHandle);
            end


            cMenu=this.AllTools{end}.UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeleteDistanceMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);


            this.installLinstenersDistanceTool();


            this.AllTools{end}.Selected=true;
            this.AllTools{end}.draw(axesHandle.Children(end));

            if~isvalid(axesHandle)
                return;
            end

            if~isvalid(this.AllTools{end})
                delete(this.AllTools{end});
                evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
                notify(this,'ObjectDeleted',evt);
                return;
            end

            figure=axesHandle.Parent;

            if size(this.AllTools{end}.Position,1)==1
                uialert(figure,getString(message('lidar:lidarViewer:DistanceToolWarning')),'warning');
                delete(this.AllTools{end});
                evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
                notify(this,'ObjectDeleted',evt);
                return;
            end
        end

        function stopMeasuringMetric(this,isUserMeasuring)


            for i=1:numel(this.AllTools)
                if isUserMeasuring
                    this.AllTools{i}.stopDrawing();
                end

                delete(this.AllTools{i});
            end
            this.AllTools={};
        end

    end




    methods(Access=private)


        function installLinstenersDistanceTool(this,~,~)


            addlistener(this.AllTools{end},'VertexAdded',@(src,~)this.vertexAdd(src));
            addlistener(this.AllTools{end},'MovingROI',@(src,evt)this.movingROI(src,evt));
            addlistener(this.AllTools{end},'ROIMoved',@(src,evt)this.updateUndoRedoStack(src,evt));
            addlistener(this.AllTools{end},'DeletingROI',@(src,~)this.vertexDeleted(src));
            addlistener(this.AllTools{end},'ROIClicked',@(src,~)this.roiClicked(src));
        end


        function movingROI(this,src,evt)



            this.calculateDistance(src.Position);


            src.Label=num2str(this.Distance);
            set(src,'Layer','front');

        end


        function updateUndoRedoStack(this,~,evt)



            if~isempty(evt.PreviousPosition)
                evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
                this.AllTools{end}.Position,this.AllTools{end}.Parent,evt.PreviousPosition);

                notify(this,'UpdateUndoRedoStack',evt);
            end
        end


        function vertexDeleted(this,src)


            evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
            this.AllTools{end}.Position,this.AllTools{end}.Parent);

            delete(src);

            notify(this,'DeleteFromUndoRedoStack',evt);
            evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
            notify(this,'ObjectDeleted',evt);

        end


        function vertexAdd(this,src)


            numberOfPoints=size(src.Position);
            this.calculateDistance(src.Position);
            src.Label=num2str(this.Distance);

            if numberOfPoints(1)>2
                src=this.deleteVertex(src);
            end

            if numberOfPoints(1)>1


                src.stopDrawing();
                notify(this,'UserDrawingFinished');

                this.calculateDistance(src.Position);
                src.Label=num2str(this.Distance);
                set(src,'Layer','front');
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


        function calculateDistance(this,pos)

            this.Distance=0;
            numberOfPoints=size(pos);


            if isempty(pos)||numberOfPoints(1)<2
                this.Distance=0;
                return;
            end


            diffVec=diff(pos);
            this.Distance=round(hypot(diffVec(1),diffVec(2)),2);
        end


        function src=deleteVertex(~,src)
            src.Position=[src.Position(1,:);src.Position(3,:)];
        end
    end
end
