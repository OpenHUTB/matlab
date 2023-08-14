function dLabel=getDisplayLabel(dao)




    if isempty(dao.PropertyName)
        dLabel=getString(message('rptgen:RptgenML_ComponentMakerData:unnamedPropLabel'));
    else
        dLabel=dao.PropertyName;
    end
