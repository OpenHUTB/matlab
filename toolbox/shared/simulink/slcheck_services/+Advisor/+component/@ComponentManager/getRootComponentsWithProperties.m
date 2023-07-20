function instIDs=getRootComponentsWithProperties(this,props,externalProps)
    instIDs=findComponentsWithProps(this,...
    this.AnalysisRootComponentID,props,externalProps,true);

    instIDs=unique(instIDs);
end