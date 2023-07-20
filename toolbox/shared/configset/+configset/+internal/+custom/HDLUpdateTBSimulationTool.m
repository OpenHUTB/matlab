function updateDeps=HDLUpdateTBSimulationTool(cs,msg)




    updateDeps=true;


    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end


    cli=hObj.getCLI;
    hdltb=hObj.getsubcomponent('hdlcoderui.hdltb');



    if hdltb.CosimModel
        cli.GenerateCoSimModel=loc_convertParam(msg.value);
    end

    if hdltb.svdpi_tb
        cli.GenerateSVDPITestbench=loc_convertParam(msg.value);
    end

end

function out=loc_convertParam(simToolVal)
    switch lower(simToolVal)
    case 'mentor graphics modelsim'
        out='ModelSim';
    case 'cadence incisive'
        out='Incisive';
    case 'xilinx vivado simulator'
        out='Vivado Simulator';
    otherwise
        out='None';
    end
end


