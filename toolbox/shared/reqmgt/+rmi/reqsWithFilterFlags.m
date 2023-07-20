function[reqs,flags,destIdInReqSet]=reqsWithFilterFlags(obj,filters,markProxyLinks)









    if nargin<3
        markProxyLinks=false;
    end

    if markProxyLinks





        [reqs,destIdInReqSet]=getReqsFromReqData(obj);
    else
        reqs=rmi.getReqs(obj);
        destIdInReqSet={};
    end

    flags=isFilterMatched(reqs,filters);


    if ceil(obj)~=obj&&obj~=bdroot(obj)
        try
            linkStatus=get_param(obj,'StaticLinkStatus');
            if any(strcmp(linkStatus,{'resolved','implicit'}))
                if markProxyLinks
                    if rmisl.inLibrary(obj)








                        libReqs=[];libLinkDestIdInReqSet={};
                    else

                        [libReqs,libLinkDestIdInReqSet]=getLibReqsFromReqData(obj);
                    end
                else
                    libReqs=rmi.getReqs(obj,true);
                end
                if~isempty(libReqs)
                    libFlags=isFilterMatched(libReqs,filters);
                    reqs=[reqs;libReqs];
                    flags=[flags;libFlags];
                    if markProxyLinks
                        destIdInReqSet=[destIdInReqSet;libLinkDestIdInReqSet];
                    end
                end
            end
        catch ex %#ok<NASGU>

        end
    end
end

function flags=isFilterMatched(reqs,filters)
    if isempty(reqs)
        flags=[];
    else
        if~isempty(filters)
            [~,flags]=rmi.filterTags(reqs,filters.tagsRequire,filters.tagsExclude);
        else
            flags=true(length(reqs),1);
        end
    end
end

function[reqs,destIdInReqSet]=getReqsFromReqData(objH)



    dataLinks=slreq.utils.getLinks(objH);
    if isempty(dataLinks)
        reqs=[];
        destIdInReqSet={};
    else
        reqs=slreq.utils.linkToStruct(dataLinks);
        destIdInReqSet=collectReqSetDestIds(dataLinks);
    end

    function reqSetIds=collectReqSetDestIds(links)
        reqSetIds=cell(numel(links),1);
        for i=1:numel(links)
            link=links(i);
            if isempty(link.dest)||link.isDirectLink()
                reqSetIds{i}='';
            else
                reqSetIds{i}=link.dest.getFullID();
            end
        end
    end
end

function[reqs,destIdInReqSet]=getLibReqsFromReqData(objH)
    reqs=[];destIdInReqSet={};

    isSf=(floor(objH)==objH);
    if isSf
        sfRoot=Stateflow.Root;
        sfObj=sfRoot.idToHandle(objH);
        if isa(sfObj,'Stateflow.AtomicSubchart')&&sfObj.isLink
            refPath=obj.Subchart.Path;
        else
            return;
        end
    else
        refPath=get_param(objH,'ReferenceBlock');
        if isempty(refPath)
            refPath=get_param(objH,'AncestorBlock');
        end
    end

    if isempty(refPath)
        return;
    end

    libName=strtok(refPath,'/');
    if rmiut.isBuiltinNoRmi(libName)
        return;
    end

    if~any(strcmp(find_system('SearchDepth',0),libName))
        return;
    end



    objH=get_param(refPath,'Handle');
    [reqs,destIdInReqSet]=getReqsFromReqData(objH);
end


