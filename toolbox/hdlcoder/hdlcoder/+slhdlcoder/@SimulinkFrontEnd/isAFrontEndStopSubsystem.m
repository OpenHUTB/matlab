function[frontendstop,bboxsystem]=isAFrontEndStopSubsystem(~,impl,blockPath)






    if isempty(impl)
        frontendstop=slhdlcoder.SimulinkFrontEnd.isStateFlowReactiveTestingBlock(blockPath);
        bboxsystem=false;
        return;
    end

    bboxsystem=true;

    if impl.recurseIntoSubSystem()

        if targetcodegen.alteradspbadriver.isDSPBASubsystem(blockPath)
            frontendstop=true;

        elseif targetcodegen.xilinxisesysgendriver.isXSGSubsystem(blockPath)
            frontendstop=true;
        elseif targetcodegen.xilinxvivadosysgendriver.isXSGSubsystem(blockPath)
            frontendstop=true;
        else
            frontendstop=false;
            bboxsystem=false;
        end
    else
        frontendstop=true;
    end
end


