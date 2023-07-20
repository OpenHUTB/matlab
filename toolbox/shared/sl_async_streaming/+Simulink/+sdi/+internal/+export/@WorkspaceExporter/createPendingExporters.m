function createPendingExporters(this)







    if isempty(this.PendingExporters)&&~getCount(this.CreatedExporters)
        interface=Simulink.sdi.internal.Framework.getFramework();
        interface.registerEnginePlugins([],false);
    end


    numExporters=length(this.PendingExporters);
    for idx=1:numExporters
        exporter=eval(this.PendingExporters{idx});
        domainTypes=getDomainType(exporter);
        if~iscell(domainTypes)
            domainTypes={domainTypes};
        end
        for idx2=1:length(domainTypes)
            if~isKey(this.CreatedExporters,domainTypes{idx2})
                insert(this.CreatedExporters,domainTypes{idx2},exporter);
            end
        end
    end
    this.PendingExporters={};
end
