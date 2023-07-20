function setAxes3DPanAndZoomStyle(hFig,hAx,ver3d)



    if~ischar(ver3d)||~(strcmp(ver3d,'limits')||strcmp(ver3d,'camera'))
        error(message('MATLAB:graphics:interaction:InvalidInputCameraLimits'));
    end
    if~all(ishghandle(hAx,'axes'))
        error(message('MATLAB:graphics:interaction:InvalidInputAxes'));
    end
    for i=1:length(hAx)
        ancestorFig=ancestor(hAx(i),'figure');
        if~isequal(hFig,ancestorFig)
            error(message('MATLAB:graphics:interaction:InvalidAxes'));
        end
    end
    for i=1:length(hAx)
        hPanBehavior=hggetbehavior(hAx(i),'Pan');
        hPanBehavior.Version3D=ver3d;

        hZoomBehavior=hggetbehavior(hAx(i),'Zoom');
        hZoomBehavior.Version3D=ver3d;
    end