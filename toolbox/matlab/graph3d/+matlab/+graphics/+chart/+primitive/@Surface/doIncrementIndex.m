function[index,interp]=doIncrementIndex(hObj,index,direction,interpolationStep)

    dataSize=size(hObj.ZData);
    [currRow,currCol]=ind2sub(dataSize,index);
    retInd=index;
    try
        switch(direction)
        case 'up'

            newRow=currRow+1;
            modVal=mod(newRow-1,dataSize(1))+1;
            addVal=~(modVal==newRow);
            newRow=modVal;

            newCol=currCol+addVal;
        case 'down'

            newRow=currRow-1;

            addVal=~(newRow>0);
            newRow=newRow+dataSize(1)*addVal;
            newCol=currCol-addVal;
        case 'left'

            newCol=currCol-1;

            addVal=~(newCol>0);
            newCol=newCol+dataSize(2)*addVal;
            newRow=currRow-addVal;
        case 'right'

            newCol=currCol+1;
            modVal=mod(newCol-1,dataSize(2))+1;
            addVal=~(modVal==newCol);
            newCol=modVal;

            newRow=currRow+addVal;
        end
        retInd=sub2ind(dataSize,newRow,newCol);
    catch E

    end
    index=retInd;
    interp=0;
