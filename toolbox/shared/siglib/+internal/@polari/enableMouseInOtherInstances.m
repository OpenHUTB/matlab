function[pList,prevEna]=enableMouseInOtherInstances(p,ena,pList,prevEna)






    if ena





        if~isempty(pList)
            enableMouseHandlers(pList,true,prevEna);
        end
    else


        pList=identifyOtherInstancesInFig(p);
        if isempty(pList)
            prevEna=[];
        else
            prevEna=enableMouseHandlers(pList,false);
        end
    end
