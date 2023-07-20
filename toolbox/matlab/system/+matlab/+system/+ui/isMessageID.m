function b=isMessageID(text)




    b=~any(isspace(text))&&length(find(text==':',2))>1;

    if b
        try
            getString(message(text));
        catch E %#ok<NASGU>
            b=false;
        end
    end

end