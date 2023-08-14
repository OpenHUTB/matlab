function descriptors=doGetDataDescriptors(hObj,index,~)








    point=hObj.doGetReportedPosition(index,0);
    point=point.getLocation(hObj);


    dimensionNames=hObj.DimensionNames;


    [x,y]=matlab.graphics.internal.makeNonNumeric(hObj,point(1),point(2),[]);


    xDescriptors=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(dimensionNames{1},x);
    yDescriptors=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor(dimensionNames{2},y);
    descriptors=[xDescriptors,yDescriptors];

end
