function check3entryvec(h,prop_name,val)





    if~isnumeric(val)||~isvector(val)||~isreal(val)||...
        anynan(val)||size(val,2)~=3||any(val(:)<0)||...
        any(val(:)>1)
        if isempty(h.Block)
            rferrhole1=h.Name;
        else
            rferrhole1=upper(class(h));
        end
        rferrhole2=prop_name;
        error(message('rf:rfchart:smith:check3entryvec:NotValidVector',...
        rferrhole1,rferrhole2));
    end
