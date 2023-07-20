function checkempty(h,a_param,lcounter,blocktype,description)




    if isempty(a_param)
        error(message('rf:rfdata:data:checkempty:emptynotallowed',description,blocktype,lcounter));
    end