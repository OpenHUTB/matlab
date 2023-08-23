classdef SensorCanvasKeyboard<matlabshared.application.ComponentKeyboard

    methods
        function escape(this)
            canvas=this.Component;
            if canvas.IsMoving||canvas.IsRotating

                canvas.IsMoving=false;
                canvas.IsRotating=false;
                index=canvas.SensorIndex;
                sensor=canvas.Application.SensorSpecifications(index);
                driving.birdsEyePlot.internal.plotCoverageArea(canvas.hCoverageAreas(index),...
                sensor.SensorLocation,sensor.MaxRange,sensor.Yaw,canvas.FieldOfViewCache(index));
                set(canvas.hCoverageAnchors(index),'XData',sensor.SensorLocation(1),'YData',sensor.SensorLocation(2));
            elseif canvas.IsCopying

                canvas.IsCopying=false;
                delete(canvas.hCoverageAreas(end));
                delete(canvas.hCoverageAnchors(end));
                canvas.hCoverageAreas(end)=[];
                canvas.hCoverageAnchors(end)=[];
            elseif strcmp(canvas.InteractionMode,'add')
                canvas.InteractionMode='move';
            end
            onMouseMove(canvas);
        end


        function delete_(this)
            canvas=this.Component;

            if canvas.IsMoving||canvas.IsCopying||canvas.IsRotating||~isStopped(canvas.Application.Simulator)
                return
            end

            if canvas.IsCopying
                canvas.IsCopying=false;
                delete(canvas.hCoverageAreas(end));
                delete(canvas.hCoverageAnchors(end));
                canvas.hCoverageAreas(end)=[];
                canvas.hCoverageAnchors(end)=[];
            elseif any(strcmp(canvas.InteractionMode,{'move','none'}))
                designer=canvas.Application;
                hideRotateWidget(canvas);
                index=getCurrentSensorIndex(designer);
                if isempty(index)||index>numel(designer.SensorSpecifications)
                    return;
                end
                edit=driving.internal.scenarioApp.undoredo.DeleteSensor(designer,index);
                applyEdit(designer,edit);
            end
        end
    end
end
