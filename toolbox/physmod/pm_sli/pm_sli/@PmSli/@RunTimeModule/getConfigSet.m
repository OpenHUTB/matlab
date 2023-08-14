function[cc,ccList]=getConfigSet(this,hh)





    persistent getConfigSetFcn;
    if isempty(getConfigSetFcn)
        getConfigSetFcn=ssc_private('ssc_get_configset');
    end
    [cc,ccList]=getConfigSetFcn(hh);


