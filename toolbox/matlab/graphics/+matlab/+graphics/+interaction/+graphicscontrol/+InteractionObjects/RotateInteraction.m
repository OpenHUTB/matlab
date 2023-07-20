classdef RotateInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase&...
    matlab.graphics.interaction.graphicscontrol.InteractionObjects.DragInteractionBase




    properties
Canvas
ax
fig
        disableHitTestDuringInteraction=true;
    end

    properties(Access=private)
OldView
    end

    methods
        function this=RotateInteraction(canvas,haxes)


            if(feature('ClientSideRotate'))
                this.Type='rotate';
            else
                this.Type='serversiderotate';
            end

            this.Canvas=canvas;
            this.ax=haxes;

            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.Drag;
        end

        function props=getPropertiesToSendToWeb(~)
            props={'disableHitTestDuringInteraction'};
        end
    end

    methods

        function preresponse(this,~)
            this.OldView=this.ax.View;
            this.fig=ancestor(this.ax,'figure');
            matlab.graphics.interaction.internal.toggleAxesLayoutManager(this.fig,this.ax,false);
        end

        function startdata=dragstart(this,eventdata)
            matlab.graphics.interaction.internal.initializeView(this.ax);

            point=[eventdata.figx,eventdata.figy];
            plotboxsize=eventdata.Source.getPlotBoxSize();
            view=eventdata.Source.getView();
            startdata=matlab.graphics.interaction.uiaxes.Rotate.startImpl(view,plotboxsize,1,point);
        end

        function dragprogress(this,eventdata,startdata)
            if~isempty(startdata)
                point=[eventdata.figx,eventdata.figy];
                new_view=matlab.graphics.interaction.uiaxes.Rotate.moveImpl(point,startdata);
                eventdata.Source.setView(new_view);
            end
        end

        function dragend(~,~,~)
        end

        function postresponse(this,~)
            oldView=this.OldView;
            newView=this.ax.View;
            this.addToUndoStack(oldView,newView);
            matlab.graphics.interaction.internal.toggleAxesLayoutManager(this.fig,this.ax,true);
            matlab.graphics.interaction.generateLiveCode(this.ax,matlab.internal.editor.figure.ActionID.ROTATE);
        end

    end

    methods(Access=private)

        function addToUndoStack(this,oldView,newView)

            if(isempty(oldView))
                return;
            end


            if(isempty(this.fig))
                this.fig=ancestor(this.ax,'figure');
            end



            axProxy=plotedit({'getProxyValueFromHandle',this.ax});


            cmd.Name='Rotate';


            cmd.Function=@changeView;
            cmd.Varargin={this,this.fig,axProxy,newView};


            cmd.InverseFunction=@changeView;
            cmd.InverseVarargin={this,this.fig,axProxy,oldView};



            uiundo(this.fig,'function',cmd);
        end

        function changeView(this,fig,axProxy,view)

            ax=plotedit({'getHandleFromProxyValue',fig,axProxy});

            if(~ishghandle(ax))
                return
            end

            ax.View=view;
        end

    end
end
