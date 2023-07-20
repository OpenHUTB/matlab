function out=setnoiseflag(h,out,prop_name)




    if isempty(out)||~isa(out,'char')||...
        (~strcmpi(out,'on')&&~strcmpi(out,'off'))
        error(message(['rfblks:rfbbequiv:rfbbequiv:setnoiseflag:'...
        ,'WrongNoiseFlag'],h.Name,prop_name));
    end