function childBlks=getChildOfAnnotation(objHandle,opt)
    obj=get_param(objHandle,'Object');
    Object=obj.getFullName();

    annotParent=get_param(objHandle,'Parent');


    areaPosition=get_param(objHandle,'Position');



    blks=find_system(annotParent,'LookUnderMasks',opt.lookUnderMask,'FollowLinks',opt.followLinks,'SearchDepth',1,'type','block');

    blks=setdiff(blks,Object);
    blks=setdiff(blks,annotParent);


    idx=[];
    for k=1:length(blks)
        blockPosition=get_param(blks{k},'Position');
        if isInsideArea(blockPosition,areaPosition)
            idx=[idx,k];
        end
    end
    childBlks=blks(idx);
end

function retval=isInsideArea(blockPosition,areaPosition)
    retval=false;
    if(blockPosition(1)>=areaPosition(1)&&blockPosition(3)<=areaPosition(3)&&blockPosition(2)>=areaPosition(2)&&blockPosition(4)<=areaPosition(4))
        retval=true;
    end
end
