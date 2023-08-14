classdef ArrowKeyPan<matlab.graphics.interaction.uiaxes.KeyHold&matlab.graphics.interaction.uiaxes.InteractionBase


    properties
        keyspeed=5;
    end

    properties(Access=private)
        totalPixel=[];
    end

    methods
        function hObj=ArrowKeyPan(ax,source,keypressname,keyreleasename)
            keynames={'uparrow','downarrow','leftarrow','rightarrow'};
            hObj=hObj@matlab.graphics.interaction.uiaxes.KeyHold(ax,keynames,source,keypressname,keyreleasename);
            hObj=hObj@matlab.graphics.interaction.uiaxes.InteractionBase;
        end
    end

    methods(Access={?tmatlab_graphics_interaction_uiaxes_ArrowKeyPan,...
        ?matlab.graphics.interaction.uiaxes.KeyHold})
        function custom=start(hObj,~,~,ck)
            import matlab.graphics.interaction.*
            switch(ck)
            case 'leftarrow'
                custom.currPixel=[hObj.keyspeed,0];
            case 'rightarrow'
                custom.currPixel=[-hObj.keyspeed,0];
            case 'uparrow'
                custom.currPixel=[0,-hObj.keyspeed];
            case 'downarrow'
                custom.currPixel=[0,hObj.keyspeed];
            end
            hObj.totalPixel=custom.currPixel;

            custom.start_point_pixels=[0,0];
            custom.ruler_lengths=hObj.ax.GetLayoutInformation.PlotBox(3:4);
            custom.orig_limits=[0,1,0,1,0,1];
            custom.orig_ds=internal.copyDataSpace(hObj.ax.DataSpace);

            trans_limits=internal.pan.panFromPixelToPixel2D(custom.orig_limits,hObj.totalPixel,custom.ruler_lengths);
            [xl,yl]=internal.UntransformLimits(custom.orig_ds,trans_limits(1:2),trans_limits(3:4),[0,1]);
            hObj.strategy.setPanLimitsInternal(hObj.ax,xl,yl);
        end

        function hold(hObj,~,~,custom)
            import matlab.graphics.interaction.*
            trans_limits=internal.pan.panFromPixelToPixel2D(custom.orig_limits,hObj.totalPixel,custom.ruler_lengths);
            [xl,yl]=internal.UntransformLimits(custom.orig_ds,trans_limits(1:2),trans_limits(3:4),[0,1]);
            hObj.strategy.setPanLimitsInternal(hObj.ax,xl,yl);
            hObj.totalPixel=hObj.totalPixel+custom.currPixel;
        end

        function stop(hObj,~,~,~)
            hObj.totalPixel=[];
        end
    end
end


