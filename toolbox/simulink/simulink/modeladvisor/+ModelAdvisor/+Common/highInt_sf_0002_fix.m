function[results]=highInt_sf_0002_fix(taskobj,prefix)




    mdladvObj=taskobj.MAObj;

    system=getfullname(mdladvObj.System);
    [info,~]=ModelAdvisor.Common.highInt_sf_0002_info(mdladvObj,system,prefix,1);
    for inx=1:length(info.Obj)
        info.Obj{inx}.UserSpecifiedStateTransitionExecutionOrder=1;
    end
    ft=ModelAdvisor.FormatTemplate('ListTemplate');
    ft.setCheckText({DAStudio.message([prefix,'FixInfo_Results'])});
    ft.setListObj(info.Obj(:)')
    results=ft;
    mdladvObj.setActionEnable(false);
end
