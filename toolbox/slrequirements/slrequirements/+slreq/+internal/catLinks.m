function link=catLinks(varargin)



    if builtin('_license_checkout','Simulink_Requirements','quiet')
        if isMigrating(varargin{1})

        else
            error(message('Slvnv:reqmgt:setReqs:NoLicense'));
        end
    end

    src=varargin{1};
    if~isstruct(src)
        src=slreq.utils.getRmiStruct(src);
    end

    linkSet=slreq.utils.getLinkSet(src.artifact,src.domain,true);


    linkInfo=varargin{2};

    if nargin==3

        src.id=sprintf('%s.%d',src.id,varargin{3});
    end

    link=slreq.data.Link.empty();
    for i=1:length(linkInfo)


        if isstruct(linkInfo)&&slreq.utils.isLocalFile(linkInfo(i))
            resolvedPath=slreq.uri.getPreferredPath(linkInfo(i).doc,src.artifact);
            if~isempty(resolvedPath)

                linkInfo(i).doc=resolvedPath;
            end
        end

        link=linkSet.addLink(src,linkInfo(i));
    end


    adapter=slreq.adapters.AdapterManager.getInstance.getAdapterByDomain(src.domain);
    adapter.refreshLinkOwner(src.artifact,src.id,[],linkInfo);
end

function tf=isMigrating(obj)
    tf=false;
    if isnumeric(obj)
        isSf=(ceil(obj)==obj);
        reqStr=rmi.getRawReqs(obj,isSf);
        if~isempty(reqStr)
            reqs=rmi.parsereqs(reqStr);
            tf=~isempty(reqs);
        end
    end
end

