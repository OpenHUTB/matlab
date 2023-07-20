function ev=getIdxValue(h,ev,ci)





    if isempty(ev)
        return;
    end
    if~isempty(ci)
        for i=1:length(ci)
            cidx=ci(i);
            if ischar(cidx)
                ev=getfield(ev,cidx);
            elseif iscell(ev)
                ev=ev{cidx};
            else
                ev=ev(cidx);
            end
        end
    end

