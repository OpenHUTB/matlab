





classdef MeasurementTool<handle

    properties

AxesHandle


        ToolType char='';


        IsUserMeasuring(1,1)logical=false;


        Tool={};


Map


        AllToolObj={};


CurrentToolObj


PreviousToolObj


Cdata


ToolbarChanged
    end

    events
UserDrawingFinished
ObjectAdded
ObjectDeleted
DisableToolstrip
UpdateUndoRedoStack
DeleteFromUndoRedoStack
    end

    properties(Dependent)




        IsToolActive(1,1)logical
    end

    methods



        function this=MeasurementTool()
            this.setUp();
        end


        function TF=get.IsToolActive(this)
            TF=~isempty(this.ToolType);
        end


        function updateAxes(this,axes)
            if~isempty(axes)
                this.AxesHandle=axes;
            end
            this.Cdata=axes.Children(end).CData;
        end
    end




    methods
        function evt=doMeasureMetric(this,evt,cMap)


            if isempty(this.AxesHandle)
                return;
            end

            this.CurrentToolObj=this.getToolObj(evt.ToolType);

            if isempty(this.CurrentToolObj)
                return;
            end

            addlistener(this.CurrentToolObj,'ObjectAdded',@(~,evt)this.objectAdded(evt));
            addlistener(this.CurrentToolObj,'ObjectDeleted',@(~,evt)this.objectDeleted(evt));
            if(evt.ToolType=="Angle Tool")
                addlistener(this.CurrentToolObj,'DisableToolstrip',@(~,~)notify(this,'DisableToolstrip'));
            end

            this.IsUserMeasuring=true;
            this.ToolType=evt.ToolType;

            this.CurrentToolObj.doMeasureMetric(this.AxesHandle,cMap,this.Cdata);

            this.IsUserMeasuring=false;
            if isempty(this.CurrentToolObj.AllTools)||~all(isvalid(this.CurrentToolObj.AllTools{end}))
                return;
            end

            if~isempty(this.PreviousToolObj)
                if isvalid(this.PreviousToolObj)
                    if isequal(this.PreviousToolObj(1).Position,...
                        this.CurrentToolObj.AllTools{end}(1).Position)
                        return;
                    end
                end
            end

            this.AllToolObj{end+1}=this.CurrentToolObj;
            this.PreviousToolObj=this.CurrentToolObj.AllTools{end};

            if~isempty(this.CurrentToolObj.AllTools)
                roiClicked(this,this.CurrentToolObj,this.CurrentToolObj.AllTools{end});
            end
            this.ToolbarChanged=false;

            evt.ToolObj=this.CurrentToolObj;
            addlistener(this.CurrentToolObj,'UpdateUndoRedoStack',@(~,evt)notify(this,'UpdateUndoRedoStack',evt));
            addlistener(this.CurrentToolObj,'DeleteFromUndoRedoStack',@(~,evt)notify(this,'DeleteFromUndoRedoStack',evt));
        end


        function stopMeasuringMetric(this)



            for i=1:numel(this.AllToolObj)
                this.AllToolObj{i}.stopMeasuringMetric(this.IsUserMeasuring);
            end

            if~isempty(allchild(this.AxesHandle))
                delete(this.AxesHandle.Children(1:end-1));
            end

            this.AllToolObj={};
            this.ToolType='';
        end


        function measurementToolCreateObject(this,evt)
            if isempty(evt.ToolName)
                return;
            end

            if strcmp(evt.ToolName,'Distance Tool')
                copyObj=lidar.internal.lidarViewer.measurementTool.tools.DistanceTool();
                copyObj.createToolObj(evt.Position,evt.Parent);
                this.CurrentToolObj=copyObj;
            elseif strcmp(evt.ToolName,'Elevation Tool')
                copyObj=lidar.internal.lidarViewer.measurementTool.tools.ElevationTool();
                copyObj.createToolObj(evt.Position,evt.Parent);
                this.CurrentToolObj=copyObj;
            elseif strcmp(evt.ToolName,'Point Tool')
                copyObj=lidar.internal.lidarViewer.measurementTool.tools.PointTool();
                copyObj.createToolObj(evt.Position,evt.Parent);
                this.CurrentToolObj=copyObj;
            elseif strcmp(evt.ToolName,'Angle Tool')
                copyObj=lidar.internal.lidarViewer.measurementTool.tools.AngleTool();
                copyObj.createToolObj(evt.Position,evt.Parent);
                this.CurrentToolObj=copyObj;
            elseif strcmp(evt.ToolName,'Volume Tool')
                copyObj=lidar.internal.lidarViewer.measurementTool.tools.VolumeTool();
                copyObj.createToolObj(evt.Position,evt.Parent);
                this.CurrentToolObj=copyObj;
            end

            this.AllToolObj{end+1}=this.CurrentToolObj;

            if~isempty(this.CurrentToolObj.AllTools)
                roiClicked(this,this.CurrentToolObj,this.CurrentToolObj.AllTools{end});
            end


            copyObj.updateAllInteractions(~this.ToolbarChanged,evt.Parent);

            addlistener(this.CurrentToolObj,'ObjectDeleted',@(~,evt)this.objectDeleted(evt));
            addlistener(this.CurrentToolObj,'ObjectAdded',@(~,evt)this.objectAdded(evt));
            addlistener(this.CurrentToolObj,'UpdateUndoRedoStack',@(~,evt)notify(this,'UpdateUndoRedoStack',evt));
            addlistener(this.CurrentToolObj,'DeleteFromUndoRedoStack',@(~,evt)notify(this,'DeleteFromUndoRedoStack',evt));
        end


        function stopCurrentTool(this)
            if this.IsUserMeasuring
                delete(this.CurrentToolObj.AllTools{end});
                uiresume(this.AxesHandle.Parent);
            end
        end


        function roiClicked(this,ToolObj,newObj)

            if~isvalid(this.AxesHandle)
                return;
            end

            if numel(allchild(this.AxesHandle))==1
                return;
            end

            for i=1:numel(this.AxesHandle.Children)
                if isequal(class(this.AxesHandle.Children(i)),'images.roi.Cuboid')||...
                    isequal(class(this.AxesHandle.Children(i)),'vision.roi.Polyline3D')||...
                    isequal(class(this.AxesHandle.Children(i)),'lidar.roi.Point3D')
                    this.AxesHandle.Children(i).Selected=false;
                    this.AxesHandle.Children(i).Color=[0,1,0];
                end
            end
            for i=1:numel(newObj)
                if strcmp(ToolObj.ToolName,'Distance Tool')||...
                    strcmp(ToolObj.ToolName,'Volume Tool')||...
                    strcmp(ToolObj.ToolName,'Point Tool')
                    newObj(i).Selected=true;
                    newObj(i).SelectedColor=[1,1,0];
                elseif strcmp(ToolObj.ToolName,'Angle Tool')
                    for t=1:3
                        newObj(t).Selected=true;
                        newObj(t).SelectedColor=[1,1,0];
                    end
                elseif strcmp(ToolObj.ToolName,'Elevation Tool')
                    newObj(1).Selected=true;
                    newObj(1).SelectedColor=[1,1,0];
                end
            end
        end


        function changeToolColor(this,cMap,axesHandle)


            if~isempty(this.AllToolObj)
                toolObj=this.AllToolObj{end};
                if strcmp(toolObj.ToolName,'Volume Tool')&&~isempty(toolObj.AllTools)
                    toolObj.updateCData(axesHandle);
                    toolObj.roiClick(toolObj.AllTools{end});
                end
            end

            obj=this.AxesHandle.Children;
            for i=1:numel(obj)
                if isequal(class(obj(i)),'vision.roi.Polyline3D')||...
                    isequal(class(obj(i)),'images.roi.Cuboid')||...
                    isequal(class(obj(i)),'lidar.roi.Point3D')
                    if cMap
                        obj(i).Color=toolObj.getColor(cMap);
                    else
                        obj(i).Color=[0,1,0];
                    end
                end
            end
        end


        function objectAdded(this,evt)
            this.AllToolObj{end+1}=evt;
        end


        function objectDeleted(this,evt)
            toolObj=evt.ToolObj;
            if isempty(toolObj.AllTools)
                return;
            end

            notify(this,'ObjectDeleted');

            stack=toolObj.AllTools;
            vertex=[];
            for i=1:numel(stack)
                TF=false;
                if isa(stack{i},'vision.roi.Polyline3D')||...
                    isa(stack{i},'lidar.roi.Point3D')||...
                    isa(stack{i},'images.roi.Cuboid')
                    if~isvalid(stack{i})
                        TF=true;
                    end
                elseif isa(stack{i}(1),'vision.roi.Polyline3D')||...
                    ~isvalid(stack{i}(1))
                    if~isvalid(stack{i}(1))
                        TF=true;
                    end
                end
                if TF
                    vertex(end+1)=i;
                end
            end
            for i=1:numel(vertex)
                if i~=numel(stack)
                    for j=vertex(i):numel(stack)-1
                        stack(j)=stack(j+1);
                    end
                end
                stack=stack(1:end-1);
            end
            toolObj.AllTools=stack;
        end


        function toolObj=getToolObj(this,toolType)


            try
                idx=this.Map(toolType);
                toolObj=this.Tool{idx};
            catch
                toolObj=[];
            end
        end
    end




    methods(Access=private)

        function setUp(this)



            info=...
            meta.package.fromName("lidar.internal.lidarViewer.measurementTool.tools");

            numTools=numel(info.ClassList);
            toolName={};

            for i=1:numTools



                try
                    obj=eval(info.ClassList(i).Name);
                    addlistener(obj,'UserDrawingFinished',@(~,~)markDrawingCompleted(this));
                    this.Tool{end+1}=obj;
                    toolName{end+1}=obj.ToolName;
                catch

                end
            end

            this.Map=containers.Map(toolName,(1:numel(toolName)));
        end


        function markDrawingCompleted(this)


            this.IsUserMeasuring=false;
            notify(this,'UserDrawingFinished');
        end
    end
end