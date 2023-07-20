function ret=doGetDataDescriptors(hObj,index,~)












    primpos=getReportedPosition(hObj,index,0);
    location=primpos.getLocation(hObj);

    xName='X';
    yName='Y';

    yStacked=matlab.graphics.chart.interaction.dataannotatable.DataDescriptor.empty;


    if hObj.NumPeers>1

        yName='Y (Segment)';
        yStackName='Y (Stacked)';


        primstackedpos=getDisplayAnchorPoint(hObj,index,0);
        stackedlocation=primstackedpos.getLocation(hObj);


        yStackedDescriptor=matlab.graphics.chart.interaction.dataannotatable.internal.createPositionDescriptors(hObj,stackedlocation,{'X',yStackName,''});
        yStacked=yStackedDescriptor(2);
    end

    XYdescriptors=matlab.graphics.chart.interaction.dataannotatable.internal.createPositionDescriptors(hObj,location,{xName,yName});

    ret=[XYdescriptors(1),yStacked,XYdescriptors(2)];
