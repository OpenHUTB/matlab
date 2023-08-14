function y=quoteIfNeeded(x,q)






    if isempty(strfind(x,q))&&~isempty(strfind(x,' '))

        y=[q,x,q];

    else

        y=x;

    end


