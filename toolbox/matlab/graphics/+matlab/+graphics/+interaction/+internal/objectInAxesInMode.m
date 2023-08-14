function ret=objectInAxesInMode(hObj)



    hAxes=ancestor(hObj,'axes');
    ret=~isempty(hAxes)&&~strcmp(hAxes.InteractionContainer.CurrentMode,'none');