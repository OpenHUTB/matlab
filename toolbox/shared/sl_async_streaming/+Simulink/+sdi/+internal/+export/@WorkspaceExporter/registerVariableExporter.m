function registerVariableExporter(this,className)

    validateattributes(className,{'char'},{'nonempty'});
    this.PendingExporters{end+1}=className;
end
