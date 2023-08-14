










































function result=ofind(arg1,type,varargin)

    arg1=convertStringsToChars(arg1);
    type=convertStringsToChars(type);
    if nargin>2
        [varargin{:}]=convertStringsToChars(varargin{:});
    end

    if~strcmpi(arg1,'type')
        error(message('Slvnv:slreq:NeedNameValuePair'));
    end

    if~any(type=='.')
        type=['slreq.',type];
    end

    switch type
    case 'slreq.ReqSet'
        result=slreq.ReqSet.empty();
        dataObjects=slreq.data.ReqData.getInstance.getLoadedReqSets();

    case 'slreq.LinkSet'
        result=slreq.LinkSet.empty();
        dataObjects=slreq.data.ReqData.getInstance.getLoadedLinkSets();

    case 'slreq.Requirement'
        result=slreq.Requirement.empty();
        dataObjects=slreq.data.Requirement.empty;
        reqSets=slreq.data.ReqData.getInstance.getLoadedReqSets();
        for i=1:numel(reqSets)
            myItems=reqSets(i).getItems();



            myItems=slreq.utils.filterByProperties(myItems,varargin{:});
            if~isempty(myItems)
                dataObjects=[dataObjects,myItems];%#ok<AGROW>
            end
        end

    case 'slreq.Reference'
        result=slreq.Reference.empty();
        dataObjects=slreq.data.Requirement.empty;
        reqSets=slreq.data.ReqData.getInstance.getLoadedReqSets();
        for i=1:numel(reqSets)
            [~,myItems]=reqSets(i).getItems();



            myItems=slreq.utils.filterByProperties(myItems,varargin{:});
            if~isempty(myItems)
                dataObjects=[dataObjects,myItems];%#ok<AGROW>
            end
        end

    case 'slreq.Justification'
        result=slreq.Justification.empty();
        dataObjects=slreq.data.Requirement.empty;
        reqSets=slreq.data.ReqData.getInstance.getLoadedReqSets();
        for i=1:numel(reqSets)
            [~,~,myItems]=reqSets(i).getItems();



            myItems=slreq.utils.filterByProperties(myItems,varargin{:});
            if~isempty(myItems)
                dataObjects=[dataObjects,myItems];%#ok<AGROW>
            end
        end

    case 'slreq.Link'
        result=slreq.Link.empty();
        dataObjects=slreq.data.Link.empty();
        linkSets=slreq.data.ReqData.getInstance.getLoadedLinkSets();
        for i=1:numel(linkSets)
            linkedItems=linkSets(i).getLinkedItems();
            for j=1:numel(linkedItems)
                linkedItem=linkedItems(j);

                if linkedItem.isTextRange
                    range=linkedItem.getRange();
                    if range(2)==0






                        continue;
                    end
                end
                links=linkedItem.getLinks();
                if~isempty(links)
                    dataObjects=[dataObjects,links];%#ok<AGROW>
                end
            end
        end

    otherwise
        error('unsupported slreq.* type: %s',type);
    end

    if~isempty(dataObjects)
        if~isempty(varargin)&&~isa(dataObjects(1),'slreq.data.Requirement')




            dataObjects=slreq.utils.filterByProperties(dataObjects,varargin{:});
        end
        for i=1:numel(dataObjects)
            result(end+1)=slreq.utils.dataToApiObject(dataObjects(i));%#ok<AGROW>
        end
    end

end

