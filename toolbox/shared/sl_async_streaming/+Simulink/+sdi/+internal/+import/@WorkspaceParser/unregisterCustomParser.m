function unregisterCustomParser(this,obj)

    validateattributes(obj,{'io.reader'},{'scalar'});
    cname=class(obj);
    if isKey(this.CustomParsers,cname)
        deleteDataByKey(this.CustomParsers,cname);
    end
end
