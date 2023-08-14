function setPcbSubstrateDimensions(obj,temp)

    if isa(obj.BoardShape,'antenna.Rectangle')||isa(obj.BoardShape,'traceRectangular')
        temp.Length=obj.BoardShape.Length;
        temp.Width=obj.BoardShape.Width;
    elseif isa(obj.BoardShape,'antenna.Circle')
        temp.Radius=obj.BoardShape.Radius;
    elseif isa(obj.BoardShape,'antenna.Polygon')
        temp.Vertices=obj.BoardShape.ShapeVertices;
    end
    if isscalar(temp.Thickness)
        temp.Thickness=obj.BoardThickness;
    end

end