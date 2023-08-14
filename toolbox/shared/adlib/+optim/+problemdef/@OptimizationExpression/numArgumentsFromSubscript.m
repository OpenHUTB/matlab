function n=numArgumentsFromSubscript(obj,sub,indexingContext)









    switch sub(1).type
    case '()'
        if isscalar(sub)

            n=1;
        else

            n=numArgumentsFromSubscript(obj,sub(2:end),indexingContext);
        end
    case '.'
        if isscalar(sub)
            if strncmp(sub(end).subs,'show',4)||strncmp(sub(end).subs,'write',5)


                n=0;
            else
                n=1;
            end
        else
            n=builtin('numArgumentsFromSubscript',obj,sub,indexingContext);
        end
    otherwise
        n=builtin('numArgumentsFromSubscript',obj,sub,indexingContext);
    end
