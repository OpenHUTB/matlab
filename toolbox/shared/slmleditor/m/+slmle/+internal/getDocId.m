function cid=getDocId(cbinfo,varargin)




    if isempty(cbinfo)
        return;
    end

    cid=cbinfo.getSelection.getFullName;
    if isempty(cid)||~ischar(cid)
        cid=gcb;
    end
    if ischar(cid)
        cid=sfprivate('block2chart',cid);
    end
end



