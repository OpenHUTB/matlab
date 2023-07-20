function setPaths2Nodes(tree)





    tree.Paths2Nodes=containers.Map('KeyType','char','ValueType','any');
    modelSpecificParameters=tree.getModelSpecificParameters;
    for msParamIdx=1:numel(modelSpecificParameters)
        modelSpecificParameter=modelSpecificParameters{msParamIdx};
        nextNode=modelSpecificParameter;
        path=serdes.internal.ibisami.ami.RepairSerDesParameterName(nextNode.NodeName);
        while tree.getParent(nextNode)~=tree.ModelSpecificNode
            nextNode=tree.getParent(nextNode);
            path=nextNode.NodeName+"."+path;
        end
        tree.Paths2Nodes(path)=modelSpecificParameter;
    end
end
