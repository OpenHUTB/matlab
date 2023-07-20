function htmlStr=getSourcelocationFromSID(obj,sid)
    htmlStr=sid;
    try
        htmlStr=obj.getHyperlink(sid);
    catch me %#ok<NASGU>
    end
end
