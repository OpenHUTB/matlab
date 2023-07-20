









function rstatus=privhdllibstate(option)


    persistent nonce;
    persistent status;

    if(strcmpi(option,'nonce'))
        rstatus=~isempty(nonce);
        return
    end
    if(isempty(nonce))
        nonce='used alteast once';
    end
    if isempty(status)
        status=false;
    end
    rstatus=status;

    switch(option)
    case 'status'
        return;
    case 'set'
        status=true;
    case 'reset'
        status=false;
    otherwise
        error('privhdllibstate : unknown option used');
    end
    rstatus=status;
end
