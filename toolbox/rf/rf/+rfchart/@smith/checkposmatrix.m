function checkposmatrix(h,prop_name,val)





    if~isnumeric(val)||~ismatrix(val)||~isreal(val)||...
        any(isinf(val(:)))||anynan(val)||size(val,1)~=2||...
        any(val(:)<0)
        if isempty(h.Block)
            rferrhole1=h.Name;
        else
            rferrhole1=upper(class(h));
        end
        rferrhole2=prop_name;
        error(message('rf:rfchart:smith:checkposmatrix:NotValidMatrix',...
        rferrhole1,rferrhole2));
    end
