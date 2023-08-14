function physicalBlockList=findPhysicalBlockIntoSubsystem(sourceBlock,subSystem)










    temp1=get_param(subSystem,'PortHandles');
    portHandleList1=[temp1.LConn,temp1.RConn];


    temp2=struct2cell(get_param(sourceBlock,'PortConnectivity'));
    portHandleList2=[];
    for idx=1:size(temp2,2)
        if~isempty([strfind(temp2{1,idx},'RConn'),strfind(temp2{1,idx},'LConn')])
            portHandleList2=[portHandleList2,temp2{6,idx}];
        end
    end



    subSystemPortHandles=intersect(portHandleList1,portHandleList2);



    PMIOPortList={};
    for idx=1:numel(subSystemPortHandles)
        subSystemPortHandle=subSystemPortHandles(idx);
        if~isempty(ee.internal.graph.findPMIOPortInSubSystem(subSystemPortHandle))
            PMIOPortHandle=ee.internal.graph.findPMIOPortInSubSystem(subSystemPortHandle);
            PMIOPort={getfullname(PMIOPortHandle)};
            PMIOPortList=[PMIOPortList;PMIOPort];
        end
    end

    physicalBlockList={};
    PMIOPortConnectedPhysicalBlocks={};
    for idx=1:numel(PMIOPortList)

        blockList=ee.internal.graph.findConnectedBlocksSameLevel(PMIOPortList{idx});
        PMIOPortConnectedPhysicalBlocks=ee.internal.graph.tracePhysicalBlocks(PMIOPortList{idx},blockList);
        physicalBlockList=[physicalBlockList;PMIOPortConnectedPhysicalBlocks];
    end
    physicalBlockList=unique(physicalBlockList);

end