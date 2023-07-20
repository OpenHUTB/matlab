function out=cleanAttributeName(in)







    out=in;
    [~,invalidChars]=slreq.internal.isValidCustomAttributeName(in);

    for n=1:length(invalidChars)
        out=strrep(out,invalidChars{n},'');
    end

    if isempty(out)


        out=mapToGoodChars(in);

    elseif length(out)>60

        out=out(1:60);
    end

end

function good=mapToGoodChars(bad)
    firstChar=65;
    totalChars=26;

    good=bad;
    for i=1:length(bad)
        code=mod(double(bad(i))-firstChar,totalChars);
        good(i)=firstChar+code;
    end
end

