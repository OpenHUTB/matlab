function out=setnoisefigure(h,in,prop_name,isavector)




    if nargin==3
        isavector=false;
    end

    if isavector
        out=setpositivevector(h,in,prop_name,true,false,false);
    else
        out=setpositive(h,in,prop_name,true,false,false);
    end
    NF=10.^(out/10);
    if any(isinf(NF))
        if isempty(h.Block)
            rferrhole1=h.Name;
            rferrhole2=prop_name;
        else
            rferrhole1=upper(class(h));
            rferrhole2=prop_name;
        end
        error(message('rf:rfbase:rfbase:FminTooBigToProcess',...
        rferrhole1,rferrhole2,round(max(out))));
    end