function updateUIContextMenu3DVersion(hFigure,version,hAxes)
    limits=findall(hFigure,'Tag','limits','Type','UIMenu');
    camera=findall(hFigure,'Tag','camera','Type','UIMenu');

    if~strcmp(version,'none')
        matlab.graphics.interaction.internal.setAxes3DPanAndZoomStyle(hFigure,hAxes,version);
    else


        version=matlab.graphics.interaction.internal.getAxes3DPanAndZoomStyle(hFigure,hAxes);
    end

    if strcmp(camera.Tag,version)
        camera.Checked='on';
        limits.Checked='off';
    else
        limits.Checked='on';
        camera.Checked='off';
    end