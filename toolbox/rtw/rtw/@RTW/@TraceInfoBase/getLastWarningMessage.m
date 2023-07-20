function out=getLastWarningMessage(h)




    if isempty(h.LastWarning)
        out='';
    else
        out=DAStudio.message(h.LastWarning{:});
    end
