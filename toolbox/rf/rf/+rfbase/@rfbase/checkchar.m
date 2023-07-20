function checkchar(h,prop_name,val)




    if~isa(val,'char')
        if isempty(h.Block)
            rferrhole1=h.Name;
        else
            rferrhole1=upper(class(h));
        end
        rferrhole2=prop_name;
        error(message('rf:rfbase:rfbase:checkchar:NotAChar',...
        rferrhole1,rferrhole2));
    end