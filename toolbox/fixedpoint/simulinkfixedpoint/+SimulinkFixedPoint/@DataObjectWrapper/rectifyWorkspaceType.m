function rectifyWorkspaceType(this)

























    dataSource=getDataSource(this);
    if isa(dataSource,'Simulink.data.DataDictionary')



        dictionaryName=get_param(this.ContextName,'DataDictionary');
        dictionaryObject=Simulink.data.dictionary.open(dictionaryName);
        sectionObject=dictionaryObject.getSection('Design Data');



        if sectionObject.exist(this.Name,'DataSource',dictionaryName,'BaseWorkspaceAccess',false)
            setWorkspaceType(this,SimulinkFixedPoint.AutoscalerVarSourceTypes.DataDictionary);
        end
    end
end