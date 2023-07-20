classdef(Abstract,Sealed)FigurePointToLocal
    methods(Static)
        function localPoint=translateFigurePointToLocal(local,figurePoint)

















            localPoint=figurePoint;
            hPanel=ancestor(local,'matlab.ui.internal.mixin.CanvasHostMixin','node');
            hFig=ancestor(local,'figure');
            if~isempty(hPanel)&&~isgraphics(hPanel,'figure')
                isUIFigure=matlab.ui.internal.isUIFigure(hFig);
                OffSet=matlab.ui.internal.GetPixelPositionHelper.getPixelPositionHelper(hPanel,true)-1;
                OffSet=OffSet+[matlab.ui.internal.GetPixelPositionHelper.getPixelPositionOffsetOneLevel(hPanel,isUIFigure),0,0];

                if isprop(hPanel,'Scrollable')&&hPanel.Scrollable
                    if isa(hPanel,'matlab.ui.container.GridLayout')

                        if~isempty(hPanel.Parent)
                            contentArea=hPanel.getScrollableContentArea();
                            viewArea=hPanel.Parent.InnerPosition;
                            OffSet(2)=OffSet(2)-(contentArea(4)-viewArea(4));
                        end
                    end



                    scrollInset=hPanel.getScrollbarsInset();
                    OffSet(2)=OffSet(2)+scrollInset(2);
                end

                hViewer=hPanel.getCanvas;
                deviceVP=double(hViewer.Viewport);

                ViewerLoc=hgconvertunits(hFig,deviceVP,'devicepixels','pixels',hPanel);
                OffSet=OffSet(1:2)+double(ViewerLoc(1:2))-1;

                if size(localPoint,1)==1

                    localPoint(1:2)=localPoint(1:2)-OffSet;
                else


                    localPoint(1,:)=localPoint(1,:)-OffSet(1);
                    localPoint(2,:)=localPoint(2,:)-OffSet(2);
                end
            end
        end
    end
end
