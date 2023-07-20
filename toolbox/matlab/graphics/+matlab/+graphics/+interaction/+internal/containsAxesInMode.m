function ret=containsAxesInMode(hObj)



    ret=false;
    hAxes=findobjinternal(hObj,'Type','Axes');
    if(numel(hAxes)==0)
        return;
    end
    interactionsContainers={hAxes.InteractionContainer};
    for n=1:numel(interactionsContainers)
        if(~strcmp(interactionsContainers{n}.CurrentMode,'none'))
            ret=true;
            return;
        end
    end