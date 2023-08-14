function out=setpositive(h,out,prop_name,...
    zero_included,inf_included,empty_allowed,updateflag)




    if(empty_allowed&&isempty(out))
        return
    end

    if isempty(out)
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setpositive:EmptyNotAllowed',...
        rferrhole1,rferrhole2));
    end

    if~isscalar(out)||~isnumeric(out)||isnan(out)||...
        ~isreal(out)||out<0||(~zero_included&&(out==0))||...
        (~inf_included&&isinf(out))
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:setpositive:NotAPositive',...
        rferrhole1,rferrhole2));
    end
    if(nargin==6)||(nargin==7&&updateflag)
        h.PropertyChanged=true;
    end