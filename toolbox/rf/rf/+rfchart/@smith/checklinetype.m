function checklinetype(h,prop_name,val)





    if~any(strcmp(val,{'-','--',':','-.',''}))
        if isempty(h.Block)
            rferrhole1=h.Name;
        else
            rferrhole1=upper(class(h));
        end
        rferrhole2=prop_name;
        error(message('rf:rfchart:smith:checklinetype:NotValidLineType',...
        rferrhole1,rferrhole2));
    end