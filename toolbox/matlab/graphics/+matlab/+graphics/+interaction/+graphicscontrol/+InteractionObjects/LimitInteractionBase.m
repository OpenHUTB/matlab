classdef LimitInteractionBase<handle





    properties
        DimX(1,1)logical=true;
        DimY(1,1)logical=true;
        DimZ(1,1)logical=true;
    end

    properties(Access=protected)
        OldLimits;
    end

    properties(Dependent)
Dimensions
    end

    methods
        function set.Dimensions(obj,val)
            obj.DimX=false;
            obj.DimY=false;
            obj.DimZ=false;
            if val.contains("x")
                obj.DimX=true;
            end
            if val.contains("y")
                obj.DimY=true;
            end
            if val.contains("z")
                obj.DimZ=true;
            end
        end
        function dim=get.Dimensions(obj)
            dim="";
            if(obj.DimX)
                dim=strcat(dim,"x");
            end
            if(obj.DimY)
                dim=strcat(dim,"y");
            end
            if(obj.DimZ)
                dim=strcat(dim,"z");
            end
        end
    end

    methods(Access=protected)

        function captureOldLimits(this,ax)
            this.OldLimits.X=ax.XLim;
            this.OldLimits.Y=ax.YLim;
            this.OldLimits.Z=ax.ZLim;
        end

        function addToUndoStack(this,ax,commandName)

            if(isempty(this.OldLimits))
                return;
            end

            new_xlim=ax.XLim;
            new_ylim=ax.YLim;
            new_zlim=ax.ZLim;


            fig=ancestor(ax,'figure');



            axProxy=plotedit({'getProxyValueFromHandle',ax});


            cmd.Name=commandName;


            cmd.Function=@changeLimits;
            cmd.Varargin={this,fig,axProxy,...
            new_xlim,new_ylim,new_zlim};


            cmd.InverseFunction=@changeLimits;
            cmd.InverseVarargin={this,fig,axProxy,...
            this.OldLimits.X,this.OldLimits.Y,this.OldLimits.Z};



            uiundo(fig,'function',cmd);
        end

        function changeLimits(~,fig,axProxy,x_lim,y_lim,z_lim)
            ax=plotedit({'getHandleFromProxyValue',fig,axProxy});

            if(~ishghandle(ax))
                return
            end

            ax.XLim=x_lim;
            ax.YLim=y_lim;
            ax.ZLim=z_lim;
            matlab.graphics.interaction.internal.restoreViewInteractions(ax);
        end

        function generateCode(~,ax)



            matlab.graphics.interaction.generateLiveCode(ax,...
            matlab.internal.editor.figure.ActionID.PANZOOM);
        end

    end

end

