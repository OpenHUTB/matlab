function handles=getControlFlowBlocks(mdl,tree,treeIdxToHandle)




    handles=[];
    allNodes=tree.descendants(tree.getRoot);

    allSlsfObjs=zeros(numel(allNodes),1);
    for i=1:numel(allNodes)
        allSlsfObjs(i)=treeIdxToHandle(allNodes(i).Id);
    end


    for i=1:length(allSlsfObjs)
        id=allSlsfObjs(i);
        bh=id;
        if strcmpi(get(bh,'Type'),'block')&&...
            strcmp(get(bh,'BlockType'),'SubSystem')
            ph=get(bh,'PortHandles');
            if~isempty(ph.Ifaction)

                ifPort=get(ph.Ifaction,'Object');
                outPort=ifPort.getActualSrc;
                ifBlk=get(outPort(1),'Parent');
                ifH=get_param(ifBlk,'Handle');
                handles(end+1)=ifH;
            end
            if~isempty(ph.Enable)
                handles(end+1)=bh;
            end
            if~isempty(ph.Trigger)
                handles(end+1)=bh;
            end
        end
    end
    handles=unique(handles);
end

