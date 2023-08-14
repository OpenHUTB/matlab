function hObj=doloadobj(hObj)





    hP=findobjinternal(hObj,'Type','patch');
    if~isempty(hP)&&~isempty(hObj.XData)

        hObj.CData=hP.FaceVertexCData(1);

        hObj.YOffSet=hP.YData(1,:);


        hObj.XOffset=(hP.XData(2,1)+hP.XData(3,1))/2-hObj.XData(1);


        hObj.WidthScaleFactor=((hP.XData(3,1)-hObj.XData(1))-(hP.XData(2,1)-hObj.XData(1)))/hObj.BarWidth;
    end

    matlab.graphics.chart.internal.deleteNonPrimitiveChildren(hObj);



    if isa(hObj.Edge_I,'matlab.graphics.primitive.world.LineStrip')
        hObj.Edge_I=matlab.graphics.primitive.world.LineLoop;
        hObj.Edge_I.Description_I='Bar Edge';
        hObj.Edge_I.Internal=true;

        hObj.Edge_I.LineWidth_I=hObj.LineWidth_I;
        hObj.Edge_I.Clipping_I=hObj.Clipping_I;
        hgfilter('LineStyleToPrimLineStyle',hObj.Edge_I,hObj.LineStyle);
    end



    if isnan(hObj.CData)
        hObj.CData_I=hObj.FaceColorIndex;
    end


    hObj.addBarListeners;

end
