function pathItems=getPathItems(h,blkObj)%#ok





    if(islevelZero(blkObj))
        pathItems={'Output'};
    else
        pathItems={'Coefficients',...
        'Product output',...
        'Accumulator',...
        'Output'};
    end

    function isZeroLevel=islevelZero(blkObj)

        isZeroLevel=false;
        try
            levelval=evalin('base',blkObj.level);
            if(levelval==0)
                isZeroLevel=true;
            end
        catch %#ok
            isZeroLevel=false;
        end


