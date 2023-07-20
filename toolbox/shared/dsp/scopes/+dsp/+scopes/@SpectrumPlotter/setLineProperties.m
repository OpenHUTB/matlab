function setLineProperties(this,lineNum,props)






    if isempty(this.Lines)

        cacheLineProperties(this,lineNum,props);
    else

        if isfield(props,'DisplayName')
            set(this.Lines(lineNum),rmfield(props,'DisplayName'));
        else
            set(this.Lines(lineNum),props);
        end
        cacheLineProperties(this,lineNum,props);
    end
end
