function out=HDL_SimToolValues(cs,name,direction,widgetVals)










    if isa(cs,'Simulink.ConfigSet')
        hObj=cs.getComponent('HDL Coder');
    else
        hObj=cs;
    end


    cli=hObj.getCLI;
    hdltb=hObj.getsubcomponent('hdlcoderui.hdltb');

    if direction==0
        if hdltb.edalinksinstalled&&...
            (strcmpi(cli.(name),'ModelSim')||strcmpi(cli.(name),'Incisive')||strcmpi(cli.(name),'Vivado Simulator'))
            out={'on'};
        else
            out={'off'};
        end

    elseif direction==1
        if widgetVals{1}
            simtool=cli.SimulationTool;
            switch lower(simtool)
            case 'mentor graphics modelsim'
                out='ModelSim';
            case 'cadence incisive'
                out='Incisive';
            case 'xilinx vivado simulator'
                out='Vivado Simulator';
            otherwise
                out='None';
            end
        else
            out='None';
        end


        switch(name)
        case 'GenerateCoSimModel'
            hdltb.CosimModel=widgetVals{1};
        case 'GenerateSVDPITestBench'
            hdltb.svdpi_tb=widgetVals{1};
        end
    end


