function origSubsystem=utilGetOrigSubsystem(solverBlk,inputs,outputs,simscapeModelSolverBlks,i)




    simscapeModelSolverBlk=simscapeModelSolverBlks{i};

    ParentBlock=get_param(solverBlk,'Parent');

    if strcmp(get_param(ParentBlock,'Type'),'block_diagram')||~strcmp(get_param(ParentBlock,'BlockType'),'SubSystem')||numel(find_system(get_param(simscapeModelSolverBlk,'Parent'),'SubClassName','solver'))>1

        networkBlocks={};
        networkBlocks=utilSimscapeNetworkGraph(solverBlk,networkBlocks);

        Simulink.BlockDiagram.createSubsystem(cell2mat(networkBlocks));

        origSubsystem=find_system(gcb,'SearchDepth',1,'Selected','on');

        origSubsystem=origSubsystem{1};

    else


        [spsBlks,pssBlks]=utilGetConverterBlocks(inputs,outputs);
        srcBlksType=cell(1,numel(spsBlks));
        dstBlksType=cell(1,numel(pssBlks));

        for i=1:numel(spsBlks)
            spsData=get_param(spsBlks{i},'PortConnectivity');
            srcBlksType{i}=get_param(spsData(1).SrcBlock,'BlockType');
        end

        for i=1:numel(pssBlks)
            pssData=get_param(pssBlks{i},'PortConnectivity');
            dstBlksType{i}=get_param(pssData(1).DstBlock,'BlockType');
        end



        if all(strcmp(srcBlksType,'Inport'))&&all(strcmp(dstBlksType,'Outport'))&&numel(find_system(get_param(simscapeModelSolverBlk,'Parent'),'SubClassName','solver'))==1

            origSubsystem=get_param(solverBlk,'Parent');

        else
            networkBlocks={};
            networkBlocks=utilSimscapeNetworkGraph(solverBlk,networkBlocks);

            Simulink.BlockDiagram.createSubsystem(cell2mat(networkBlocks));

            origSubsystem=find_system(gcb,'SearchDepth',1,'Selected','on');

            origSubsystem=origSubsystem{1};

        end

    end
end
