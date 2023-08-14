classdef RulerPanInteraction<matlab.graphics.interaction.interface.ConstrainableInteraction&matlab.graphics.interaction.interface.BaseInteraction




    methods(Hidden)
        function p=createInteraction(hObj,ax,fig)
            p=matlab.graphics.interaction.uiaxes.RulerPan(ax,fig,'WindowMousePress','WindowMouseMotion','WindowMouseRelease');
            p.Dimensions=hObj.Dimensions;
        end

        function p=createWebInteraction(hObj,can,ax)
            p=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction.empty;

            if contains(hObj.Dimensions,"x")
                rulerpanx=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
                rulerpanx.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Pan;
                rulerpanx.Axis='x';
                rulerpanx.Object=ax.XAxis;

                p(end+1)=rulerpanx;
            end

            if contains(hObj.Dimensions,"y")
                if(isscalar(ax.YAxis))
                    rulerpany=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
                    rulerpany.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Pan;
                    rulerpany.Axis='y';
                    rulerpany.Object=ax.YAxis;

                    p(end+1)=rulerpany;
                else
                    rulerpany1=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
                    rulerpany1.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Pan;
                    rulerpany1.Axis='y';
                    rulerpany1.Object=ax.YAxis(1);

                    p(end+1)=rulerpany1;

                    rulerpany2=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
                    rulerpany2.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Pan;
                    rulerpany2.Axis='y';
                    rulerpany2.Object=ax.YAxis(2);

                    p(end+1)=rulerpany2;
                end
            end

            if contains(hObj.Dimensions,"z")
                rulerpanz=matlab.graphics.interaction.graphicscontrol.InteractionObjects.RulerPanInteraction(can,ax);
                rulerpanz.MouseCursor=matlab.graphics.interaction.graphicscontrol.Enumerations.MouseCursors.Pan;
                rulerpanz.Axis='z';
                rulerpanz.Object=ax.ZAxis;

                p(end+1)=rulerpanz;
            end
        end
    end

end
