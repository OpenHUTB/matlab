classdef ResetPlotInteraction<matlab.graphics.interaction.graphicscontrol.InteractionObjects.InteractionBase




    properties
Figure
Axes
    end

    properties(Access=private)
OldView
OldLimits
    end

    methods
        function this=ResetPlotInteraction(hAxes)
            this.Object=hAxes;
            this.Axes=hAxes;

            this.Action=matlab.graphics.interaction.graphicscontrol.Enumerations.Action.DoubleClick;
            this.Type='reset';
        end

        function preresponse(this,~)
            this.OldView=this.Axes.View;
            this.OldLimits.X=this.Axes.XLim;
            this.OldLimits.Y=this.Axes.YLim;
            this.OldLimits.Z=this.Axes.ZLim;
            this.Figure=ancestor(this.Axes,'figure');
        end

        function response(this,~)
            resetplotview(this.Axes,'ApplyStoredView');
        end

        function postresponse(this,~)
            oldView=this.OldView;
            newView=this.Axes.View;
            oldLimits=this.OldLimits;
            newLimits.X=this.Axes.XLim;
            newLimits.Y=this.Axes.YLim;
            newLimits.Z=this.Axes.ZLim;
            this.addToUndoStack(oldView,newView,oldLimits,newLimits);
        end
    end

    methods(Access=private)

        function addToUndoStack(this,oldView,newView,oldLimits,newLimits)

            if(isempty(oldView)||isempty(oldLimits))
                return;
            end


            if(isempty(this.Figure))
                this.Figure=ancestor(this.Axes,'figure');
            end



            axProxy=plotedit({'getProxyValueFromHandle',this.Axes});


            cmd.Name='Reset';


            cmd.Function=@changeLimitsAndView;
            cmd.Varargin={this,this.Figure,axProxy,newView,newLimits};


            cmd.InverseFunction=@changeLimitsAndView;
            cmd.InverseVarargin={this,this.Figure,axProxy,oldView,oldLimits};



            uiundo(this.Figure,'function',cmd);
        end

        function changeLimitsAndView(~,fig,axProxy,view,limits)

            ax=plotedit({'getHandleFromProxyValue',fig,axProxy});

            if(~ishghandle(ax))
                return
            end

            ax.View=view;

            ax.XLim=limits.X;
            ax.YLim=limits.Y;
            ax.ZLim=limits.Z;
        end

    end
end

