function out=EmbeddedCoderDictionary(cs,name,direction,widgetValues)




    if direction==0
        out=cell(1,3);
        [out{:}]=deal(get_param(cs,name));
    else
        out=widgetValues{1};
    end
