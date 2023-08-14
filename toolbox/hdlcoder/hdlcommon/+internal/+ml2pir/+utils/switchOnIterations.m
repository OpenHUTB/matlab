





function finalNode=switchOnIterations(graphBuilder,iterScope,nodesToSwitch,nodeType)



    assert(numel(nodesToSwitch)>0)

    [iterNode,iterType,iterStart,iterStep]=iterScope.getIterNode;



    thresholdVals=cell(1,numel(nodesToSwitch));
    threshold=iterStart;
    for i=1:numel(nodesToSwitch)
        thresholdVals{i}=threshold;
        threshold=cast(threshold+iterStep,'like',iterStart);
    end

    if iterStep<0


        nodesToSwitch=nodesToSwitch(end:-1:1);
        thresholdVals=thresholdVals(end:-1:1);
    end


    prevNode=nodesToSwitch{1};


    switchTypeInfo=internal.mtree.NodeTypeInfo(...
    [nodeType,iterType,nodeType],nodeType);

    for i=2:numel(nodesToSwitch)
        thisSwitch=graphBuilder.createSwitchNode('',switchTypeInfo,...
        'u2 >= Threshold',thresholdVals{i});

        graphBuilder.connect(nodesToSwitch{i},{thisSwitch,1});
        graphBuilder.connect(iterNode,{thisSwitch,2});
        graphBuilder.connect(prevNode,{thisSwitch,3});

        prevNode=thisSwitch;
    end



    finalNode=prevNode;
end
