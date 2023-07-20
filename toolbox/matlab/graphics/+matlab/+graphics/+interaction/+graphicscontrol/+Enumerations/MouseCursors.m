classdef MouseCursors




    enumeration
Pan
Zoom
ZoomOut
Zoom3d
Rotate
Fleur
Resize
DataTip
Pointer
IBeam
None
    end

    methods
        function output=toString(cursor)
            switch cursor
            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Pan
                output="pan";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Zoom
                output="zoom";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.ZoomOut
                output="zoomout";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Zoom3d
                output="zoom3d";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Rotate
                output="rotate";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Fleur
                output="fleur";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Resize
                output="resize";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.DataTip
                output="initial";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Pointer
                output="initial";

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.None
                output='none';

            case matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.IBeam
                output='ibeam';

            otherwise
                output="none";
            end
        end
    end
end
