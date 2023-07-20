function schema=slvnvmenus(fncname,cbinfo)



    fnc=str2func(fncname);
    schema=fnc(cbinfo);
end

function schema=ModelRequirements(~)%#ok<DEFNU>
    schema=sl_action_schema;
    schema.tag='Simulink:ReqTraceReport';
    schema.label=DAStudio.message('Simulink:studio:ReqTraceReport');
    schema.callback=@ModelRequirementsCB;
    schema.autoDisableWhen='Busy';
end

function ModelRequirementsCB(~)
    rmi.reqReport(bdroot);
end

