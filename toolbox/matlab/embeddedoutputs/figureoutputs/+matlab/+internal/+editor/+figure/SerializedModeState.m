classdef(Hidden)SerializedModeState<handle







    properties
SerializedPanState
SerializedZoomState
SerializedRotateState
SerializedDataCursorState
    end

    methods



        function deserialize(this,hFig,currentModeName)



            switch(currentModeName)
            case{'Exploration.Pan'}
                if~isempty(this.SerializedPanState)
                    panModeAccessor=pan(hFig);


                    panModeAccessor.Motion=this.SerializedPanState.Motion;
                end
            case{'Exploration.Rotate3d'}
                if~isempty(this.SerializedRotateState)
                    rotateModeAccessor=rotate3d(hFig);


                    rotateModeAccessor.RotateStyle=this.SerializedRotateState.RotateStyle;
                end
            case{'Exploration.Zoom'}
                if~isempty(this.SerializedZoomState)
                    zoomModeAccessor=zoom(hFig);


                    zoomModeAccessor.Direction=this.SerializedZoomState.Direction;
                    zoomModeAccessor.Motion=this.SerializedZoomState.Motion;
                    zoomModeAccessor.RightClickAction=this.SerializedZoomState.RightClickAction;
                end
            case{'Exploration.Datacursor'}
                if~isempty(this.SerializedDataCursorState)

                    dataCursorModeAccessor=datacursormode(hFig);

                    dataCursorModeAccessor.SnapToDataVertex=this.SerializedDataCursorState.SnapToDataVertex;
                    dataCursorModeAccessor.UpdateFcn=this.SerializedDataCursorState.UpdateFcn;
                    dataCursorModeAccessor.Interpreter=this.SerializedDataCursorState.Interpreter;
                end
            end
        end

        function deserializeForPoppedOutFigure(this,hFig)
            this.deserialize(hFig,'Exploration.Datacursor');
            this.deserialize(hFig,'Exploration.Rotate3d');
            this.deserialize(hFig,'Exploration.Zoom');
            this.deserialize(hFig,'Exploration.Pan');
        end



        function serialize(this,fig)

            if isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)
                dataCursorUIMode=getMode(fig.ModeManager,'Exploration.Datacursor');
                if~isempty(dataCursorUIMode)&&~isempty(dataCursorUIMode.ModeStateData)&&...
                    isfield(dataCursorUIMode.ModeStateData,'DataCursorTool')
                    dataCursorModeAccessor=dataCursorUIMode.ModeStateData.DataCursorTool;
                    this.SerializedDataCursorState.SnapToDataVertex=dataCursorModeAccessor.SnapToDataVertex;
                    this.SerializedDataCursorState.UpdateFcn=dataCursorModeAccessor.UpdateFcn;
                    this.SerializedDataCursorState.Interpreter=dataCursorModeAccessor.Interpreter;
                else
                    this.SerializedDataCursorState=[];
                end

                panUIMode=getMode(fig.ModeManager,'Exploration.Pan');
                if~isempty(panUIMode)&&~isempty(panUIMode.ModeStateData)&&...
                    isfield(panUIMode.ModeStateData,'accessor')
                    this.SerializedPanState.Motion=panUIMode.ModeStateData.accessor.Motion;
                else
                    this.SerializedPanState=[];
                end

                zoomUIMode=getMode(fig.ModeManager,'Exploration.Zoom');
                if~isempty(zoomUIMode)&&~isempty(zoomUIMode.ModeStateData)&&...
                    isfield(zoomUIMode.ModeStateData,'accessor')
                    zoomModeAccessor=zoomUIMode.ModeStateData.accessor;
                    this.SerializedZoomState.Direction=zoomModeAccessor.Direction;
                    this.SerializedZoomState.Motion=zoomModeAccessor.Motion;
                    this.SerializedZoomState.RightClickAction=zoomModeAccessor.RightClickAction;
                else
                    this.SerializedZoomState=[];
                end


                rotateUIMode=getMode(fig.ModeManager,'Exploration.Rotate3d');
                if~isempty(rotateUIMode)&&~isempty(rotateUIMode.ModeStateData)&&...
                    isfield(rotateUIMode.ModeStateData,'accessor')
                    this.SerializedRotateState.RotateStyle=rotateUIMode.ModeStateData.accessor.RotateStyle;
                else
                    this.SerializedRotateState=[];
                end
            else
                this.SerializedPanState=[];
                this.SerializedZoomState=[];
                this.SerializedRotateState=[];
                this.SerializedDataCursorState=[];
            end
        end

        function mode=getCurrentMode(~,fig)


            mode='';
            if isprop(fig,'ModeManager')&&~isempty(fig.ModeManager)&&...
                isprop(fig.ModeManager,'CurrentMode')&&~isempty(fig.ModeManager.CurrentMode)
                mode=fig.ModeManager.CurrentMode.Name;
            end
        end
    end
end