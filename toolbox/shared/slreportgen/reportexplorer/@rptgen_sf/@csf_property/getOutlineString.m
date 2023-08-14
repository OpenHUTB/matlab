function s=getOutlineString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsf_csf_property:unlicensedComponentLabel'));
        return;

    end



    objType='Stateflow';

    s=sprintf(getString(message('RptgenSL:rsf_csf_property:propertyMsg')),...
    objType,...
    c.StateflowProperty);
