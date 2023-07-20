function collapseNode(~,nodeA,nodeB)
















    if~nodeA.isvalid
        return;
    end


    if nodeA.hasDTConstraints


        unionizedConstraint=nodeA.getConstraints{1};



        if nodeB.hasDTConstraints
            unionizedConstraint=unionizedConstraint+nodeB.getConstraints{1};
        end


        nodeB.setDTConstraints({unionizedConstraint});
    end



    if~(isempty(nodeA.ModelRequiredMin)&&isempty(nodeA.ModelRequiredMax))
        mergedRange=SimulinkFixedPoint.AutoscalerUtils.unionRange(...
        [nodeA.ModelRequiredMin,nodeA.ModelRequiredMax],...
        [nodeB.ModelRequiredMin,nodeB.ModelRequiredMax]);
        nodeB.setPropValue('ModelRequiredMin',mergedRange(1));
        nodeB.setPropValue('ModelRequiredMax',mergedRange(2));
    end

end


