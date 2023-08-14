function setContextName(this,contextName)






    this.ContextName=contextName;
    if~isempty(contextName)
        this.Context=get_param(contextName,'Object');
    end
end