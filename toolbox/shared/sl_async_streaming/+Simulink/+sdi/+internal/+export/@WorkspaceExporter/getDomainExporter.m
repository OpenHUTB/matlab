function ret=getDomainExporter(this,domainType)
    if~isempty(domainType)&&isKey(this.CreatedExporters,domainType)
        ret=getDataByKey(this.CreatedExporters,domainType);
    else
        ret=this.DefaultElementExporter;
    end
end
