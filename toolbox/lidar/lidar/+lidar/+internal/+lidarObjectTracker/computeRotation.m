












function correctedTrackPostion=computeRotation(data,trackPositions)

    xmin=trackPositions(1)-trackPositions(4)/2;
    xmax=trackPositions(1)+trackPositions(4)/2;
    ymin=trackPositions(2)-trackPositions(5)/2;
    ymax=trackPositions(2)+trackPositions(5)/2;
    X=data(:,1);
    Y=data(:,2);
    idx=(X>=xmin)&(X<=xmax)&(Y>=ymin)&(Y<=ymax);
    if any(idx)
        data=data(idx,:);
        ptCloudIn=pointCloud(data);
        model=pcfitcuboid(ptCloudIn,'AzimuthRange',[0,90]);
        correctedTrackPostion=model.Parameters;
        correctedTrackPostion(7:8)=[0,0];
    else
        correctedTrackPostion(7:9)=[0,0,0];
    end
end
