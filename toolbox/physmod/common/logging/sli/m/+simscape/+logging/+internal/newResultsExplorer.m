function res=newResultsExplorer(choice)
mlock

    persistent STATE
    if isempty(STATE)
        STATE=true;
    end


    res=STATE;


    if nargin>0
        STATE=choice;
    end
end