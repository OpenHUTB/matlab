function[cto,ctxt]=getContextObject(ad,ctxt)




    if nargin<2|strncmpi(ctxt,'auto',4)
        ctxt=ad.Context;
    end

    if strcmp(ctxt,'None')|isempty(ctxt)
        cto=[];
        ctxt='';
    else
        cto=get(ad,['Current',ctxt]);
    end