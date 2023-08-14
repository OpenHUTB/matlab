classdef GCAClickInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase




    properties
Axes
    end

    methods(Static)

        function highlight(fig,ax)

            persistent fadeTimer;
mlock


            if isa(fig.getCanvas,'matlab.graphics.primitive.canvas.JavaCanvas')
                return
            end


            scribelayer=matlab.graphics.annotation.internal.getDefaultCamera(fig,'overlay','-peek');
            highlighter=get(scribelayer,'Highlighter');


            try
                layoutInfo=ax.GetLayoutInformation;
                box=layoutInfo.PlotBox;
                coords=hgconvertunits(fig,box,'pixels','normalized',fig);
            catch
                coords=hgconvertunits(fig,getpixelposition(ax),'pixels','normalized',fig);
            end


            vd=[coords(1),coords(2),0;...
            coords(1)+coords(3),coords(2),0;...
            coords(1)+coords(3),coords(2)+coords(4),0;...
            coords(1),coords(2)+coords(4),0]';
            set(highlighter,'VertexData',single(vd));


            if isempty(fadeTimer)||~isvalid(fadeTimer)
                fadeTimer=timer('StartDelay',1,'ExecutionMode','singleShot',...
                'Tag','gcaInteractionTimer','ObjectVisibility','off');
            end
            fadeTimer.TimerFcn=@(e,d)matlab.graphics.internal.drawnow.callback(@()localFadeOut(highlighter));


            highlighter.Visible='on';




            fadeTimer.stop;
            fadeTimer.start;
        end

        function highlightgca




            f=get(groot,'CurrentFigure');
            if isempty(f)
                return
            end


            modeManager=uigetmodemanager(f);
            isPloteditMode=~isempty(modeManager)&&~isempty(modeManager.CurrentMode)&&...
            strcmp(modeManager.CurrentMode.Name,'Standard.EditPlot');
            if isPloteditMode
                return
            end

            curAx=[];

            if isprop(f,'CurrentAxes')
                curAx=f.CurrentAxes;
            end

            if~isempty(curAx)&&numel(findall(f,'type','axes'))>1
                scribelayer=matlab.graphics.annotation.internal.getDefaultCamera(f,'overlay','-peek');





                if~isprop(scribelayer,'Highlighter')

                    matlab.graphics.interaction.graphicscontrol.InteractionObjects.GCAClickInteraction.buildHighlighter(f);
                end


                matlab.graphics.interaction.graphicscontrol.InteractionObjects.GCAClickInteraction.highlight(f,curAx);
            end
        end

        function buildHighlighter(fig)
            scribelayer=matlab.graphics.annotation.internal.getDefaultCamera(fig,'overlay','-peek');

            highlighter=matlab.graphics.primitive.world.LineLoop;
            set(highlighter,'StripData',uint32([1,5]));
            set(highlighter,'LineJoin','miter');
            highlighter.ColorBinding_I='object';
            highlighter.ColorType_I='truecoloralpha';
            highlighter.ColorData=uint8([3,152,252,255]');
            highlighter.LineWidth=2;
            highlighter.Visible='off';


            scribelayer.addNode(highlighter);


            if~isprop(scribelayer,'Highlighter')
                pHighlighter=addprop(scribelayer,'Highlighter');
                pHighlighter.Transient=true;
                pHighlighter.Hidden=true;
            end

            set(scribelayer,'Highlighter',highlighter);
        end

    end
    methods
        function this=GCAClickInteraction(ax)
            this.Type='gcaclick';
            this.ID=uint64(0);
            this.ObjectPeerID=uint64(0);
            this.Axes=ax;
            this.Object=ax;
            this.Actions=matlab.graphics.interaction.graphicscontrol.Enumerations.Actions.Click;
        end

        function response(~,eventdata)
            if strcmp(eventdata.name,'click')
                if~strcmp(eventdata.Source.Axes.HandleVisibility,'on')
                    return

                end

                matlab.graphics.interaction.graphicscontrol.InteractionObjects.GCAClickInteraction.highlightgca
            end
        end
    end
end

function localFadeOut(highlighter)
    if~isvalid(highlighter)
        return
    end
    highlighter.Visible='off';

end
