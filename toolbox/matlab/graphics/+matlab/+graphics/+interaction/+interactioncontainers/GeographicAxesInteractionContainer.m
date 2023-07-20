classdef GeographicAxesInteractionContainer<matlab.graphics.interaction.interactioncontainers.BaseAxesInteractionContainer




    properties
        InternalList=[]
    end

    methods
        function hObj=GeographicAxesInteractionContainer(ax)
            hObj=hObj@matlab.graphics.interaction.interactioncontainers.BaseAxesInteractionContainer(ax);
        end

        function arr=getDefaultInteractionsArray(~)
            arr=matlab.graphics.interaction.interface.DefaultGeographicAxesInteractionSet;
        end

        function s=getDefaultStrategy(~)
            s=matlab.graphics.internal.maps.GeographicAxesInteractionStrategy();
        end

        function validateInteractions(~,ints)
            for i=1:numel(ints)
                isInvalidGeographicInteraction=isa(ints(i),'matlab.graphics.interaction.interface.BaseInteraction')&&...
                ~(isa(ints(i),'matlab.graphics.interaction.interactions.DataTipInteraction')...
                ||isa(ints(i),'matlab.graphics.interaction.interactions.ZoomInteraction')...
                ||isa(ints(i),'matlab.graphics.interaction.interactions.PanInteraction'));

                isInteractionSetAndNotGeographic=isa(ints(i),'matlab.graphics.interaction.interface.BaseInteractionSet')&&...
                ~isa(ints(i),'matlab.graphics.interaction.interface.DefaultGeographicAxesInteractionSet');

                if isInvalidGeographicInteraction||isInteractionSetAndNotGeographic
                    ME=MException(message('MATLAB:graphics:interaction:GeographicAxesInteractionsProperty',class(ints(i))));
                    throwAsCaller(ME);
                end
            end
        end

        function clearList(hObj)


            clearList@matlab.graphics.interaction.interactioncontainers.BaseAxesInteractionContainer(hObj)
            hObj.InternalList=[];
        end

        function list=createDefaultWebAxesInteractions(hObj,intarray)
            list=createDefaultWebAxesInteractions@matlab.graphics.interaction.interactioncontainers.BaseAxesInteractionContainer(hObj,intarray);


            gx=hObj.GObj;
            fig=ancestor(gx,'figure');
            keystrokes=addInternalInteractions(hObj,gx,fig);
            keystrokes.strategy=hObj.getStrategy;
            keystrokes.enable()
            hObj.InternalList=keystrokes;
        end

        function newint=createInteraction(~,int,ax,fig)
            newint=int.createGeographicInteraction(ax,fig);
        end

        function newint=createWebInteraction(~,int,ax,fig)
            newint=int.createGeographicWebInteraction(ax,fig);
        end

        function keystrokes=addInternalInteractions(hObj,ax,fig)

            keystrokes=matlab.graphics.chart.internal.maps.PanZoomKeystrokes(ax,fig);
        end

        function tf=shouldRecreateInteractionsAfterStateUpdate(hObj,ax,is2dim,numDataSpaces)



            tf=false;
        end

        function tf=shouldRecreateWebModeInteractions(hObj,is2dim)

            tf=false;
        end

        function tf=shouldCreateDefaultWebInteractions(hObj,ax,can)


            tf=isa(can,'matlab.graphics.primitive.canvas.HTMLCanvas')&&...
            ~matlab.internal.editor.figure.FigureUtils.isEditorSnapshotGraphicsView(ancestor(ax,'figure'));
        end
    end
end
