function waypoints=getAutoWaypoints(pos,closed)








    n=size(pos,1);
    waypoints=false([n,1]);


    pos=diff([pos;pos(1,:)]);
    posLength=hypot(pos(:,1),pos(:,2));
    cumLength=cumsum(posLength);
    diag=hypot(max(pos(:,1))-min(pos(:,1)),max(pos(:,2))-min(pos(:,2)));

    if diag==0


        waypoints(1)=true;
    else

        spacing=getWaypointSpacing(diag,cumLength(end));


        waypoints=findLineSegmentWaypoints(waypoints,n,posLength,cumLength(end));


        waypoints(1)=true;


        if~closed
            waypoints(end)=true;
        end


        waypoints=findSpacedWaypoints(waypoints,n,cumLength,spacing);
    end

end

function spacing=getWaypointSpacing(diag,cumLength)








    n=20;
    m=8;
    b=0.05;

    if diag==0||cumLength==0
        spacing=b;
        return;
    end

    spacing=(diag/n)+(cumLength/m)+b;

end

function waypoints=findLineSegmentWaypoints(waypoints,n,posLength,cumLength)



    m=0.05;

    diffThresh=m*cumLength;

    idx=(1:n)';
    idx(posLength<diffThresh)=[];

    if~isempty(idx)
        waypoints(idx)=true;
        idx=idx+1;
        idx(idx>n)=[];
        waypoints(idx)=true;
    end

end

function waypoints=findSpacedWaypoints(waypoints,numPoints,cumLength,spacing)

    idx=(1:numPoints)';




    lineSegIdx=idx(waypoints);


    for idx=1:numel(lineSegIdx)

        waypointIdx=lineSegIdx(idx);

        if idx==numel(lineSegIdx)


            dataSeg=cumLength(waypointIdx:end);
        else


            dataSeg=cumLength(waypointIdx:lineSegIdx(idx+1)-1);
        end


        dataSeg=dataSeg-dataSeg(1);
        totalSpacing=max(dataSeg);



        if totalSpacing>2*spacing


            buffer=rem(totalSpacing,spacing);
            numPoints=round(((totalSpacing-buffer)/spacing)-1);



            for ii=1:numPoints
                [~,index]=min(abs(dataSeg-(ii*spacing)-(0.5*buffer)));
                waypoints(waypointIdx+index-1)=true;
            end

        end

    end

end