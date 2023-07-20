

function name=getBehaviorName(~,var)
    name=[];
    if isempty(var)
        return;
    end


    dotIndex=strfind(var,'.');
    if~isempty(dotIndex)
        var=extractAfter(var,dotIndex);
    end

    import matlab.graphics.controls.internal.ToolbarValidator;

    switch lower(var)
    case ToolbarValidator.pan
        name='Pan';
    case ToolbarValidator.rotate
        name='Rotate3d';
    case ToolbarValidator.brush
        name='Brush';
    case ToolbarValidator.datacursor
        name='DataCursor';
    case ToolbarValidator.zoomin
        name='Zoom';
    case ToolbarValidator.zoomout
        name='Zoom';
    case ToolbarValidator.restoreview
        name='Reset';
    case ToolbarValidator.saveas
        name='SaveAs';
    case{ToolbarValidator.copyvector,ToolbarValidator.copyimage}
        name='Copy';
    case ToolbarValidator.export
        name='Export';
    end
end