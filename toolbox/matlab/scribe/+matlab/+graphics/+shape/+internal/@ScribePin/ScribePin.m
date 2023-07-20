
classdef(CaseInsensitiveProperties=true,TruncatedProperties=true)ScribePin<handle




    properties(SetAccess=private,Transient=true)
        Axes=matlab.graphics.axis.Axes.empty;
    end

    properties(SetAccess=private)
        PixelLocation=[0,0];
    end
    properties(SetAccess=private,GetAccess=private,Transient=true)
        AxesListener=event.listener.empty;
    end
    properties(SetAccess=private)
        DataCoords=[];
    end

    properties(SetAccess=private)
        DoNotify=true;
    end
    properties(SetAccess=public,GetAccess=public)
        UserData;


        MovePosition=[];
    end

    methods
        function hObj=ScribePin(hContainer,pixelLocation)
            assert(isa(hContainer,'matlab.ui.internal.mixin.CanvasHostMixin'),...
            'MATLAB:scribe:pin:invalidFigure','The first argument must be a figure, uipanel or uitab.');
            if nargin>=2
                hObj.repin(pixelLocation,hContainer);
            end
        end





        function repin(hObj,pixelLocation,hContainer,hAxes)
            hObj.DoNotify=false;
            if nargin>=4&&~isempty(hAxes)
                hObj.updateAxes(pixelLocation,hContainer,hAxes);
            else
                hObj.updateAxes(pixelLocation,hContainer);
            end
            hObj.updateDataCoords(hContainer,pixelLocation);
            hObj.PixelLocation=pixelLocation;
            hObj.DoNotify=true;
        end



        function pixelLocation=getPixelLocation(hObj,hContainer)


            if~isempty(hObj.MovePosition)
                pixelLocation=hObj.MovePosition;
                return
            end




            if isempty(hObj.Axes)
                pixelLocation=hObj.PixelLocation;
                if~isempty(hContainer)
                    hObj.updateAxes(pixelLocation,hContainer);
                else
                    return;
                end
            end
            if isempty(hObj.Axes)
                return
            end

            pixelLocation=matlab.graphics.chart.internal.convertDataSpaceCoordsToViewerCoords(hObj.Axes,hObj.DataCoords(:));
            pixelLocation=pixelLocation(:)';
            hObj.PixelLocation=pixelLocation;
        end
    end

    methods
        function updateDataCoords(hObj,hContainer,pixelPosition)
            if isempty(hObj.Axes)
                if~isempty(hContainer)
                    hObj.updateAxes(pixelPosition,hContainer);
                else
                    return;
                end
            end
            if isempty(hObj.Axes)
                hObj.DataCoords=[];
                return
            end

            verts=matlab.graphics.chart.internal.convertViewerCoordsToDataSpaceCoords(hObj.Axes,pixelPosition(:)');
            hObj.DataCoords=double(verts.');
        end

        function updateAxes(hObj,pixelLocation,hContainer,hAx)
            if isempty(hContainer)
                return
            end
            if nargin<=3||isempty(hAx)

                hAx=matlab.graphics.axis.Axes.empty;

                axList=findobj(hContainer,'-isa','matlab.graphics.axis.AbstractAxes');
                hFig=ancestor(hContainer,'figure');
                vp=matlab.graphics.interaction.internal.getViewportInDevicePixels(hFig,hContainer);
                if~isempty(axList)
                    for i=1:numel(axList)
                        if matlab.graphics.interaction.internal.isAxesHit(axList(i),vp,pixelLocation,[0,0])
                            hAx=axList(i);
                            break;
                        end
                    end
                end
            end
            hObj.Axes=hAx;
            if~isempty(hAx)
                hObj.AxesListener=event.listener({hAx;hAx.DataSpace;hAx.Camera},'MarkedDirty',@(obj,evd)(hObj.sendChangedCallback));
                hObj.AxesListener(2)=event.listener(hAx,'ObjectBeingDestroyed',@(obj,evd)(delete(hObj)));
            else
                hObj.AxesListener=event.listener.empty;
            end
        end

        function sendChangedCallback(hObj)
            if hObj.DoNotify
                hObj.notify('PinChanged');
            end
        end
    end

    events
        PinChanged;
    end
end
