function removeInvalidData(obj)




    try
        nodes=obj.root.passiveTree.getAllNodes(obj.root.passiveTree.root.children);
        removeNodes=[];
        for idx=1:numel(nodes)
            n=nodes{idx};
            if~isempty(n.data)
                cvd=n.data.getCvd();
                if isempty(cvd)||...
                    ~valid(cvd)||...
                    ~exist(n.data.fullFileName,'file')
                    removeNodes=[removeNodes,n];%#ok<AGROW>
                end
            end
        end
        obj.removeNodes(removeNodes);
    catch MEx
        rethrow(MEx);
    end
end