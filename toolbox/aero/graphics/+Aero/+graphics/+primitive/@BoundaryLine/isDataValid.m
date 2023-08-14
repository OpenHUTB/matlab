function tf=isDataValid(hObj,throwError)




    x=hObj.XData;
    y=hObj.YData;

    tf=true;

    if numel(x)<2||~isvector(x)
        maybeThrowError("aero_graphics:BoundaryLine:mustBeVector",throwError)
        tf=false;
    end
    if numel(y)<2||~isvector(y)
        maybeThrowError("aero_graphics:BoundaryLine:mustBeVector",throwError)
        tf=false;
    end
    if numel(x)~=numel(y)
        maybeThrowError("aero_graphics:BoundaryLine:IncompatibleData",throwError)
        tf=false;
    end

end

function maybeThrowError(msg,throwError)
    if throwError
        error(message(msg))
    end
end