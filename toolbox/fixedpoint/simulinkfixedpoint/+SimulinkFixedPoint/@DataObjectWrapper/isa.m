function isaClass=isa(this,className)





    if nargin>1
        className=convertStringsToChars(className);
    end

    isaClass=strcmp(className,'SimulinkFixedPoint.DataObjectWrapper')...
    ||isa(this.Object,className);
end