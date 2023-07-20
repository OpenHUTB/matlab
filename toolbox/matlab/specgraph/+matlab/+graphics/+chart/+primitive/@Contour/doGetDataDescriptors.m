function descriptors=doGetDataDescriptors(hObj,index,interpolationFactor)







    descriptors=matlab.graphics.chart.interaction.dataannotatable.SurfaceHelper.getDataDescriptors(hObj,index,interpolationFactor);


    descriptors(3)=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor('Level',descriptors(3).Value);
