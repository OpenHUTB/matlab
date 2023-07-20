function out=setnetworkparametertype(h,out,prop_name,...
    empty_allowed,updateflag)




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
        error(message(['rf:rfbase:rfbase:setnetworkparametertype:'...
        ,'EmptyNotAllowed'],rferrhole1,rferrhole2));
    end

    if~isa(out,'char')
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message(['rf:rfbase:rfbase:setnetworkparametertype:'...
        ,'NotAString'],rferrhole1,rferrhole2));
    end
    switch upper(out)
    case{'ABCD PARAMETERS','ABCD_PARAMETERS','ABCD-PARAMETERS','ABCD_PARAMS','ABCD-PARAMS','ABCD'...
        ,'S PARAMETERS','S_PARAMETERS','S-PARAMETERS','S_PARAMS','S-PARAMS','S'...
        ,'Y PARAMETERS','Y_PARAMETERS','Y-PARAMETERS','Y_PARAMS','Y-PARAMS','Y'...
        ,'Z PARAMETERS','Z_PARAMETERS','Z-PARAMETERS','Z_PARAMS','Z-PARAMS','Z'...
        ,'H PARAMETERS','H_PARAMETERS','H-PARAMETERS','H_PARAMS','H-PARAMS','H'...
        ,'G PARAMETERS','G_PARAMETERS','G-PARAMETERS','G_PARAMS','G-PARAMS','G'...
        ,'T PARAMETERS','T_PARAMETERS','T-PARAMETERS','T_PARAMS','T-PARAMS','T'}
        if(nargin==4)||(nargin==5&&updateflag)
            oldvalue=get(h,prop_name);
            if~strncmpi(oldvalue,out,1)
                h.PropertyChanged=true;
            end
        end
    otherwise
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message(['rf:rfbase:rfbase:setnetworkparametertype:'...
        ,'WrongType'],rferrhole1,rferrhole2));
    end
