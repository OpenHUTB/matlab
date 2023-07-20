function s=to_string(s)





    if ischar(s)
        return
    end

    if isstruct(s)
        return
    end

    if isnumeric(s)||islogical(s)
        s=num2str(s);
        return
    end
end
