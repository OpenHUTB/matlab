
function[set2Better]=utilCompareSets(set1,set2,currentset)












    currentsetWeight=0.05;





    t1=set1.offset+set1.slope;
    t2=set2.offset+set2.slope;

    slope1=set1.slope;
    slope2=set2.slope;


    if(abs((t1-t2)/min([t1,t2]))<currentsetWeight&&...
        abs((slope1-slope2)/min([slope1,slope2]))<currentsetWeight)
        set_tie=true;
    else
        set_tie=false;
    end

    if t1>t2
        set2Better=true;
    else
        set2Better=false;
    end




    if(set_tie&&strcmp(currentset,set1.simulationmode))
        set2Better=false;
    elseif(set_tie&&strcmp(currentset,set2.simulationmode))
        set2Better=true;
    end

end

