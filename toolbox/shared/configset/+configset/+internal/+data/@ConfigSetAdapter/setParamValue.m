function setParamValue(obj,name,val)


    shortName=configset.internal.util.toShortName(name);
    cs=obj.Source;
    if~isempty(cs.getConfigSet)
        cs=cs.getConfigSet;
    end
    pdata=obj.getParamData(shortName);

    if~isempty(pdata)&&strcmp(pdata.Component,'HDL Coder')
        hdlcc=cs.getComponent('HDL Coder');
        if~isempty(hdlcc)
            hdlcc.set_param(shortName,val);
        end
    else


        oldVal=warning('query','backtrace');
        tmp=onCleanup(@()warning(oldVal.state,oldVal.identifier));
        warning('off',oldVal.identifier);

        cs.set_param(shortName,val);
    end

