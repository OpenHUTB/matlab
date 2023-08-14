function[topModel,createForTopModel]=validateTopModelInput(topModel,unparsedSubsys,isInBatchMode,subsys)




    topModel=string(topModel);
    if topModel==""
        if isInBatchMode
            error(message('stm:TestForSubsystem:TopModelRequiredInBatchMode'));
        else
            topModel=inferTopModelFromSubsysInNonBatch(unparsedSubsys);
        end
    end
    if topModel==""
        error(message('stm:TestForSubsystem:NoTopModelSpecified'));
    end
    createForTopModel=any(topModel==subsys);
    if createForTopModel
        bds=find_system('Type','block_diagram');
        if~any(contains(bds,topModel))
            error(message('stm:TestForSubsystem:NoTopModelSpecified'));
        end
    end
end

function topModel=inferTopModelFromSubsysInNonBatch(subsys)
    if isa(subsys,"char")||isa(subsys,"cell")||isa(subsys,"string")
        subsys=string(subsys);
    else
        subsys=string(subsys.getBlock(1));
    end
    if contains(subsys,"/")
        topModel=extractBefore(subsys,"/");
    else
        topModel=subsys;
    end
end
