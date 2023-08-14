function hObj=doloadobj(hObj)





    if isa(hObj.Edge_I,'matlab.graphics.primitive.world.LineStrip')
        hObj.Edge_I=matlab.graphics.primitive.world.LineLoop;
        hObj.Edge_I.Description_I='Rectangle Edge';
        hObj.Edge_I.Internal=true;

        hObj.Edge_I.LineWidth_I=hObj.LineWidth_I;
        hgfilter('LineStyleToPrimLineStyle',hObj.Edge_I,hObj.LineStyle);
        hgfilter('RGBAColorToGeometryPrimitive',hObj.Edge_I,hObj.EdgeColor);
    end



    hObj=doloadobj@matlab.graphics.shape.internal.ScribeObject(hObj);

end
