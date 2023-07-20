classdef TextInteractions<handle




    methods(Static)

        function createAndRegisterTextControl(t)

            canvas=matlab.graphics.interaction.internal.TextInteractions.getCanvas(t);
            if(isempty(canvas))
                return;
            end


            if(~isprop(t,'ObjectIDCache'))
                p=addprop(t,'ObjectIDCache');
                p.Hidden=true;
                p.Transient=true;
            end


            if(~strcmp(t.ObjectIDCache,getObjectID(t)))


                t.ObjectIDCache=getObjectID(t);



                if(isa(canvas,'matlab.graphics.primitive.canvas.HTMLCanvas'))
                    textcontrol=matlab.graphics.interaction.graphicscontrol.TextControl(t);
                    canvas.ControlManager.registerControl(t,textcontrol);
                end


                t.InteractionContainer.updateInteractions();

            end
        end

        function updateTextInteractionsOnReparenting(t)





            t.InteractionContainer.updateInteractions();
        end

        function can=getCanvas(t)
            can=ancestor(t,'matlab.graphics.primitive.canvas.Canvas','node');
        end

    end
end
