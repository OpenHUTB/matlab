function setPrefix(this,prefix)



    if~isempty(regexp(prefix,'\W','once'))
        error('Only word charaters (A-Z, a-z, 0-9, and _) are allowed in the prefix of transformed model name');
    elseif~isempty(regexp(prefix(1),'[\d_]','once'))
        error('The first character of the prefix of transformed model name must be an alphabet(a-z or A-Z)');
    else
        this.fPrefix=prefix;
    end
end
