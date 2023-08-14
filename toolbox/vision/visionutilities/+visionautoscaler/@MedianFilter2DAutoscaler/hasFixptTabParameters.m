function hasFixptTabParams=hasFixptTabParameters(h,blkObj)%#ok
    try
        val=evalin('base',blkObj.nghbood);
        val=prod(val(:));
        isNHoodOdd=(rem(val,2)~=0);
    catch %#ok

        isNHoodOdd=false;
    end
    hasFixptTabParams=~isNHoodOdd;