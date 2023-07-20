function out=runningSLDVResultsValidator(in)





    persistent State;

    if isempty(State)
        State=false;
    end

    if nargin>0
        State=in;
    end

    out=State;
end