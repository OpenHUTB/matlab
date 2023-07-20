function genReport(socsysinfo,verbose)
    if verbose
        fprintf('---------- Generating SoC Blockset Builder Report ----------\n');
    end
    prjDir=socsysinfo.projectinfo.prj_dir;
    reportFile=socsysinfo.projectinfo.report;
    [reportDir,reportName,~]=fileparts(reportFile);


    mFile=fullfile(prjDir,[reportName,'.m']);

    if~isfolder(reportDir)
        mkdir(reportDir);
    end


    fid=fopen(mFile,'w');


    fprintf(fid,'%%%%  socBuilder System Report\n');
    fprintf(fid,'%% This report was automatically generated on %s by SoC Blockset.\n',datetime);
    startVer='2019';
    currVer=datestr(version('-date'),'YYYY');
    if strcmpi(startVer,currVer)
        copyRightYr=startVer;
    else
        copyRightYr=sprintf('%s-%s',startVer,currVer);
    end


    l_printSectionTitle(fid,'Project Overview');

    fprintf(fid,'%% * Top model : %s \n',socsysinfo.modelinfo.sys);
    if isfield(socsysinfo.modelinfo,'fpga_model')&&~isempty(socsysinfo.modelinfo.fpga_model)
        fprintf(fid,'%% * FPGA model : %s \n',socsysinfo.modelinfo.fpga_model);

    end
    if isfield(socsysinfo.modelinfo,'arm_model')&&~isempty(socsysinfo.modelinfo.arm_model)
        if~iscell(socsysinfo.modelinfo.arm_model)
            fprintf(fid,'%% * Processor model : %s \n',socsysinfo.modelinfo.arm_model);
        else
            fprintf(fid,'%% * Processor model : %s \n',strjoin(socsysinfo.modelinfo.arm_model,', '));
        end
    end

    fprintf(fid,'%% * Project directory : %s \n',socsysinfo.projectinfo.prj_dir);
    fprintf(fid,'%% * Hardware board : %s \n',socsysinfo.projectinfo.fullboardname);
    if isfield(socsysinfo.projectinfo,'bit_file')&&~isempty(socsysinfo.projectinfo.bit_file)
        fprintf(fid,'%% * Bit file : %s \n',socsysinfo.projectinfo.bit_file);
    end
    if isfield(socsysinfo.projectinfo,'jtag_file')&&~isempty(socsysinfo.projectinfo.jtag_file)
        fprintf(fid,'%% * AXI Manager example file : %s \n',socsysinfo.projectinfo.jtag_file);
    end
    if isfield(socsysinfo.projectinfo,'sw_system')&&~isempty(socsysinfo.projectinfo.sw_system)
        fprintf(fid,'%% * Software model : %s \n',socsysinfo.projectinfo.sw_system);
    end
    if isfield(socsysinfo.projectinfo,'elf_file')&&~isempty(socsysinfo.projectinfo.elf_file)
        if~iscell(socsysinfo.projectinfo.elf_file)
            fprintf(fid,'%% * Software executable : %s \n',socsysinfo.projectinfo.elf_file);
        else
            fprintf(fid,'%% * Software executable : %s \n',strjoin(socsysinfo.projectinfo.elf_file,', '));
        end
    end



    if isfield(socsysinfo,'ipcoreinfo')
        if~isempty(socsysinfo.ipcoreinfo.mwipcore_info)
            l_printSectionTitle(fid,'User IPCore');
        end

        for i=1:numel(socsysinfo.ipcoreinfo.mwipcore_info)
            this_ipcore=socsysinfo.ipcoreinfo.mwipcore_info(i);
            if~strcmpi(this_ipcore.ipcore_name,'vdma_trigger')
                fprintf(fid,'%% * IPCore name: *%s* (base address *%s*)\n',this_ipcore.ipcore_name,this_ipcore.base_addr);

                if~isempty(this_ipcore.axi_regs)
                    fprintf(fid,'%%%%\n');
                    fprintf(fid,'%% <html><table border=1>\n');

                    fprintf(fid,'%% <tr><td>Register Name</td><td>Offset</td><td>Data Type</td><td>Direction</td><td>Vector Length</td></tr>\n');
                    for j=1:numel(this_ipcore.axi_regs)
                        this_axi_regs=this_ipcore.axi_regs(j);
                        if isempty(this_axi_regs.direction)
                            this_axi_regs.direction='-';
                        end
                        fprintf(fid,'%% <tr><td>%s</td><td>%s</td><td>%s</td><td>%s</td><td>%d</td></tr>\n',...
                        this_axi_regs.name,...
                        ['0x',this_axi_regs.offset],...
                        this_axi_regs.data_type,...
                        this_axi_regs.direction,...
                        this_axi_regs.vec_length...
                        );
                    end

                    fprintf(fid,'%% </table></html>');
                    fprintf(fid,'\n\n');
                    fprintf(fid,'%%%%\n');
                end
            end
        end


        if~isempty(socsysinfo.ipcoreinfo.dma_info)...
            ||~isempty(socsysinfo.ipcoreinfo.vdma_info)...
            ||~isempty(socsysinfo.ipcoreinfo.vdma_fifo_info)...
            ||~isempty(socsysinfo.ipcoreinfo.customipcore_info)
            l_printSectionTitle(fid,'Vendor IPCore');
        end


        for i=1:numel(socsysinfo.ipcoreinfo.dma_info)
            this_dma=socsysinfo.ipcoreinfo.dma_info(i);
            fprintf(fid,'%% * IPCore name: *%s* (base address *%s*)\n',this_dma.type,this_dma.base_addr);

            fprintf(fid,'%%%%\n');
            fprintf(fid,'%% <html><table border=1>\n');

            fprintf(fid,'%% <tr><td>Interrupt Number</td><td>%s</td></tr>\n',this_dma.irq_num);
            fprintf(fid,'%% <tr><td>Memory Mapped Data Width</td><td>%s</td></tr>\n',this_dma.mm_dw);
            fprintf(fid,'%% <tr><td>Stream Data Width</td><td>%s</td></tr>\n',this_dma.s_dw);
            fprintf(fid,'%% <tr><td>FIFO Depth</td><td>%s</td></tr>\n',this_dma.fifo_depth);
            fprintf(fid,'%% <tr><td>Max Burst Size</td><td>%s</td></tr>\n',this_dma.burst_size);
            fprintf(fid,'%% <tr><td>Memory Channel Block</td><td>%s</td></tr>\n',this_dma.dma_blk);

            fprintf(fid,'%% </table></html>');
            fprintf(fid,'\n\n');
            fprintf(fid,'%%%%\n');
        end


        for i=1:numel(socsysinfo.ipcoreinfo.vdma_info)
            this_vdma=socsysinfo.ipcoreinfo.vdma_info(i);
            fprintf(fid,'%% * IPCore name: *%s* (base address *%s*)\n',this_vdma.type,this_vdma.base_addr);

            fprintf(fid,'%%%%\n');
            fprintf(fid,'%% <html><table border=1>\n');

            fprintf(fid,'%% <tr><td>Memory Mapped Data Width</td><td>%s</td></tr>\n',this_vdma.mm_dw);
            fprintf(fid,'%% <tr><td>Stream Data Width</td><td>%s</td></tr>\n',this_vdma.s_dw);
            fprintf(fid,'%% <tr><td>Buffer Depth</td><td>%s</td></tr>\n',this_vdma.buf_depth);
            fprintf(fid,'%% <tr><td>Max Burst Size</td><td>%s</td></tr>\n',this_vdma.burst_size);
            fprintf(fid,'%% <tr><td>Memory Channel Block</td><td>%s</td></tr>\n',this_vdma.vdma_blk);

            fprintf(fid,'%% </table></html>');
            fprintf(fid,'\n\n');
            fprintf(fid,'%%%%\n');
        end


        for i=1:numel(socsysinfo.ipcoreinfo.vdma_fifo_info)
            this_vdma_fifo=socsysinfo.ipcoreinfo.vdma_fifo_info(i);
            fprintf(fid,'%% * IPCore name: *%s* (base address *%s*)\n',this_vdma_fifo.type,this_vdma_fifo.base_addr);

            fprintf(fid,'%%%%\n');
            fprintf(fid,'%% <html><table border=1>\n');

            fprintf(fid,'%% <tr><td>S2MM Memory Mapped Data Width</td><td>%s</td></tr>\n',this_vdma_fifo.s2mm_mm_dw);
            fprintf(fid,'%% <tr><td>S2MM Stream Data Width</td><td>%s</td></tr>\n',this_vdma_fifo.s2mm_s_dw);
            fprintf(fid,'%% <tr><td>S2MM Buffer Depth</td><td>%s</td></tr>\n',this_vdma_fifo.s2mm_buf_depth);
            fprintf(fid,'%% <tr><td>S2MM Max Burst Size</td><td>%s</td></tr>\n',this_vdma_fifo.s2mm_burst_size);
            fprintf(fid,'%% <tr><td>MM2S Memory Mapped Data Width</td><td>%s</td></tr>\n',this_vdma_fifo.mm2s_mm_dw);
            fprintf(fid,'%% <tr><td>MM2S Stream Data Width</td><td>%s</td></tr>\n',this_vdma_fifo.mm2s_s_dw);
            fprintf(fid,'%% <tr><td>MM2S Buffer Depth</td><td>%s</td></tr>\n',this_vdma_fifo.mm2s_buf_depth);
            fprintf(fid,'%% <tr><td>MM2S Max Burst Size</td><td>%s</td></tr>\n',this_vdma_fifo.mm2s_burst_size);
            fprintf(fid,'%% <tr><td>Memory Channel Block</td><td>%s</td></tr>\n',this_vdma_fifo.vdma_blk);

            fprintf(fid,'%% </table></html>');
            fprintf(fid,'\n\n');
            fprintf(fid,'%%%%\n');
        end


        for i=1:numel(socsysinfo.ipcoreinfo.customipcore_info)
            this_customipcore=socsysinfo.ipcoreinfo.customipcore_info(i);
            fprintf(fid,'%% * IPCore name: *%s* \n',this_customipcore.ipcore_name);

            fprintf(fid,'%%%%\n');
            fprintf(fid,'%% <html><table border=1>\n');
            fprintf(fid,'%% <tr><td>Slave Interface</td><td>Base Address</td></tr>\n');
            for j=1:length(this_customipcore.SInterfaces)
                fprintf(fid,'%% <tr><td>%s</td><td>%s</td></tr>\n',this_customipcore.SInterfaces(j).name,this_customipcore.SInterfaces(j).offset);
            end

            fprintf(fid,'%% </table></html>');
            fprintf(fid,'\n\n');
            fprintf(fid,'%%%%\n');
        end


        if~isempty(socsysinfo.ipcoreinfo.perf_mon_info)...
            ||~isempty(socsysinfo.ipcoreinfo.ATGInfo)
            l_printSectionTitle(fid,'MathWorks IPCore');
        end

        for i=1:numel(socsysinfo.ipcoreinfo.perf_mon_info)
            this_perf_mon=socsysinfo.ipcoreinfo.perf_mon_info(i);
            fprintf(fid,'%% * IPCore name: *%s* (base address *%s*)\n','MW_PerfMon',this_perf_mon.base_addr);
            fprintf(fid,'%%%%\n');
            fprintf(fid,'%% <html><table border=1>\n');

            fprintf(fid,'%% <tr><td>Number of Masters</td><td>%d</td></tr>\n',this_perf_mon.num_slots);
            fprintf(fid,'%% <tr><td>Master Data Width</td><td>%s</td></tr>\n',num2str(this_perf_mon.slot_dw));

            fprintf(fid,'%% </table></html>');
            fprintf(fid,'\n\n');
            fprintf(fid,'%%%%\n');
        end

        for i=1:numel(socsysinfo.ipcoreinfo.ATGInfo)
            this_ATG=socsysinfo.ipcoreinfo.ATGInfo(i);
            fprintf(fid,'%% * IPCore name: *%s* (base address *%s*)\n',['axi_traffic_gen_',num2str(i-1)],this_ATG.base_addr);
            fprintf(fid,'%%%%\n');
            fprintf(fid,'%% <html><table border=1>\n');

            fprintf(fid,'%% <tr><td>Burst Size</td><td>%s</td></tr>\n',this_ATG.bsize);
            fprintf(fid,'%% <tr><td>Data Width</td><td>%s</td></tr>\n',this_ATG.mem_width);
            periods=str2num(this_ATG.periods);
            fprintf(fid,'%% <tr><td>Transaction Period </td><td>%s</td></tr>\n',num2str(periods(1)));

            fprintf(fid,'%% </table></html>');
            fprintf(fid,'\n\n');
            fprintf(fid,'%%%%\n');
        end
    end

    fprintf(fid,'%%\n%%\n');
    fprintf(fid,'%% (C) %s The MathWorks, Inc.  All Rights Reserved.\n',copyRightYr);
    fprintf(fid,'%%\n%%\n');
    fclose(fid);


    publish(mFile,'evalCode',false);
    if isfile(mFile)
        delete(mFile);
    end

end


function l_printSectionTitle(fid,text)
    fprintf(fid,'\n%%%%%% %s\n',text);
    fprintf(fid,'%%%%\n');
end


