function status=generateNetworkInfo(obj)






    for i=1:length(obj.CovDependency)
        [status,thisNets]=generateMdlNetworkInfo(obj,i);
        if~status
            obj.Networks=[];
            return;
        else
            if isempty(obj.Networks)
                obj.Networks=thisNets;
            else
                for j=1:length(thisNets)
                    obj.Networks{end+1}=thisNets{j};
                end
            end
        end
    end
end

function[status,networks]=generateMdlNetworkInfo(obj,idx)
    status=true;
    networks=[];

    Dependency=obj.CovDependency(idx).Dependency;
    tempNetworks={};


    for i=1:length(Dependency)
        tempNetworks{i}={Dependency(i).BlkName};%#ok<AGROW>
    end



    for i=1:length(Dependency)
        name1=Dependency(i).BlkName;
        idx1=findSetIdx(tempNetworks,name1);
        for j=1:length(Dependency(i).blkInputDependency)
            for k=1:length(Dependency(i).blkInputDependency(j).SrcBlk)
                name2=Dependency(i).blkInputDependency(j).SrcBlk{k};

                if strcmp(name2,'DefaultBlockDiagram')


                    continue;
                end

                setIdx=findSetIdx(tempNetworks,name2);
                if~setIdx

                    status=0;
                    return;
                end
                if setIdx~=idx1
                    tempNetworks{idx1}=[tempNetworks{idx1},tempNetworks{setIdx}];%#ok<AGROW>
                    tempNetworks{setIdx}=[];%#ok<AGROW>
                end
            end
        end
    end

    for i=1:length(tempNetworks)
        networks{end+1}=tempNetworks{i};%#ok<AGROW>
    end
end

function idx=findSetIdx(nets,name)
    idx=0;
    for i=1:length(nets)
        if~isempty(nets{i})&&...
            ~isempty(find(strcmp(name,nets{i}),1))
            idx=i;
            return;
        end
    end
end

function val=hasMoreThanOneBlock(blkList)



    val=(length(blkList)>1);
end
