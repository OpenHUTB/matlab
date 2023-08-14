function M=getModelViewProjectionMatrix(a)


    vp=matlab.graphics.interaction.internal.getViewProjectionMatrix(a);

    M=vp*a.DataSpace.getMatrix;

