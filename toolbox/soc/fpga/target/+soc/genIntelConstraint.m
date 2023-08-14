function genIntelConstraint(hbuild)
    fprintf('---------- Generating Constraints File ----------\n');
    prj_dir=hbuild.ProjectDir;
    pinConstr=hbuild.ConstraintFile.pinConstr;
    timingConstr=hbuild.ConstraintFile.timingConstr;

    if~isfolder(prj_dir)
        mkdir(prj_dir);
    end


    fid=fopen(fullfile(prj_dir,pinConstr),'w');


    inputClk=hbuild.Board.InputClk;
    fprintf(fid,'# Add clock constraint\n');
    fprintf(fid,'set_location_assignment %s -to %s_clk\n',inputClk.pin{1},inputClk.source);
    fprintf(fid,'set_instance_assignment -name %s -to %s_clk\n\n',inputClk.std,inputClk.source);



    inputRst=hbuild.Board.InputRst;
    fprintf(fid,'# Add reset constraint\n');
    fprintf(fid,'set_location_assignment %s -to %s_reset_n\n',inputRst.pin,inputRst.source);
    fprintf(fid,'set_instance_assignment -name %s -to %s_reset_n\n\n',inputRst.std,inputRst.source);



    fprintf(fid,'# Add external IO constraint\n');
    for i=1:numel(hbuild.ExternalIO)
        fprintf(fid,'set_location_assignment %s -to %s_pin\n',hbuild.ExternalIO(i).pin,hbuild.ExternalIO(i).name);
        fprintf(fid,'set_instance_assignment -name %s -to %s_pin\n\n',hbuild.ExternalIO(i).std,hbuild.ExternalIO(i).name);
    end


    if~isempty(hbuild.HPS)
        fprintf(fid,'# Add HPS constraint\n');
        fprintf(fid,hbuild.HPS.Constraint);
    end


    if~isempty(hbuild.MemPL)
        fprintf(fid,'# Add memory constraint\n');
        fprintf(fid,hbuild.MemPL.Constraint);
    end

    fprintf(fid,'set_instance_assignment -name GLOBAL_SIGNAL OFF -to "*altera_reset_synchronizer:alt_rst_sync_uq1|altera_reset_synchronizer_int_chain_out*"\n');
    fclose(fid);



    fid=fopen(fullfile(prj_dir,timingConstr),'w');

    fprintf(fid,'derive_pll_clocks\n');
    fprintf(fid,'derive_clock_uncertainty\n\n');
    fprintf(fid,'#create clock\n');
    if isa(hbuild.MemPL,'soc.intelcomp.Arria10SoCDDR4')
        fprintf(fid,'create_clock -name {ddr4_pll_ref_clk_clk} -period 7.5 [ get_ports ddr4_pll_ref_clk_clk]\n');
    end
    fprintf(fid,'create_clock -name {%s_clk} -period %.3f [get_ports %s_clk]\n\n',inputClk.source,1000./str2double(inputClk.freq),inputClk.source);
    fprintf(fid,'#set false path\n');
    fprintf(fid,'set_false_path -from [get_ports %s_reset_n] -to *\n\n',inputRst.source);
    fclose(fid);

end