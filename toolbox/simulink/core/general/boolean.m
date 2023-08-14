function y=boolean(x)







    if nargin>0
        x=convertStringsToChars(x);
    end

    y=logical(x);
