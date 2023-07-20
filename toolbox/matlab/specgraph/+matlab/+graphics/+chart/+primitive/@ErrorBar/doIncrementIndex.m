function[index,interp]=doIncrementIndex(hObj,index,direction,~)




    retInd=index;

    if strcmpi(direction,'up')||strcmpi(direction,'right')
        retInd=hObj.doGetNearestIndex(retInd+1);
    else
        retInd=hObj.doGetNearestIndex(retInd-1);
    end

    index=retInd;
    interp=0;
