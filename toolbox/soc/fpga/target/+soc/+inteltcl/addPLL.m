function addPLL(fid,hbuild)







    source_clk=hbuild.InputClk;


    fprintf(fid,'# add altrea PLL\n');
    switch hbuild.Board.DeviceFamily
    case 'Arria 10'
        fprintf(fid,'add_instance altera_pll altera_iopll \n');
    case 'Cyclone V'
        fprintf(fid,'add_instance altera_pll altera_pll \n');
    otherwise
        error('Device family not supported.');
    end
    fprintf(fid,'set_instance_parameter_value altera_pll {gui_reference_clock_frequency} {%s}\n',source_clk.freq);
    fprintf(fid,'set_instance_parameter_value altera_pll {gui_use_locked} {0}\n');
    gen_ipcore_clk=startsWith(hbuild.IPCoreClk.source,'altera_pll');
    gen_memps_clk=startsWith(hbuild.MemPSClk.source,'altera_pll');

    if gen_ipcore_clk&&gen_memps_clk
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_number_of_clocks} {3}\n');
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_output_clock_frequency0} {%s}\n',hbuild.SystemClk.freq);
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_output_clock_frequency1} {%s}\n',hbuild.IPCoreClk.freq);
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_output_clock_frequency2} {%s}\n',hbuild.MemPSClk.freq);
    elseif gen_ipcore_clk&&~gen_memps_clk
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_number_of_clocks} {2}\n');
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_output_clock_frequency0} {%s}\n',hbuild.SystemClk.freq);
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_output_clock_frequency1} {%s}\n',hbuild.IPCoreClk.freq);
    elseif~gen_ipcore_clk&&gen_memps_clk
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_number_of_clocks} {2}\n');
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_output_clock_frequency0} {%s}\n',hbuild.SystemClk.freq);
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_output_clock_frequency1} {%s}\n',hbuild.MemPSClk.freq);
    else
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_number_of_clocks} {1}\n');
        fprintf(fid,'set_instance_parameter_value altera_pll {gui_output_clock_frequency0} {%s}\n',hbuild.SystemClk.freq);
    end


    fprintf(fid,'add_connection %s.clk altera_pll.refclk\n',source_clk.source);
    fprintf(fid,'add_connection %s.clk_reset altera_pll.reset\n\n',source_clk.source);
