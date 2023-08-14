function configureAccessorBlock(accessorBlk,ownerBlk,blocksize)




    persistent lastOwner;
    persistent extraOffsetCount;
    if strcmp(lastOwner,ownerBlk)
        extraOffsetCount=extraOffsetCount+1;
    else
        lastOwner=ownerBlk;
        extraOffsetCount=0;
    end


    refsize=double(blocksize);
    scaleFac=2.5;
    accessorW=refsize*scaleFac;
    accessorH=refsize*scaleFac;
    ownerPos=get_param(ownerBlk,'Position');
    extraOffsetUnit=ceil(refsize/2);

    extraOffset=extraOffsetCount*extraOffsetUnit;
    offsetX=refsize+extraOffset;
    offsetY=refsize+extraOffset;
    set_param(accessorBlk,'Position',[ownerPos(3)+offsetX,ownerPos(4)+offsetY,...
    ownerPos(3)+offsetX+accessorW,ownerPos(4)+offsetY+accessorH]);


    set_param(ownerBlk,'selected','off');
    set_param(accessorBlk,'selected','on');
end