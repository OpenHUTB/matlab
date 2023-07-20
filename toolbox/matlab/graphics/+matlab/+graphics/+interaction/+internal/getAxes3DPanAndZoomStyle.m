function ver3D=getAxes3DPanAndZoomStyle(hFig,hAx)




    ver3D=cell(length(hAx),1);
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
        hBehavior=hggetbehavior(hAx(i),'Pan','-peek');
        if isempty(hBehavior)
            ver3D{i}='limits';
        else
            ver3D{i}=hBehavior.Version3D;
        end
    end