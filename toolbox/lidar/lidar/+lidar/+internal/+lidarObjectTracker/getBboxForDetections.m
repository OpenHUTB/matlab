
function bboxes=getBboxForDetections(detections)
    x=detections(:,1);
    y=detections(:,2);
    Xlength=detections(:,4);
    YLength=detections(:,5);

    bboxes=[x-Xlength/2,y-YLength/2,Xlength,YLength];
end