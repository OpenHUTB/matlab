function s=getOutlineString(c)






    if~builtin('license','checkout','SIMULINK_Report_Gen')
        s=getString(message('RptgenSL:rsl_csl_property:unlicensedComponentLabel'));
        return;

    end


    s=getString(message('RptgenSL:rsl_csl_property:propertyLabel',...
    c.findDisplayName('ObjectType'),...
    get(c,[c.ObjectType,'Property'])));
