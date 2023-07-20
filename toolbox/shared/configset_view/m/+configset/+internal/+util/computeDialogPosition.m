function pos=computeDialogPosition(pos)






    screensize=get(0,'screensize');







    delta=70;
    maxWidth=screensize(3)-2*delta;
    maxHeight=screensize(4)-2*delta;

    minWidth=min(maxWidth,900);
    minHeight=min(maxHeight,710);

    pos(3)=max(pos(3),minWidth);
    pos(4)=max(pos(4),minHeight);


    if pos(3)<=maxWidth&&pos(4)<=maxHeight

        pos(1:2)=max(pos(1:2),screensize(1:2)+delta);
        pos(1:2)=min(pos(1:2),screensize(3:4)-delta-pos(3:4));
    else


        pos=[screensize(1:2)+delta,min(pos(3:4),[maxWidth,maxHeight])];
    end
