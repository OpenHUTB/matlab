function result=objHasReqs(obj,filters,group_number)



    if~slreq.data.ReqData.exists()



        result=false;
        return;
    end

    if nargin<2
        filters=[];
    end

    if nargin==3
        reqs=rmi.getReqs(obj,group_number);
    else
        reqs=rmi.getReqs(obj);
    end

    if isempty(reqs)
        result=false;
    else


        if~isempty(filters)&&filters.enabled
            reqs=rmi.filterTags(reqs,filters.tagsRequire,filters.tagsExclude);
        end

        if~isempty(filters)&&isfield(filters,'linkedOnly')&&~filters.linkedOnly


            result=~isempty(reqs);
        else

            result=~isempty(reqs)&&any([reqs.linked]);
        end
    end
end
