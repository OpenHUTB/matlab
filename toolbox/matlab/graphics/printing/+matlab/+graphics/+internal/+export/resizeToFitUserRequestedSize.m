
function pj=resizeToFitUserRequestedSize(pj,results)
    if strcmpi(pj.DriverClass,'IM')
        handler=matlab.graphics.internal.export.ImageOutputResizeHandler(pj,results);
    else
        handler=matlab.graphics.internal.export.VectorOutputResizeHandler(pj,results);
    end
    pj=handler.process();
end
