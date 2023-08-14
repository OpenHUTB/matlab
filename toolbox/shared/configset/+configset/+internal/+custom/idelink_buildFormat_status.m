function[status,desc]=idelink_buildFormat_status(cs,~)



    desc='';

    if~exist('registertic2000.m','file')&&...
        ~exist('registerxilinxise.m','file')&&...
        ~exist('registerWRWorkbench.m','file')
        status=configset.internal.data.ParamStatus.InAccessible;
    else
        target=cs.getComponent('Code Generation').getComponent('Target');



        if~strcmp(target.AdaptorName,'None')&&...
            target.ProjectMgr.getAdaptorSpecificInfo(target.AdaptorName,'getBuildFormatEnable')
            status=configset.internal.data.ParamStatus.Normal;
        else
            status=configset.internal.data.ParamStatus.ReadOnly;
        end
    end
