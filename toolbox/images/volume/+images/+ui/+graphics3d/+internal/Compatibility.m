classdef(Abstract,AllowedSubclasses=?images.ui.graphics3d.Volume)...
    Compatibility<handle








    properties(Hidden,Dependent,GetAccess=private)
BackgroundColor
CameraPosition
CameraTarget
CameraUpVector
CameraViewAngle
InteractionsEnabled
IsosurfaceColor
Lighting
Renderer
ScaleFactors
Isovalue
    end

    methods(Hidden)

        function setVolume(~,~)
            error(message('images:volume:removedMethod'));
        end

    end

    methods

        function set.BackgroundColor(~,~)
            error(message('images:volume:parentProperty',"BackgroundColor","BackgroundColor"));
        end

        function set.CameraPosition(~,~)
            error(message('images:volume:parentProperty',"CameraPosition","CameraPosition"));
        end

        function set.CameraTarget(~,~)
            error(message('images:volume:parentProperty',"CameraTarget","CameraTarget"));
        end

        function set.CameraUpVector(~,~)
            error(message('images:volume:parentProperty',"CameraUpVector","CameraUpVector"));
        end

        function set.CameraViewAngle(~,~)
            error(message('images:volume:removedProperty',"CameraViewAngle"));
        end

        function set.InteractionsEnabled(~,~)
            error(message('images:volume:parentProperty',"InteractionsEnabled","Interactions"));
        end

        function set.Isovalue(~,~)
            error(message('images:volume:renamedProperty',"Isovalue","IsosurfaceValue"));
        end

        function set.IsosurfaceColor(~,~)
            error(message('images:volume:renamedProperty',"IsosurfaceColor","Colormap"));
        end

        function set.Lighting(~,~)
            error(message('images:volume:parentProperty',"Lighting","Lighting"));
        end

        function set.Renderer(~,~)
            error(message('images:volume:renamedProperty',"Renderer","RenderingStyle"));
        end

        function set.ScaleFactors(~,~)
            error(message('images:volume:renamedProperty',"ScaleFactors","Transformation"));
        end

    end

end