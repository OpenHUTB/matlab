function genXilinxConstraint(hbuild)
    fprintf('---------- Generating constraints file ----------\n');
    prj_dir=hbuild.ProjectDir;
    constr_file=hbuild.ConstraintFile;

    if~isfolder(prj_dir)
        mkdir(prj_dir);
    end


    fid=fopen(fullfile(prj_dir,constr_file),'w');

    if soc.internal.isCustomHWBoard(hbuild.Board.Name)




        condition=isempty(hbuild.PS7)&&isempty(hbuild.MemPL);
    else


        condition=isempty(hbuild.PS7)||~isempty(hbuild.MemPL);
    end

    if condition

        input_clk=hbuild.Board.InputClk;
        if strcmpi(input_clk.type,'diff')
            fprintf(fid,'create_clock -period %.3f [get_ports %s]\n',...
            1000./str2double(input_clk.freq),...
            [input_clk.source,'_clk_p']);
            fprintf(fid,'set_property PACKAGE_PIN %s [get_ports %s]\n',...
            input_clk.pin{1},...
            [input_clk.source,'_clk_n']);
            fprintf(fid,'set_property PACKAGE_PIN %s [get_ports %s]\n',...
            input_clk.pin{2},...
            [input_clk.source,'_clk_p']);
            fprintf(fid,'set_property %s [get_ports %s]\n',...
            strrep(input_clk.std,'=',' '),...
            [input_clk.source,'_clk_n']);
            fprintf(fid,'set_property %s [get_ports %s]\n',...
            strrep(input_clk.std,'=',' '),...
            [input_clk.source,'_clk_p']);
        else
            fprintf(fid,'create_clock -period %.3f [get_ports %s]\n',...
            1000./str2double(input_clk.freq),...
            input_clk.source);
            fprintf(fid,'set_property PACKAGE_PIN %s [get_ports %s]\n',...
            input_clk.pin{1},...
            input_clk.source);
            fprintf(fid,'set_property %s [get_ports %s]\n',...
            strrep(input_clk.std,'=',' '),...
            input_clk.source);
        end


        if~isempty(hbuild.Board.InputRst)
            input_rst=hbuild.Board.InputRst;
            fprintf(fid,'set_property PACKAGE_PIN %s [get_ports %s]\n',...
            input_rst.pin,...
            input_rst.source);
            fprintf(fid,'set_property %s [get_ports %s]\n',...
            strrep(input_rst.std,'=',' '),...
            input_rst.source);
        end
    end


    fprintf(fid,'set_clock_groups -asynchronous -group [get_clocks -include_generated_clocks -of [get_pins design_1_i/clkgen/inst/clk_in1*]]\n');


    fprintf(fid,'set_property BITSTREAM.GENERAL.COMPRESS TRUE [current_design]\n');


    for i=1:numel(hbuild.ExternalIO)
        fprintf(fid,'set_property -dict {PACKAGE_PIN %s %s} [get_ports %s]\n',...
        hbuild.ExternalIO(i).pin,...
        strrep(hbuild.ExternalIO(i).std,'=',''),...
        hbuild.ExternalIO(i).name);
    end

    if~isempty(hbuild.PS7)
        fprintf(fid,'%s\n',...
        hbuild.PS7.Constraint);
    end

    if~isempty(hbuild.MemPL)
        fprintf(fid,'%s\n',...
        hbuild.MemPL.Constraint);
    end


    if~isempty(hbuild.FMCIO)
        for nn=1:numel(hbuild.FMCIO)
            fprintf(fid,hbuild.FMCIO{nn}.Constraint);
        end
    end


    if~isempty(hbuild.CustomIP)
        for nn=1:numel(hbuild.CustomIP)
            fprintf(fid,hbuild.CustomIP{nn}.Constraint);
        end
    end



    fclose(fid);
