function option_line=findoptline(h,a_section,lcounter,blocktype)




    option_lnum=strmatch('#',a_section);
    if isempty(option_lnum)
        error(message('rf:rfdata:data:findoptline:missoptionline',blocktype,lcounter));
    end

    if numel(option_lnum)>1
        error(message('rf:rfdata:data:findoptline:multipleoptionlines',blocktype,lcounter));
    end
    option_line=strtok(a_section{option_lnum},'!');