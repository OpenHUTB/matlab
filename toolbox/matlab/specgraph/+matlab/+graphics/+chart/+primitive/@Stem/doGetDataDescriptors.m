function descriptors=doGetDataDescriptors(hObj,index,~)












    primpos=hObj.getReportedPosition(index,0);
    pos=primpos.getLocation(hObj);
    descriptors=matlab.graphics.chart.interaction.dataannotatable.internal.createPositionDescriptors(hObj,pos);
end