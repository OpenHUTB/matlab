




classdef DisplayManager<handle

    properties


Displays
    end

    properties(Dependent)

NumDisplays
    end

    events
ExternalTrigger

DefaultCMapValSelected

DefaultCMapSelected

UserDrawingFinished

ObjectDeleted

DisableToolstrip

UpdateUndoRedoStack

DeleteFromUndoRedoStack

UpdateColorData

UpdateUndoRedo

RequestToAddColor
    end




    methods

        function this=DisplayManager(hFig,defaultName)
            createDefaultDisplay(this,hFig,defaultName);
        end


        function clear(this)
            this.Displays=[];
        end


        function num=get.NumDisplays(this)
            num=numel(this.Displays);
        end
    end




    methods

        function display=getDisplayFromId(this,id)
            if(id>0)&&(id<=this.NumDisplays)
                display=this.Displays{id};
            else
                display=[];
            end
        end


        function display=getDisplayFromName(this,name)
            displayId=this.getDisplayId(name);
            display=getDisplayFromId(this,displayId);
        end


        function id=getDisplayId(this,name)
            id=0;
            for i=1:this.NumDisplays
                if strcmp(this.Displays{i}.Name,name)
                    id=i;
                    break;
                end
            end
        end


        function ptCld=getPtCldInDisplay(this,id)

            ptCld=this.Displays{id+1}.getPtCldInDisplay();
        end


        function axes=getDisplayAxes(this,id)


            axes=this.Displays{id+1}.getAxes();
        end


        function[cmap,variation,cmapVal]=getColorVariationInfo(this,dataId)
            [cmap,variation,cmapVal]=this.Displays{dataId+1}.getColorVariationInfo();
        end


    end




    methods

        function createDefaultDisplay(this,hFig,defaultName)
            if isempty(this.Displays)
                createAndAddDisplay(this,hFig,false,defaultName);
            end
        end


        function newDisplay=createAndAddDisplay(this,hFig,isPCDisplay,name,limits)
            newDisplay=[];
            if isNameUnused(this,name)

                if~isPCDisplay
                    newDisplay=struct();
                    newDisplay.Parent=hFig;
                    newDisplay.Name=name;
                else
                    newDisplay=lidar.internal.lidarViewer.view.display.PCDisplay(hFig,name,limits);
                    addlistener(newDisplay,'DefaultCMapValSelected',@(~,~)notify(this,'DefaultCMapValSelected'));
                    addlistener(newDisplay,'DefaultCMapSelected',@(~,~)notify(this,'DefaultCMapSelected'));
                    addlistener(newDisplay,'ExternalTrigger',@(~,evt)notify(this,'ExternalTrigger',evt));

                    addlistener(newDisplay,'UserDrawingFinished',@(~,~)notify(this,'UserDrawingFinished'));
                    addlistener(newDisplay,'ObjectDeleted',@(~,~)notify(this,'ObjectDeleted'));
                    addlistener(newDisplay,'DisableToolstrip',@(~,~)notify(this,'DisableToolstrip'));
                    addlistener(newDisplay,'UpdateUndoRedoStack',@(~,evt)notify(this,'UpdateUndoRedoStack',evt));
                    addlistener(newDisplay,'DeleteFromUndoRedoStack',@(~,evt)notify(this,'DeleteFromUndoRedoStack',evt));
                    addlistener(newDisplay,'UpdateColorData',@(~,~)notify(this,'UpdateColorData'));
                    addlistener(newDisplay,'RequestToAddColor',@(~,evt)notify(this,'RequestToAddColor',evt));
                end

                this.Displays{end+1}=newDisplay;
            end
        end


        function removeDisplay(this,name)
            [dispExists,dispIdx]=doesNameExist(this,name);
            if dispExists
                delete(this.Displays{dispIdx});
                this.Displays(dispIdx)=[];
            end
        end


        function closeAllDisplays(this,toCloseNoneDisplay)



            allDisplays=this.Displays;
            for i=numel(allDisplays):-1:2
                this.removeDisplay(this.Displays{i}.Name)
            end

            if toCloseNoneDisplay
                this.Displays(1)=[];
            end

            notify(this,'UpdateUndoRedo');
        end
    end




    methods

        function changeDisplayColor(this,cmap,cmapVal,colorVariation,dataId)

            this.Displays{dataId+1}.setColorData(cmap,cmapVal,colorVariation);
        end


        function changeBackgroundColor(this,dataId,evt)

            this.Displays{dataId+1}.changeBackgroundColor(evt.Color);
        end


        function changeDisplayPointSize(this,dataId,pointSize)

            this.Displays{dataId+1}.setPointSize(pointSize);
        end


        function changePlanarView(this,dataId,view)

            this.Displays{dataId+1}.setPlanarView(view);
        end


        function setDefaultView(this,dataId)

            this.Displays{dataId+1}.setDefaultView();
        end


        function saveCameraView(this,dataId,viewName)

            this.Displays{dataId+1}.saveCameraView(viewName);
        end


        function organizeCameraView(this,dataId,actions)

            this.Displays{dataId+1}.organizeCameraView(actions);
        end


        function savedView=getSavedViewNames(this,dataId)

            savedView=this.Displays{dataId+1}.getSavedViewNames();
        end


        function deleteSavedView(this,dataId,viewName)

            this.Displays{dataId+1}.deleteSavedView(viewName);
        end


        function renameSavedView(this,dataId,oldName,newName)

            this.Displays{dataId+1}.renameSavedView(oldName,newName);
        end


        function changeCameraView(this,dataId,viewId)

            this.Displays{dataId+1}.changeCameraView(viewId);
        end


        function setCameraView(this,dataId,method,egoDirection)

            this.Displays{dataId+1}.setCameraView(method,egoDirection);
        end


        function setCameraProperties(this,dataId,pos,target,up,ang,azel,cZoom)

            this.Displays{dataId+1}.setCameraProperties(pos,target,up,ang,azel,cZoom);
        end


        function[pos,target,up,ang,cZoom]=getCameraProperties(this,dataId)
            [pos,target,up,ang,cZoom]=this.Displays{dataId+1}.getCameraProperties;
        end


        function setGroundRemoval(this,dataId,evt)

            if strcmp(evt.Mode,'segmentGroundSMRF')
                this.Displays{dataId+1}.setGroundRemoval(evt.HideGround,evt.Mode,...
                evt.ElevationAngleDelta,evt.InitialElevationAngle,...
                evt.MaxDistance,evt.ReferenceVector,evt.MaxAngularDistance,...
                evt.GridResolution,evt.ElevationThreshold,...
                evt.SlopeThreshold,evt.MaxWindowRadius);
            else
                this.Displays{dataId+1}.setGroundRemoval(evt.HideGround,evt.Mode,...
                evt.ElevationAngleDelta,evt.InitialElevationAngle,...
                evt.MaxDistance,evt.ReferenceVector,evt.MaxAngularDistance);
            end
        end


        function setClusterData(this,dataId,evt)
            this.Displays{dataId+1}.setClusterData(evt.ClusterData,...
            evt.Mode,evt.DistanceThreshold,evt.AngleThreshold,evt.MinDistance,evt.NumClusters);
        end


        function startColoringByClusters(this,dataId)
            this.Displays{dataId+1}.ColorByCluster=true;
        end


        function stopColoringByClusters(this,dataId)
            this.Displays{dataId+1}.ColorByCluster=false;
        end


        function viewGroundDataRequest(this,dataId)
            this.Displays{dataId+1}.viewGroundDataRequest();
        end


        function stopViewGroundDataRequest(this,dataId)
            this.Displays{dataId+1}.stopViewGroundDataRequest();
        end

        function customColormapRequest(this,evt,dataId)
            this.Displays{dataId+1}.customColormapRequest(evt);
        end
    end




    methods
        function stopMeasuringMetric(this,dataId)

            if dataId<numel(this.Displays)
                this.Displays{dataId+1}.stopMeasuringMetric();
            end
        end


        function evt=doMeasureMetric(this,dataId,evt)

            if dataId<numel(this.Displays)
                evt=this.Displays{dataId+1}.doMeasureMetric(evt);
            end
        end


        function changeToolColor(this,dataId,cMap,axesHandle)
            if dataId<numel(this.Displays)
                this.Displays{dataId+1}.changeToolColor(cMap,axesHandle);
            end
        end


        function TF=toEnableCancel(this,dataId)
            TF=this.Displays{dataId+1}.ToEnableCancel;
        end


        function measurementToolCreateObject(this,evt,dataId)
            if dataId<numel(this.Displays)
                this.Displays{dataId+1}.measurementToolCreateObject(evt);
            end
        end


        function stopCurrentTool(this,dataId)
            if dataId==0
                return;
            end

            if dataId<numel(this.Displays)
                this.Displays{dataId+1}.stopCurrentTool();
            end
        end
    end




    methods(Access=private)

        function tf=isNameUnused(this,name)

            tf=true;
            for i=1:this.NumDisplays
                if strcmp(this.Displays{i},name)
                    tf=false;
                    return;
                end
            end
        end


        function[tf,dispIdx]=doesNameExist(this,name)

            tf=false;
            dispIdx=0;
            for i=1:this.NumDisplays
                if strcmp(this.Displays{i}.Name,name)
                    tf=true;
                    dispIdx=i;
                    return;
                end
            end
        end
    end
    methods(Hidden,Access=?lidar.internal.lidarViewer.LVView)


        function cpoints=getColorFromCustomColormap(this,dataId,cmap)
            cpoints=this.Displays{dataId+1}.getColorFromCustomColormap(cmap);
        end
    end
end


