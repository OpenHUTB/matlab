classdef DataTipInteraction<matlab.graphics.interaction.interface.BaseInteraction



    properties
        SnapToDataVertex matlab.internal.datatype.matlab.graphics.datatype.on_off="on";
    end

    methods(Hidden)
        function dt=createInteraction(~,ax,fig)

            eventClickName='click';
            eventMoveName='WindowMouseMotion';
            eventDisableName='WindowMousePress';
            eventEnableName='WindowMouseRelease';
            eventScrollName='WindowScrollWheel';

            hTipProvider=matlab.graphics.interaction.uiaxes.DataTipProvider();
            dtClick=matlab.graphics.interaction.uiaxes.DatatipsClick(ax,fig,eventClickName,hTipProvider);
            dLingerHover=matlab.graphics.interaction.uiaxes.DatatipsHoverLinger(ax,fig,eventMoveName,eventDisableName,eventEnableName,eventScrollName,hTipProvider);
            dt=[dLingerHover,dtClick];

        end

        function dt=createWebInteraction(this,can,ax)
            eventMoveName='MouseMove';
            eventClickName='MouseClick';
            eventDisableName='DisableDatatips';
            eventEnableName='EnableDatatips';
            eventScrollName='MouseScroll';

            hTipProvider=matlab.graphics.interaction.uiaxes.DataTipProvider();





            dClickInteraction=matlab.graphics.interaction.uiaxes.DatatipsClick(ax,[],eventClickName,hTipProvider);
            dtClickWebInteraction=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipClickInteraction(can,ax,dClickInteraction);

            dHoverLinger=matlab.graphics.interaction.uiaxes.DatatipsHoverLinger(ax,[],eventMoveName,eventDisableName,eventEnableName,eventScrollName,hTipProvider);
            dHoverLingerWebInteraction=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipHoverLingerInteraction(can,ax,dHoverLinger);

            dEnableDisableInteraction=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DataTipDisableEnableInteraction(can,ax,dHoverLinger);

            dHoverClientWebInteraction=[];



            if isa(ax,'matlab.graphics.axis.Axes')
                dHoverClientWebInteraction=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DatatipsClientHoverInteraction(ax);
            end


            dClientDisableInteraction=matlab.graphics.interaction.graphicscontrol.InteractionObjects.DatatipsClientDisableInteraction(ax);


            dEnterExitInteraction=matlab.graphics.interaction.graphicscontrol.InteractionObjects.EnterExitInteraction;
            dEnterExitInteraction.Object=ax;
            dEnterExitInteraction.enable(can);

            dt=[dHoverLingerWebInteraction...
            ,dHoverClientWebInteraction...
            ,dClientDisableInteraction...
            ,dtClickWebInteraction...
            ,dEnableDisableInteraction...
            ,dEnterExitInteraction];
        end

        function dt=createGeographicInteraction(hObj,ax,fig)
            dt=hObj.createInteraction(ax,fig);
        end


        function dt=createGeographicWebInteraction(hObj,can,ax)
            dt=hObj.createWebInteraction(can,ax);
        end
    end
end
