classdef InteractionStrategy<handle


    events
PostZoom
    end

    methods
        function setPanLimits(hObj,ax,x,y,z)
            if nargin>4
                hObj.set3DLimits(ax,x,y,z);
            else
                hObj.set2DLimits(ax,x,y);
            end
        end

        function setZoomLimits(hObj,ax,x,y,z)
            if nargin>4
                hObj.set3DLimits(ax,x,y,z);
            else
                hObj.set2DLimits(ax,x,y);
            end
        end

        function setUntransformedZoomLimits(hObj,ax,ds,x,y,z)
            try
                if nargin>5
                    [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.internal.UntransformLimits(ds,x,y,z);
                    hObj.setZoomLimits(ax,new_xlim,new_ylim,new_zlim);
                else
                    [new_xlim,new_ylim]=matlab.graphics.interaction.internal.UntransformLimits(ds,x,y,[0,1]);
                    hObj.setZoomLimits(ax,new_xlim,new_ylim);
                end
            catch
            end
        end

        function setUntransformedPanLimits(hObj,ax,ds,x,y,z)
            try
                if nargin>5
                    [new_xlim,new_ylim,new_zlim]=matlab.graphics.interaction.internal.UntransformLimits(ds,x,y,z);
                    hObj.setPanLimits(ax,new_xlim,new_ylim,new_zlim);
                else
                    [new_xlim,new_ylim]=matlab.graphics.interaction.internal.UntransformLimits(ds,x,y,[0,1]);
                    hObj.setPanLimits(ax,new_xlim,new_ylim);
                end
            catch
            end
        end

        function setView(~,ax,v)
            ax.View=v;
            drawnow expose;
        end

        function ret=isValidKeyEvent(~,~,~,~)
            ret=true;
        end

        function ret=isValidMouseEvent(~,~,~,~)
            ret=true;
        end

        function ret=isObjectHit(~,~,~,~)
            ret=true;
        end
    end

    methods(Sealed)
        function set2DLimits(~,ax,x,y)
            matlab.graphics.interaction.validateAndSetLimits(ax,x,y);
        end

        function set3DLimits(~,ax,x,y,z)
            matlab.graphics.interaction.validateAndSetLimits(ax,x,y,z);
        end

        function setPanLimitsInternal(hObj,ax,x,y,z)
            if nargin>4
                setPanLimits(hObj,ax,x,y,z);
            else
                setPanLimits(hObj,ax,x,y);
            end
        end

        function setZoomLimitsInternal(hObj,ax,x,y,z)
            if nargin>4
                setZoomLimits(hObj,ax,x,y,z);
            else
                setZoomLimits(hObj,ax,x,y);
            end

            drawnow update;
            notify(hObj,'PostZoom');
        end

        function setUntransformedPanLimitsInternal(hObj,hAxes,hDataSpace,norm_xlim,norm_ylim,norm_zlim)
            if nargin>5
                hObj.setUntransformedPanLimits(hAxes,hDataSpace,norm_xlim,norm_ylim,norm_zlim);
            else
                hObj.setUntransformedPanLimits(hAxes,hDataSpace,norm_xlim,norm_ylim);
            end
        end

        function setUntransformedZoomLimitsInternal(hObj,hAxes,hDataSpace,norm_xlim,norm_ylim,norm_zlim)
            if nargin>5
                hObj.setUntransformedZoomLimits(hAxes,hDataSpace,norm_xlim,norm_ylim,norm_zlim);
            else
                hObj.setUntransformedZoomLimits(hAxes,hDataSpace,norm_xlim,norm_ylim);
            end

            drawnow update;
            notify(hObj,'PostZoom');
        end

        function setViewInternal(hObj,ax,v)
            setView(hObj,ax,v);
        end
    end
end
