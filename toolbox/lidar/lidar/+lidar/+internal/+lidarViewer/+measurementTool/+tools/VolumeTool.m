





classdef VolumeTool<lidar.internal.lidarViewer.measurementTool.AbstractTool

    properties(Constant)


        ToolName='Volume Tool'

    end

    properties(Access=private)

AxesHandle
        Index=0
CData

CData1
CData2
    end

    properties

        AllTools={}
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

            this.AllTools{end+1}=create3DCuboidObj(this,axesHandle,0);
            this.AllTools{end}.Position=pos;


            this.installListenersVolumeTool(axesHandle);

            this.AxesHandle=axesHandle;
            if this.Index==0

                this.updateCData(this.AxesHandle);

                this.Index=this.Index+1;
            end

            this.AllTools{end}.Selected=true;


            cMenu=this.AllTools{end}.UIContextMenu;
            cMenu.Children(2).Text=getString(message('lidar:lidarViewer:DeleteVolumeMeasurement'));


            volume=pos(4)*pos(5)*pos(6);
            this.AllTools{end}.Label=[num2str(round(volume,2)),' m',char(179)];
            cuboidMoved(this,axesHandle,numel(this.AllTools));

        end


        function doMeasureMetric(this,axesHandle,cMap,CData)


            this.AxesHandle=axesHandle;

            this.updateCData(axesHandle);

            this.AllTools{end+1}=create3DCuboidObj(this,this.AxesHandle,cMap);


            if isempty(axesHandle.Toolbar.Tag)
                this.updateAllInteractions(true,axesHandle);
            else
                this.updateAllInteractions(false,axesHandle);
            end


            this.installListenersVolumeTool(this.AxesHandle);
            this.AllTools{end}.Selected=true;


            cMenu=this.AllTools{end}.UIContextMenu;
            cMenu.Children(2).Text=getString(message('lidar:lidarViewer:DeleteVolumeMeasurement'));

            this.AllTools{end}.SelectedColor=[1,1,0];

            scatterPlot=findall(this.AxesHandle.Children,'Tag','pcviewer');
            this.AllTools{end}.draw(scatterPlot(end));

            if~isvalid(axesHandle)
                return;
            end

            if~isvalid(this.AllTools{end})
                delete(this.AllTools{end});
                evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
                notify(this,'ObjectDeleted',evt);
                return;
            end

            volume=this.AllTools{end}.Position(4)*this.AllTools{end}.Position(5)*this.AllTools{end}.Position(6);
            this.AllTools{end}.Label=[num2str(round(volume,2)),' m',char(179)];

        end


        function stopMeasuringMetric(this,~)


            for i=1:numel(this.AllTools)
                delete(this.AllTools{i});
            end
            this.AllTools={};
            this.resetCData(this.AxesHandle);

            this.Index=0;
        end


        function roiClick(this,src)
            roiClicked(this,src);
        end


        function updateCData(this,axesHandle)

            scatterPlot=findall(axesHandle.Children,'Tag','pcviewer');

            if numel(scatterPlot)>1
                this.CData1=scatterPlot(1).CData;
                this.CData2=scatterPlot(2).CData;
            else
                this.CData=scatterPlot.CData;
            end
        end


        function resetCData(this,axesHandle)

            scatterPlot=findall(axesHandle.Children,'Tag','pcviewer');

            if numel(scatterPlot)>1
                scatterPlot(1).CData=this.CData1;
                scatterPlot(2).CData=this.CData2;
            else
                scatterPlot.CData=this.CData;
            end
        end
    end




    methods(Access=private)

        function installListenersVolumeTool(this,axesHandle)


            addlistener(this.AllTools{end},'MovingROI',@(src,~)this.movingCuboid(src));
            addlistener(this.AllTools{end},'ROIMoved',@(~,evt)this.cuboidMoved(axesHandle,numel(this.AllTools),evt));
            addlistener(this.AllTools{end},'ROIClicked',@(src,~)this.roiClicked(src));
            addlistener(this.AllTools{end},'DeletingROI',@(src,~)this.ROIDeleted(src));
        end


        function movingCuboid(~,src)


            volume=src.Position(4)*src.Position(5)*src.Position(6);
            src.Label=[num2str(round(volume,2)),' m',char(179)];

        end


        function ROIDeleted(this,src)


            evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
            this.AllTools{end}.Position,this.AllTools{end}.Parent);

            notify(this,'DeleteFromUndoRedoStack',evt);

            delete(src);
            evt=lidar.internal.lidarViewer.events.MeasurementToolEventData(this.ToolName,this);
            notify(this,'ObjectDeleted',evt);

            this.resetCData(this.AxesHandle);
        end


        function roiClicked(this,src)

            if numel(this.AxesHandle)>=1
                for i=1:numel(this.AxesHandle.Children)
                    if isequal(class(this.AxesHandle.Children(i)),'images.roi.Cuboid')||...
                        isequal(class(this.AxesHandle.Children(i)),'vision.roi.Polyline3D')||...
                        isequal(class(this.AxesHandle.Children(i)),'lidar.roi.Point3D')
                        this.AxesHandle.Children(i).Selected=false;
                        this.AxesHandle.Children(i).SelectedColor=[0,1,0];
                    end
                end
            end

            try
                src.Selected=true;
                src.SelectedColor=[1,1,0];
            catch
                return;
            end

            scatterPlot=findall(this.AxesHandle.Children,'Tag','pcviewer');

            if numel(scatterPlot)>1
                indices1=insidePoints(this,scatterPlot(1),src);
                scatterPlot(1).CData=this.CData1;
                scatterPlot(1).CData(indices1')=repmat(2,numel(indices1),1);

                indices2=insidePoints(this,scatterPlot(2),src);
                scatterPlot(2).CData=this.CData2;
                scatterPlot(2).CData(indices2')=repmat(2,numel(indices2),1);
            else
                indices=insidePoints(this,scatterPlot,src);
                scatterPlot.CData=this.CData;
                scatterPlot.CData(indices')=repmat(0.75,numel(indices),1);
            end
        end


        function cuboidMoved(this,axesHandle,toolNum,evt)


            if isempty(this.AllTools{end}.Position)
                return;
            end



            if nargin==4&&~isempty(evt.PreviousPosition)
                evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(this.ToolName,...
                this.AllTools{end}.Position,this.AllTools{end}.Parent,evt.PreviousPosition);

                notify(this,'UpdateUndoRedoStack',evt);
            end

            if numel(axesHandle)<1
                scatterPlot=axesHandle;
            else
                scatterPlot=findall(axesHandle.Children,'Tag','pcviewer');
            end

            src=this.AllTools{toolNum};
            if numel(scatterPlot)>1
                indices1=insidePoints(this,scatterPlot(1),src);
                scatterPlot(1).CData=this.CData1;
                scatterPlot(1).CData(indices1')=repmat(2,numel(indices1),1);

                indices2=insidePoints(this,scatterPlot(2),src);
                scatterPlot(2).CData=this.CData2;
                scatterPlot(2).CData(indices2')=repmat(2,numel(indices2),1);
            else
                indices=insidePoints(this,scatterPlot,src);
                scatterPlot.CData=this.CData;
                scatterPlot.CData(indices')=repmat(0.75,numel(indices),1);
            end
        end


        function indices=insidePoints(this,scatterPlot,src)
            XData=scatterPlot.XData;
            YData=scatterPlot.YData;
            ZData=scatterPlot.ZData;
            CData=scatterPlot.CData;

            ptCloudInside=pointCloud([XData',YData',ZData']);
            roi=src.Position;
            roi=[roi(1),roi(1)+roi(4),roi(2),roi(2)+roi(5),roi(3),roi(3)+roi(6)];

            indices=findPointsInROI(ptCloudInside,roi);
        end
    end
end
