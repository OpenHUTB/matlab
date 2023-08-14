classdef DatatipsClientDisableInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase


    properties
ResponseData
    end

    properties(Constant)
        MARKER_DESCRIPTION=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DatatipsClientHoverInteraction.MARKER_DESCRIPTION;
    end

    methods
        function this=DatatipsClientDisableInteraction(ax)
            this.Type='disabledatatips';
            this.ResponseData=[];
            this.Object=ax;
            this.Actions=[matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.DragStart
            matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Scroll];
            this.updateResponseData();
        end

        function response(obj,eventdata)
        end
    end

    methods(Access=private)

        function updateResponseData(this)

            hLocators=findobjinternal(this.Object.ChildContainer.NodeChildren,'-isa','matlab.graphics.shape.internal.PointTipLocator');

            markerHandle=[];

            for i=1:length(hLocators)
                if strcmp(hLocators(i).ScribeHost.PeerHandle.DisplayHandle.Description,matlab.graphics.interaction.graphicscontrol.InteractionObjects.DatatipsClientHoverInteraction.MARKER_DESCRIPTION)
                    hLocator=hLocators(i);
                    markerHandle=hLocator.ScribeHost.DisplayHandle;
                    break;
                end
            end


            if isempty(markerHandle)
                this.ResponseData=NaN;
                return
            end

            this.ResponseData=getObjectID(markerHandle);
        end
    end
end

