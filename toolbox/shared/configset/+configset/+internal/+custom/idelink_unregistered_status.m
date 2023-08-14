function[status,desc]=idelink_unregistered_status(~,~)






    if~exist('registertic2000.m','file')&&...
        ~exist('registerxilinxise.m','file')&&...
        ~exist('registerWRWorkbench.m','file')
        status=configset.internal.data.ParamStatus.Normal;
    else
        status=configset.internal.data.ParamStatus.UnAvailable;
    end

    desc='';
