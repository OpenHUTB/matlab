function dLabel=getDisplayLabel(dao)




    if isempty(dao.ClassName)
        dLabel=getString(message('rptgen:RptgenML_ComponentMaker:unnamedComponentLabel'));
    else
        dLabel=dao.ClassName;
    end

    if dao.getDirty
        dirtyFlag='*';
    else
        dirtyFlag='';
    end

    dLabel=[getString(message('rptgen:RptgenML_ComponentMaker:componentLabel')),' - ',dLabel,dirtyFlag];