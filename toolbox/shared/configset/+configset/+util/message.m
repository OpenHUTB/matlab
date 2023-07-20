function msg=message(err)

    if isempty(err.cause)
        msg=err.message;
    else
        msg=err.message;
        for i=1:length(err.cause)
            msg=sprintf('%s\n  %d. %s',msg,i,err.cause{i}.message);
        end
    end
