function checkbool(h,prop_name,val)




    if~(islogical(val)||(isnumeric(val)&&isscalar(val)&&isreal(val)...
        &&~isinf(val)&&~isnan(val)))
        if isempty(h.Block)
            rferrhole1=h.Name;
        else
            rferrhole1=upper(class(h));
        end
        rferrhole2=prop_name;
        error(message('rf:rfbase:rfbase:checkbool:NotABool',...
        rferrhole1,rferrhole2));
    end