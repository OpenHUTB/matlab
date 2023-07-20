function removeIncompatibleData(obj)




    nodes=obj.root.passiveTree.getAllNodes(obj.root.passiveTree.root.children);
    removeNodes=[];
    for idx=1:numel(nodes)
        n=nodes{idx};
        removeIt=false;
        if~isempty(n.data)
            cvd=n.data.getCvd();
            if~isempty(cvd)&&...
                valid(cvd)
                fullFileName=n.data.fullFileName;

                if~exist(fullFileName,'file')
                    removeIt=true;
                else
                    [res,part]=matchChecksum(obj,cvd);
                    if isempty(res)||part
                        removeIt=true;
                    end
                end
            else
                removeIt=true;
            end
            if removeIt
                removeNodes=[removeNodes,n];%#ok<AGROW>
            end
        end
    end
    obj.removeNodes(removeNodes);
end