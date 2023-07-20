function hSimscapeSS=utilPreprocessSimscapeNetwork(HDLModel,obj)









    for i=1:numel(obj.SolverConfiguration)

        [~,remain]=strtok(obj.SolverConfiguration(i),'/');





        block=[obj.HDLModel,remain{1}];
        hSolverBlocks(i)=getSimulinkBlockHandle(block);
    end







    connLabelBlocks=find_system(HDLModel,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','BlockType','ConnectionLabel');
    simscapeBusBlocks=find_system(HDLModel,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks','on','BlockType','SimscapeBus');
    if~isempty(connLabelBlocks)

        me=MException('generateHDLModel:connLabelBlocks',...
        message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:AutoReplaceConnLabelBlocks').getString);
        throwAsCaller(me);
    end
    if~isempty(simscapeBusBlocks)

        me=MException('generateHDLModel:simscapeBusBlocks',...
        message('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:AutoReplaceSimscapeBusBlocks').getString);
        throwAsCaller(me);
    end






    connBlocks=find_system(HDLModel,'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'BlockType','PMIOPort');


    parents=zeros(1,numel(connBlocks));
    for i=1:numel(connBlocks)
        block=connBlocks{i};
        parents(i)=get_param(get_param(block,'Parent'),'handle');
    end
    parents=unique(parents);

    for i=1:numel(parents)


        aMaskObj=Simulink.Mask.get(parents(i));
        if~isempty(aMaskObj)
            if aMaskObj.isSimpleMask()
                aMaskObj.delete()
            end
        end

        Simulink.BlockDiagram.expandSubsystem(parents(i),'CreateArea','Off')
    end






    allBlockLists=getSimscapeBlockHandles(hSolverBlocks);


    hSimscapeSS=zeros(1,numel(allBlockLists));
    for networkNum=1:numel(allBlockLists)
        blocklist=allBlockLists{networkNum};



        Simulink.BlockDiagram.createSubsystem(blocklist);

        hSimscapeSS(networkNum)=get_param(get_param(blocklist(1),'parent'),'handle');
    end



end

function hSimscapeBlocks=getSimscapeBlockHandles(hSolverBlocks)
    hSimscapeBlocks=cell(numel(hSolverBlocks),1);
    for i=1:numel(hSolverBlocks)



        visitedMap=walkSimscapeNetwork(hSolverBlocks(i));
        hBlocks=cell2mat(visitedMap.keys());
        hSimscapeBlocks{i}=hBlocks;
    end
end


function visitedMap=walkSimscapeNetwork(hBlock,visitedMap)

    if nargin<2


        visitedMap=containers.Map(hBlock,true);
    else

        visitedMap(hBlock)=true;
    end


    switch get_param(hBlock,"ReferenceBlock")



    case['nesl_utility/Simulink-PS',newline,'Converter']
        return

    case['nesl_utility/PS-Simulink',newline,'Converter']
        return

    case['nesl_utility_internal/PS-Simulink',newline,'Converter']
        return

    otherwise




        portConnectivity=get_param(hBlock,"PortConnectivity");


        for i=1:numel(portConnectivity)

            for j=1:numel(portConnectivity(i).DstBlock)

                handle=portConnectivity(i).DstBlock(j);

                if~visitedMap.isKey(handle)

                    visitedMap=walkSimscapeNetwork(handle,visitedMap);
                end
            end
        end

    end


end


