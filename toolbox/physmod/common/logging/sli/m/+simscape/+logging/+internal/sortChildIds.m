function children=sortChildIds(node)

    if hasTagValue(node,'SimulationStatistics','Statistics')
        children=node.childIds;
        if~isempty(children)
            n_=numel(strfind(children{1},'_'));
            if n_==1

                [~,idx]=sort(cellfun(@(c)eval(c(4:end)),children));
                children=children(idx);
            else




                assert(n_==2);
                children=sort(children);
            end
        end
    else
        children=sort(node.childIds);



        if node.isFrequency()
            pos=find(strcmp(children,'instantaneous'));
            if(pos>0&&pos<numel(children))
                children([1,pos])=children([pos,1]);
            end
        end

    end
end
