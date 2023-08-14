function res=indexedNode(simlog,indexedPath)




    res=[];

    for idx=1:numel(indexedPath)
        id=indexedPath{idx};

        if isscalar(simlog)


            simlog=lNode(simlog,id);
        else


            simlog=lSubsIndex(simlog,id);
        end


        if isempty(simlog)
            return;
        end

    end


    res=simlog;

end

function res=lNode(simlog,id)


    if ischar(id)&&(isempty(id)||simlog.hasPath(id))
        res=simlog.node(id);
    else
        res=[];
    end

end

function res=lSubsIndex(simlog,index)


    linearIndex=...
    simscape.logging.internal.subArray2Ind(size(simlog),index);



    if~isempty(linearIndex)
        res=simlog(linearIndex);
    else
        res=[];
    end

end
