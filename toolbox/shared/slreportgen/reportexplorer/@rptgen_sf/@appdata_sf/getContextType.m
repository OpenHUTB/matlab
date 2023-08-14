function ct=getContextType(adSF,c,excludeEmpty)









    if nargin<3
        excludeEmpty=logical(0);
    end

    ct=adSF.Context;
    if isempty(ct)
        classList={
'rptgen_sf.csf_obj_loop'
'rptgen_sf.csf_state_loop'
'rptgen_sf.csf_chart_loop'
'rptgen_sf.csf_machine_loop'
'rptgen_sf.csf_slfun_sys_loop'
        };
        contextList={
'Object'
'State'
'Chart'
'Machine'
        };
        ct=rptgen.loopContext(classList,contextList,c,excludeEmpty);
    elseif excludeEmpty&strcmp(ct,'None')
        ct='Machine';
    end