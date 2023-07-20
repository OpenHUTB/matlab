function registerCustomParser(this,obj)

    validateattributes(obj,{'io.reader'},{'scalar'});
    cname=class(obj);
    if~isKey(this.CustomParsers,cname)
        insert(this.CustomParsers,cname,obj);
    end
end
