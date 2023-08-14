function htmlStr=getSourcelocationFromSID(obj,sid)
    htmlStr=sid;
    try
        [~,blockSID,~,~,~,~]=obj.util_sid(sid);
        htmlStr=obj.getHyperlink(blockSID);
    catch me %#ok<NASGU>
    end
end
