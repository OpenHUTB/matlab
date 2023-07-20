function hSimscapeBlocks=utilGetSimscapeBlockHandles(obj)




    solverBlocks=obj.SolverConfiguration;
    HDLModelName=obj.HDLModel;
    daemonInfo=obj.StateSpaceParametersDeamon;

    hSimscapeBlocks=cell(numel(daemonInfo),1);
    for i=1:numel(daemonInfo)
        blockList=[unique(daemonInfo(i).blocks);solverBlocks(i);obj.SpsPssConverterBlks{i}'];
        numBlocksDaemon=numel(unique(daemonInfo(i).blocks));
        for j=1:numel(blockList)
            block=blockList{j};
            if j>numBlocksDaemon||strcmp(get_param(block,'BlockType'),'SimscapeBlock')
                [~,remain]=strtok(block,'/');




                block=[HDLModelName,remain];

                hSimscapeBlocks{i}(j)=getSimulinkBlockHandle(block);
            end
        end
        hSimscapeBlocks{i}=hSimscapeBlocks{i}(hSimscapeBlocks{i}>0);
    end
end



