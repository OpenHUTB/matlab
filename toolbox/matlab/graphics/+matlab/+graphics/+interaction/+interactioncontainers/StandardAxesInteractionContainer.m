classdef StandardAxesInteractionContainer<matlab.graphics.interaction.interactioncontainers.BaseAxesInteractionContainer



    properties(Hidden)
        isLinked=false;
        ContainsPinnedScribeObject=false;
    end
    methods(Abstract)
        validateInteractions(obj,array)
        s=getDefaultStrategy(obj)
    end

    methods
        function hObj=StandardAxesInteractionContainer(ax)
            hObj=hObj@matlab.graphics.interaction.interactioncontainers.BaseAxesInteractionContainer(ax);
        end

        function newint=createInteraction(~,int,ax,fig)
            newint=int.createInteraction(ax,fig);
        end

        function newint=createWebInteraction(~,int,ax,fig)
            newint=int.createWebInteraction(ax,fig);
        end

        function ret=shouldRecreateWebModeInteractions(hObj,is2dim)




            ret=hObj.isFirst2DTo3D(is2dim)&&~strcmp(hObj.CurrentMode,'rotate');
        end

        function ret=isFirst2DTo3D(hObj,is2dim)
            ret=hObj.is2d&&~hObj.Ever3d&&~is2dim;
        end


        function ret=shouldRecreateInteractionsAfterStateUpdate(hObj,ax,is2dim,numDataSpaces)



            baseSet=isscalar(hObj.InteractionsArray)&&isa(hObj.InteractionsArray,'matlab.graphics.interaction.interface.BaseInteractionSet');
            first2DTo3D=hObj.isFirst2DTo3D(is2dim);

            autoPanRotateConvert=baseSet&&first2DTo3D;
            numDataSpacesChanged=~isempty(hObj.NumDataSpaces)&&(hObj.NumDataSpaces~=numDataSpaces);

            linkAxesAdded=~isempty(getappdata(ax,'graphics_linkaxes'))&&(hObj.isLinked==false);

            if linkAxesAdded==true
                hObj.isLinked=true;
            end

            scribeObjectPinned=~isempty(getappdata(ax,'ContainsPinnedScribeObject'))&&...
            ~hObj.ContainsPinnedScribeObject;

            if scribeObjectPinned
                hObj.ContainsPinnedScribeObject=true;
            end

            ret=autoPanRotateConvert||numDataSpacesChanged||linkAxesAdded||scribeObjectPinned;
        end

        function ret=shouldCreateDefaultWebInteractions(~,ax,can)
            ret=isa(can,'matlab.graphics.primitive.canvas.HTMLCanvas')&&...
            ~matlab.internal.editor.figure.FigureUtils.isEditorSnapshotGraphicsView(ancestor(ax,'figure'));
        end

        function int=addInternalInteractions(~,~,~)
            int=[];
        end
    end
end
