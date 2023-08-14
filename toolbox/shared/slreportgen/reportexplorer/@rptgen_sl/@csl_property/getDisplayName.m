function dName=getDisplayName(c)




    dName=rptgen.parseExpressionText(get(c,[c.ObjectType,'Property']));

    if isempty(dName)
        error(message('RptgenSL:rsl_csl_property:propertyNameEmptyLabel'));
    end