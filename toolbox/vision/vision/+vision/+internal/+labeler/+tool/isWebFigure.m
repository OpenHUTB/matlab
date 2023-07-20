function TF=isWebFigure(figHandle)

    TF=isa(getCanvas(figHandle),'matlab.graphics.primitive.canvas.HTMLCanvas');
end