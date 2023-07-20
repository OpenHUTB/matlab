function retVal=sanitizePosition(inPos)










    retVal=inPos;
    for i=1:length(inPos)
        if(inPos(i)<32000)
            retVal(i)=inPos(i);
        else
            retVal(i)=32000;
        end
    end



