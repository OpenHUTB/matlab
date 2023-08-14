function out=setpositivevector(h,out,prop_name,...
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
        error(message('rf:rfbase:rfbase:setpositivevector:EmptyNotAllowed',...
        rferrhole1,rferrhole2));
    end

    out=squeeze(out);
    if~isnumeric(out)||~isvector(out)||any(isnan(out))||...
        any(~isreal(out))||any(out<0)||...
        (~zero_included&&any(out==0))||...
        (~inf_included&&any(isinf(out)))
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message(['rf:rfbase:rfbase:setpositivevector:'...
        ,'NotAPositiveVector'],rferrhole1,rferrhole2));
    end
    out=out(:);
    if(nargin==6)||(nargin==7&&updateflag)
        oldvalue=get(h,prop_name);
        if numel(oldvalue)~=numel(out)||any(oldvalue-out)
            h.PropertyChanged=true;
        end
    end