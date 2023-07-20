function dataobjs=getDataObj(apiobjs)
    if isempty(apiobjs)
        dataobjs=[];
        return;
    end

    if isa(apiobjs(1),'slreq.data.DataModelObj')
        dataobjs=apiobjs;
        return;
    end

    cname=class(apiobjs(1).getDataObj());
    dataobjs=eval([cname,'.empty(0, length(apiobjs))']);
    for i=1:length(apiobjs)
        dataobjs(i)=apiobjs(i).getDataObj();
    end
end
