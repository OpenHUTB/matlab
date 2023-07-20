function[out,desc]=idelink_buildActionEnum_entries(cs,~)

    desc='';

    if~exist('registertic2000.m','file')&&...
        ~exist('registerxilinxise.m','file')&&...
        ~exist('registerWRWorkbench.m','file')
        registered=false;
    else
        registered=true;
    end


    if isa(cs,'Simulink.ConfigSet')
        target=cs.getComponent('Code Generation').getComponent('Target');
    elseif isa(cs,'Simulink.RTWCC')
        target=cs.getComponent('Target');
    else
        target=cs;
    end



    if~registered||strcmp(target.AdaptorName,'None')
        val=cs.getProp('buildAction');
        out.str=val;
        out.disp=val;
        return;
    end
    display=target.ProjectMgr.getBuildActions(target.AdaptorName,target.buildFormat);
    values=target.getPropAllowedValues('buildAction');
    isERT=strcmp(cs.getProp('IsERTTarget'),'on');
    if~isERT

        display=display(~strcmpi(display,'Create_Processor_In_the_Loop_project'));
    end
    values=values(1:length(display));
    out=struct('str',values','disp',display);
