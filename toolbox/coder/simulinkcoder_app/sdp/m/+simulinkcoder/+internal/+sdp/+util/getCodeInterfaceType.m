function out=getCodeInterfaceType(dict)




    out=1;

    if exist(dict,'file')
        try
            dd=coder.dictionary.open(dict);
            type=dd.getConfigurationType();
            if strcmp(type,'DataInterface')
                out=1;
            else
                out=2;
            end
        catch
        end
    end
