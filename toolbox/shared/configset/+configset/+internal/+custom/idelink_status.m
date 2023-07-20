function[status,desc]=idelink_status(cs,name)



    target=cs.getComponent('Code Generation').getComponent('Target');


    if~exist('registertic2000.m','file')&&...
        ~exist('registerxilinxise.m','file')&&...
        ~exist('registerWRWorkbench.m','file')
        enabled=false;
        visible=false;


    elseif strcmp(target.AdaptorName,'None')
        enabled=false;
        visible=false;
    else
        enabled=target.getEnabledFlag(name);
        visible=target.getVisibleFlag(name);
    end

    if~visible
        status=configset.internal.data.ParamStatus.InAccessible;
    elseif~enabled
        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end
    desc='';
