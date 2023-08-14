function[selectedNodes,selectedPaths,labels]=...
    getExplorerSelectedNodes(selectedPaths,loggedNode)








    import simscape.logging.internal.*;

    numSelected=numel(selectedPaths);
    selectedNodes=cell(1,numSelected);
    pathLabels=cell(1,numSelected);


    for idx=1:numSelected
        selectedNodes{idx}=lIndexedNode(loggedNode,selectedPaths{idx});
        pathLabels{idx}=indexedPathLabel(selectedPaths{idx}(2:end));
    end


    [pathLabels,sortIdx]=sort(pathLabels);
    selectedPaths=selectedPaths(sortIdx);
    selectedNodes=selectedNodes(sortIdx);


    ids=cellfun(@(x)(x.id),selectedNodes,'UniformOutput',false);



    labels=ids;




    uniqueIds=unique(ids);
    if numel(uniqueIds)~=numel(ids)
        for idx=1:numel(uniqueIds)
            i=strcmp(ids,uniqueIds{idx});


            if numel(find(i))>1
                labels(i)=pathLabels(i);
            end
        end

    end
end

function res=lIndexedNode(simlog,p)
    res=[];
    for idx=2:numel(p)
        item=p{idx};
        if isnumeric(item)
            if(numel(simlog)>=item)
                simlog=simlog(item);
            else
                return;
            end
        else
            ids=simlog.childIds;
            if ismember(item,ids)
                simlog=getChild(simlog,item);
            else
                return;
            end
        end
    end
    res=simlog;
end