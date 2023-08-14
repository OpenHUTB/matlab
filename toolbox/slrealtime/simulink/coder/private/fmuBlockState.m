function re=fmuBlockState(action)




    persistent FMUBlockState

    if isempty(FMUBlockState)
        FMUBlockState=0;
    end

    switch lower(action)
    case 'set'
        re=FMUBlockState;
        FMUBlockState=1;
    case 'get'
        re=FMUBlockState;
    case 'clear'
        re=FMUBlockState;
        FMUBlockState=0;
    otherwise
        assert(false,['Invalid input: ',action]);
    end

end
