function registerVariableParser(this,className)



    validateattributes(className,{'char'},{'nonempty'});
    this.PendingParsers{end+1}=className;
end
