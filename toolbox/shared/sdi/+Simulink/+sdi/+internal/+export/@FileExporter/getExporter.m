function exporter=getExporter(this,extension)
    extension=lower(extension);
    if this.CreatedExporters.getCount()==0
        this.createPendingExporters();
    end
    if~this.CreatedExporters.isKey(extension)
        error(message('SDI:sdi:InvalidExportExtension'));
    end
    exporter=this.CreatedExporters.getDataByKey(extension);
end