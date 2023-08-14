function[index,interp]=doIncrementIndex(hObj,index,direction,interpolationStep)







    index=matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.incrementIndex(index,direction,interpolationStep,size(hObj.ZData));
    interp=0;

