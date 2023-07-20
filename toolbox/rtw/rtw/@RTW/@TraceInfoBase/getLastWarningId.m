function out=getLastWarningId(h)




    if isempty(h.LastWarning)
        out='';
    else
        out=h.LastWarning{1};
    end
