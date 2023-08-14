function names=specifierhelp(spcfrs)











    if ischar(spcfrs)
        names=cellstr(spcfrs);
    elseif iscellstr(spcfrs)

        names=spcfrs;
    else

        error(message('SimBiology:specifierhelper:InvalidArg'));
    end



