
function links=getAllLinks(this,linkSet,filter)






    if nargin<3
        filter={};
    end
    links=[];

    if ischar(linkSet)
        modelLinkSet=this.findLinkSet(linkSet);
    else
        modelLinkSet=this.getModelObj(linkSet);
    end

    if~isempty(modelLinkSet)
        items=modelLinkSet.links.toArray;
        links=slreq.data.Link.empty();
        for i=1:numel(items)
            item=items(i);



            if~isempty(filter)&&~slreq.data.ReqData.isMatch(item,filter)
                continue;
            end

            links(end+1)=this.wrap(item);%#ok<AGROW>
        end
    end
end
