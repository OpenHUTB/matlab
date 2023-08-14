function result=getDescStrings(obj,index,count)







    if nargin==2
        reqs=rmi.getReqs(obj,index);
    else
        reqs=rmi.getReqs(obj);
        if~isempty(reqs)&&nargin>2
            reqs=rmi.filterReqs(reqs,index,count);
        end
    end


    if isempty(reqs)
        result={};
        return;
    else
        result={reqs.description};
        for i=1:length(result)
            if isempty(result{i})
                result{i}=getString(message('Slvnv:reqmgt:NoDescriptionEntered'));
            end
        end
    end

end