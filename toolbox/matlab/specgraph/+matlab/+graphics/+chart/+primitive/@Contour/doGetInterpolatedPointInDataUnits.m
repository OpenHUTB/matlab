function[index,interpolationFactor]=doGetInterpolatedPointInDataUnits(hObj,position)







    interpolationFactor=0;

    xData=hObj.XData;
    yData=hObj.YData;
    if strcmp(hObj.Is3D,'on')
        zData=hObj.ZData;
    else

        zData=zeros(size(hObj.ZData));
    end

    if localCheckDataConsistency(xData,yData,zData)
        pickUtils=matlab.graphics.chart.interaction.dataannotatable.picking.AnnotatablePicker.getInstance();




        [f,verts]=surf2patch(xData,yData,zData,'triangles');
        index=pickUtils.nearestFacePoint(hObj,position,false,f,verts);
    end


    function ret=localCheckDataConsistency(X,Y,Z)


        xSize=size(X);
        ySize=size(Y);
        zSize=size(Z);

        xOK=all(xSize==zSize)...
        ||(isvector(xSize)&&numel(X)==zSize(2));

        yOK=all(ySize==zSize)...
        ||(isvector(ySize)&&numel(Y)==zSize(1));

        ret=xOK&&yOK;