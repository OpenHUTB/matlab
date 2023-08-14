function[blkPos,canLoc]=computeBlockPosition(hBlock)






    blkPos=get_param(hBlock,'Position');
    hParent=get_param(hBlock,'Parent');
    canLoc=get_param(hParent,'Location');
    scrlOff=get_param(hParent,'ScrollbarOffset');

    zoomFactor=str2double(get_param(hParent,'ZoomFactor'))/100.0;



    blkPos=blkPos*zoomFactor-horzcat(scrlOff,scrlOff);
    outDist=[0,0];



    cWth=canLoc(3)-canLoc(1);
    if blkPos(3)>cWth
        outDist(1)=blkPos(3)-cWth;
    end

    cHt=canLoc(4)-canLoc(2);
    if blkPos(4)>cHt
        outDist(2)=blkPos(4)-cHt;
    end
    blkPos=blkPos-horzcat(outDist,outDist);

end

