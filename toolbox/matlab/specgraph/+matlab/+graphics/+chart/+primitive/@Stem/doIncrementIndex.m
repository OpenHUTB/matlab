function[index,interp]=doIncrementIndex(hObj,index,direction,interpolationStep)




    retInd=index;
    try
        if strcmpi(direction,'up')||strcmpi(direction,'right')
            retInd=hObj.doGetNearestIndex(retInd+1);
        else
            retInd=hObj.doGetNearestIndex(retInd-1);
        end
    catch E

    end
    index=retInd;
    interp=0;
