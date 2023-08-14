





classdef PointTool<lidar.internal.lidarViewer.measurementTool.AbstractTool

    properties(Constant)


        ToolName='Point Tool'

    end

    properties(Access=private)
AxesHandle
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

            this.AllTools{end+1}=create3DPointObj(this,axesHandle,0);
            this.AllTools{end}.Position=pos;
            this.AllTools{end}.setSnapToPoints(axesHandle.Children(end));

            this.AxesHandle=axesHandle;


            cMenu=this.AllTools{end}.UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeletePointMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);


            this.installPointListeners();

            this.AllTools{end}.Selected=true;

            this.AllTools{end}.Label=num2str(round(pos,2));

            set(this.AllTools{end},'Layer','front');

        end


        function doMeasureMetric(this,axesHandle,cMap,~)


            this.AxesHandle=axesHandle;
            this.AllTools{end+1}=create3DPointObj(this,axesHandle,cMap);


            if isempty(axesHandle.Toolbar.Tag)
                this.updateAllInteractions(true,axesHandle);
            else
                this.updateAllInteractions(false,axesHandle);
            end


            cMenu=this.AllTools{end}.UIContextMenu;
            cMenu.Children(1).Text=getString(message('lidar:lidarViewer:DeletePointMeasurement'));
            defaultContextMenu=findobj(cMenu,'Tag','IPTROIContextMenuAddPoint');
            delete(defaultContextMenu);


            this.installPointListeners();

            this.AllTools{end}.Selected=true;
            this.AllTools{end}.SelectedColor=[1,1,0];

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

            this.AllTools{end}.Label=num2str(round(this.AllTools{end}.Position,2));
            this.AllTools{end}.setSnapToPoints(axesHandle.Children(end));
            set(this.AllTools{end},'Layer','front');

        end


        function stopMeasuringMetric(this,~)


            for i=1:numel(this.AllTools)
                delete(this.AllTools{i});
            end
            this.AllTools={};
        end
    end




    methods(Access=private)


        function installPointListeners(this,~,~)


            addlistener(this.AllTools{end},'MovingROI',@(src,evt)this.vertexMoved(src,evt));
            addlistener(this.AllTools{end},'ROIClicked',@(src,~)this.roiClicked(src));
            addlistener(this.AllTools{end},'DeletingROI',@(src,~)this.vertexDeleted(src));
            addlistener(this.AllTools{end},'ROIMoved',@(~,evt)this.updateUndoRedoStack(evt));

        end


        function vertexMoved(~,src,evt)

            currentPos=round(evt.CurrentPosition(1,:),2);
            src.Label=num2str(currentPos);
            set(src,'Layer','front');
        end


        function vertexDeleted(this,src)


            evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
            this.AllTools{end}.Position,this.AllTools{end}.Parent);

            notify(this,'DeleteFromUndoRedoStack',evt);

            delete(src);
            evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
            notify(this,'ObjectDeleted',evt);

        end


        function updateUndoRedoStack(this,evt)



            if~isempty(evt.PreviousPosition)
                evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
                this.AllTools{end}.Position,this.AllTools{end}.Parent,evt.PreviousPosition);

                notify(this,'UpdateUndoRedoStack',evt);
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
    end

end
