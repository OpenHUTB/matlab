function out=isValidIdentifier(str)




    out=false;
    if isempty(str)
        return;
    end
    tmp=regexprep(str,'[^a-zA-Z_0-9]','_');
    if strcmp(tmp,str)

        firstChar=str(1);
        if(firstChar<'0'||firstChar>'9')

            out=true;
        end
    end
end
