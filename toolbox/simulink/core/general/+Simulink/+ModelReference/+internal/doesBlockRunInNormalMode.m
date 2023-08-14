function isNormal=doesBlockRunInNormalMode(bp)
    if(~isa(bp,'Simulink.BlockPath'))
        DAStudio.error('Simulink:modelReference:DoesBlockRunInNormalModeArgMustBeBlockPath');
    end

    bp.validate();


    topModel=bdroot(bp.getBlock(1));
    topSimMode=get_param(topModel,'SimulationMode');
    if(~strcmpi(topSimMode,'normal'))
        isNormal=false;
        return;
    end

    for blockIdx=1:(bp.getLength()-1)
        modelBlock=bp.getBlock(blockIdx);
        refSimMode=get_param(modelBlock,'SimulationMode');
        if(~strcmpi(refSimMode,'normal'))
            isNormal=false;
            return;
        end
    end

    isNormal=true;
end
