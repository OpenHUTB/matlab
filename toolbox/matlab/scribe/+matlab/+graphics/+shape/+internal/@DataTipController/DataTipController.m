classdef(Abstract)DataTipController<matlab.mixin.Heterogeneous&handle







    methods(Abstract)
        data=install(obj,tip);
        uninstall(obj,tip,data);
    end

    methods(Sealed)
        function ret=eq(A,B)
            ret=eq@handle(A,B);
        end
    end

    methods(Static)




        function setCurrentCursor(hTip)

            if~isempty(hTip)&&isvalid(hTip)&&strcmp(hTip.PinnedView,'on')
                hFig=ancestor(hTip,'figure');


                if~isempty(hFig)
                    dcm=localGetMode(hFig);
                    if~isempty(dcm)
                        if dcm.CurrentCursor~=hTip.Cursor
                            dcm.CurrentCursor=hTip.Cursor;








                            hUpListener=addlistener(hFig,'WindowMouseRelease',@(e,d)nDelayedBringToFront);
                            hMotionListener=addlistener(hFig,'WindowMouseMotion',@(e,d)nDelayedBringToFront);
                        end
                        hTip.CurrentTip='on';


                        if isempty(hTip.UIContextMenu)||~isvalid(hTip.UIContextMenu)
                            hTip.UIContextMenu=dcm.createOrGetContextMenu();
                        end
                    end
                end
            end
            function nDelayedBringToFront()
                if~isempty(hUpListener)
                    delete(hUpListener);
                end
                if~isempty(hMotionListener)
                    delete(hMotionListener);
                end
                if~isempty(hTip)&&isvalid(hTip)




                    hTip.TipHandle.ScribeHost.bringToFront();
                    hTip.LocatorHandle.ScribeHost.bringToFront();
                end
            end
        end




        function updateContextMenuIfNeeded(hTip)
            if~isempty(hTip)&&isvalid(hTip)&&strcmp(hTip.PinnedView,'on')
                hMenu=hTip.UIContextMenu;
                hContextMenuFig=ancestor(hMenu,'figure','node');
                hDataTipFig=ancestor(hTip,'figure','node');
                if hDataTipFig~=hContextMenuFig

                    dcm=localGetMode(hDataTipFig);
                    if~isempty(dcm)



                        hTip.UIContextMenu=dcm.createOrGetContextMenu();
                    end
                end
            end
        end
    end

    methods(Access=protected,Static)

        function showContextMenu(hMenu)





            if~isempty(hMenu)&&ishghandle(hMenu)
                hFig=ancestor(hMenu,'figure');

                if~isempty(hFig)&&~matlab.internal.editor.figure.FigureUtils.isEditorSnapshotFigure(hFig)
                    figPoint=hFig.CurrentPoint;
                    figPoint=hgconvertunits(hFig,[figPoint,0,0],hFig.Units,'pixels',hFig);
                    figPoint=figPoint(1:2);
                    hMenu.Position=figPoint;

                    hgfeval(hMenu.Callback,hMenu,[]);
                    hMenu.Visible='on';
                end
            end
        end

        function ret=isTipInteractionEnabled(hTip)










            hFig=ancestor(hTip,'figure');
            ret=isempty(hFig)...
            ||(~hasOtherModeActive(hFig)...
            &&~matlab.internal.editor.figure.FigureUtils.isEditorSnapshotGraphicsView(hFig));
        end
    end
end

function ret=hasOtherModeActive(hFig)


    ret=~isactiveuimode(hFig,'Exploration.Datacursor');


    if ret
        mm=uigetmodemanager(hFig);
        ret=~isempty(mm.CurrentMode)...
        &&isobject(mm.CurrentMode)...
        &&isvalid(mm.CurrentMode)...
        &&~strcmp(mm.CurrentMode.Name,'Standard.EditPlot');
    end
end

function dcm=localGetMode(hFig)

    if~isempty(hFig)
        dcm=datacursormode(hFig);
    else
        dcm=[];
    end
end