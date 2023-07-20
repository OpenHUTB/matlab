function ctxt=getLoopContext(c)





    classList={
'rptgen_sf.csf_obj_loop'
'rptgen_sf.csf_state_loop'
'rptgen_sf.csf_chart_loop'
'rptgen_sf.csf_machine_loop'
    };
    contextList={
'Object'
'State'
'Chart'
'Machine'
    };

    ctxt=rptgen.loopContext(classList,contextList,c);