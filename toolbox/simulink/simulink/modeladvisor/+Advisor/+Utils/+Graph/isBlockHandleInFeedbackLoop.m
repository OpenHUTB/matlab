function result=isBlockHandleInFeedbackLoop(handle,system)


















    result=false;

    if isempty(handle)||isempty(system)
        return;
    end


    diG=Simulink.internal.extractBDTopoGraph(bdroot(system));
    if isempty(diG)
        return;
    end


    [nodes,~]=dfsearch(diG,1,'edgetodiscovered','Restart',true);

    if isempty(nodes)
        return;
    end



    handlesLoop=arrayfun(@(x)diG.Nodes.Handle(x),[nodes(:,1);nodes(:,2)]);
    result=any(ismember(handlesLoop,handle));

    if result
        return;
    end


    for i=1:diG.numnodes
        preds=diG.predecessors(i);
        if numel(preds)<2
            continue;
        end
        for j=1:length(preds)
            sPath=diG.shortestpath(i,preds(j));
            if isempty(sPath)
                continue;
            end
            handlesLoop=arrayfun(@(x)diG.Nodes.Handle(x),sPath);
            result=any(ismember(handlesLoop,handle));
            if result
                return;
            end
        end
    end
end