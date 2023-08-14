function[labels,depths,locStr]=getDocIndex(sys,doc)




    labels=[];
    depths=[];
    locStr=[];

    if ischar(sys)

        if~isempty(doc)
            perIdx=find(doc=='.');
            ext=doc((perIdx(end)):end);
        else
            ext='';
        end
        linkType=rmi.linktype_mgr('resolve',sys,ext);
    else

        linkType=sys;
    end


    if~isa(linkType,'ReqMgr.LinkType')
        return;
    end


    if~isempty(linkType.ContentsFcn)
        [labels,depths,locStr]=feval(linkType.ContentsFcn,doc);
    end
end
