function[node,path,status]=pmsl_extracttreenode(tRoot,reqsCell,isKey,map,isLeaf,getNumBranches,getBranch)















    node=[];
    path=[];
    status=true;

    nCells=numel(reqsCell);
    pm_assert(mod(nCells,2)==0,'req list passed does not have even length');
    nReqs=nCells/2;


    for idx=1:nReqs
        reqKey=reqsCell{2*idx-1};
        if isKey(tRoot,reqKey)
            reqValue=reqsCell{2*idx};
            if~isequal(map(tRoot,reqKey),reqValue)
                status=false;
                break
            end
        else
            status=false;
            break
        end
    end

    if status

        node=tRoot;
        path=[];
    elseif~isLeaf(tRoot)

        n=getNumBranches(tRoot);
        for idx=1:n
            [node,path,status]=pmsl_extracttreenode(getBranch(tRoot,idx),reqsCell,isKey,map,isLeaf,getNumBranches,getBranch);
            if status

                path=[idx,path];
                break
            end
        end
    end

