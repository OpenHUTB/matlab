function value=slcomparison4(newValue)




    mlock;
    persistent slcomparison4On;
    if isempty(slcomparison4On)
        slcomparison4On=false;
    end

    if slcomparison4On
        value='on';
    else
        value='off';
    end
    if strcmp(newValue,'on')
        slcomparison4On=true;
    elseif strcmp(newValue,'off')
        slcomparison4On=false;
    end
end
