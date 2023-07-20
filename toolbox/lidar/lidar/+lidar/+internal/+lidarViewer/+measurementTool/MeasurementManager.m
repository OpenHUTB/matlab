







classdef MeasurementManager<handle

    properties

        MeasurementUndoStack={}


        MeasurementRedoStack={}


CurrentIndex


        ColorValue=[0,1,0]

    end

    events
ResetColorData
DeleteAllTools
UpdateClearSection
CreateObject
    end

    methods


        function createMeasurementStacks(this,numFrames,currentIndex)


            this.MeasurementUndoStack=cell(numFrames,1);
            this.MeasurementRedoStack=cell(numFrames,1);
            this.CurrentIndex=currentIndex;


            dummy.ToolName='';
            dummy.Position=[];
            dummy.Parent=[];

            for i=1:numFrames
                this.MeasurementUndoStack{i}{1}=dummy;
            end
        end




        function doUndo(this)


            if this.isMeasurementUndoStackEmpty(this.CurrentIndex)
                return;
            end

            this.MeasurementRedoStack{this.CurrentIndex}{end+1}=this.MeasurementUndoStack{this.CurrentIndex}{end};
            this.MeasurementUndoStack{this.CurrentIndex}=this.MeasurementUndoStack{this.CurrentIndex}(1:end-1);
            this.updateDisplay(this.MeasurementUndoStack{this.CurrentIndex}{end});
        end




        function doRedo(this)


            if this.isMeasurementRedoStackEmpty(this.CurrentIndex)
                return;
            end

            this.MeasurementUndoStack{this.CurrentIndex}{end+1}=this.MeasurementRedoStack{this.CurrentIndex}{end};
            this.MeasurementRedoStack{this.CurrentIndex}=this.MeasurementRedoStack{this.CurrentIndex}(1:end-1);
            this.updateDisplay(this.MeasurementUndoStack{this.CurrentIndex}{end});
        end


        function addToolsInStacks(this,currentIndex,evt)


            if isempty(evt.ToolObj)
                return;
            end

            this.ColorValue=[0,1,0];

            if iscell(this.MeasurementUndoStack{currentIndex}{end})
                this.MeasurementUndoStack{currentIndex}{end+1}={this.MeasurementUndoStack{currentIndex}{end}{1:end},this.copyROIs(evt.ToolObj)};
            else
                this.MeasurementUndoStack{currentIndex}{end+1}={this.MeasurementUndoStack{currentIndex}{end},this.copyROIs(evt.ToolObj)};
            end

            this.CurrentIndex=currentIndex;
            this.MeasurementRedoStack{currentIndex}=[];
        end


        function resetStacks(this,lastStack)


            this.MeasurementRedoStack{this.CurrentIndex}={};
            this.MeasurementUndoStack{this.CurrentIndex}={};


            dummy.ToolName='';
            dummy.Position=[];
            dummy.Parent=[];

            if nargin==2
                this.MeasurementUndoStack{this.CurrentIndex}{1}=lastStack;
                this.MeasurementUndoStack{this.CurrentIndex}{end+1}=dummy;
            else
                this.MeasurementUndoStack{this.CurrentIndex}{1}=dummy;
            end
        end


        function TF=isMeasurementUndoStackEmpty(this,currentIndex)

            if numel(this.MeasurementUndoStack{currentIndex})<=1
                TF=true;
                return;
            end
            TF=false;
        end


        function TF=isMeasurementRedoStackEmpty(this,currentIndex)

            if isempty(this.MeasurementRedoStack{currentIndex})
                TF=true;
                return;
            end
            TF=false;
        end


        function changeCurrentFrame(this,currentIndex)

            this.CurrentIndex=currentIndex;
        end


        function changeColor(this,axesHandle)


            for i=1:numel(axesHandle.Children)-1
                obj=axesHandle.Children(i);
                obj.Color=this.ColorValue;
            end
        end


        function updateDisplay(this,TotalROIs)


            notify(this,'ResetColorData');

            notify(this,'DeleteAllTools');

            for i=1:numel(TotalROIs)
                if numel(TotalROIs)>1
                    this.createTool(TotalROIs{i});
                end
            end

            notify(this,'UpdateClearSection');
        end


        function outgoingStack=copyROIs(this,incomingStack)


            ToolObj=incomingStack;
            obj=ToolObj.AllTools{end};
            if strcmp(ToolObj.ToolName,'Distance Tool')
                copyObj.ToolName='Distance Tool';
                copyObj.Position=obj.Position;
                copyObj.Parent=obj.Parent;
            elseif strcmp(ToolObj.ToolName,'Elevation Tool')
                copyObj.ToolName='Elevation Tool';
                copyObj.Position=obj(1).Position;
                copyObj.Parent=obj.Parent;
            elseif strcmp(ToolObj.ToolName,'Point Tool')
                copyObj.ToolName='Point Tool';
                copyObj.Position=obj.Position;
                copyObj.Parent=obj.Parent;
            elseif strcmp(ToolObj.ToolName,'Angle Tool')
                copyObj.ToolName='Angle Tool';
                copyObj.Position(1,:)=obj(1).Position(1,:);
                copyObj.Position(2,:)=obj(2).Position(1,:);
                copyObj.Position(3,:)=obj(3).Position(1,:);
                copyObj.Parent=obj.Parent;
            elseif strcmp(ToolObj.ToolName,'Volume Tool')
                copyObj.ToolName='Volume Tool';
                copyObj.Position=obj.Position;
                copyObj.Parent=obj.Parent;
            end
            outgoingStack=copyObj;
        end


        function createTool(this,incomingStack)


            ToolObj=incomingStack;

            evt=lidar.internal.lidarViewer.events.MeasurementUndoRedoEventData(ToolObj.ToolName,...
            ToolObj.Position,ToolObj.Parent);
            notify(this,'CreateObject',evt);
        end


        function updateToolsInMeasurementStack(this,evt)
            if numel(fieldnames(evt))<6
                return;
            end
            previousStack=this.MeasurementUndoStack{this.CurrentIndex}{end};
            temp={};

            for i=1:numel(previousStack)
                if~isequal(previousStack{i}.Position,evt.PreviousPosition)
                    temp{end+1}=previousStack{i};
                else
                    copyObj.ToolName=evt.ToolName;
                    copyObj.Position=evt.Position;
                    copyObj.Parent=evt.Parent;

                    temp{end+1}=copyObj;
                end
            end

            if~isempty(temp)
                this.MeasurementUndoStack{this.CurrentIndex}{end+1}=temp;
            end
        end


        function deleteToolsInMeasurementStack(this,evt)
            if numel(fieldnames(evt))<6
                return;
            end

            previousStack=this.MeasurementUndoStack{this.CurrentIndex}{end};
            temp={};

            for i=1:numel(previousStack)
                if~isequal(previousStack{i}.Position,evt.Position)
                    temp{end+1}=previousStack{i};
                end
            end

            if~isempty(temp)
                this.MeasurementUndoStack{this.CurrentIndex}{end+1}=temp;
                this.MeasurementRedoStack{this.CurrentIndex}=[];
            end
        end
    end
end