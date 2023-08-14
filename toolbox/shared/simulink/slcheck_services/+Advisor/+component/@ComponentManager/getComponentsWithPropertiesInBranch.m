



function instIDs=getComponentsWithPropertiesInBranch(this,branchID,props,externalProps)
    instIDs=findComponentsWithProps(this,branchID,props,externalProps,false);
    instIDs=unique(instIDs);
end