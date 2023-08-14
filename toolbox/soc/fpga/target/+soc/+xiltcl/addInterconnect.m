function addInterconnect(fid,hbuild)




    intc_gp=hbuild.Interconnect;

    hp0_master='';
    hp1_master='';
    if~isempty(hbuild.MemPS)





        hp_idx=arrayfun(@(x)(strcmpi(x.usage,'memPS')),intc_gp.master,'UniformOutput',true);
        hp0_master=intc_gp.master(hp_idx);
        intc_gp.master(hp_idx)=[];
        hp1_idx=arrayfun(@(x)(strcmpi(x.name,'axi_vdma_s2mm_2/m_dest_axi')||strcmpi(x.name,'axi_vdma_mm2s_2/m_src_axi')),hp0_master,'UniformOutput',true);
        hp1_master=hp0_master(hp1_idx);
        hp0_master(hp1_idx)=[];
    end

    pl_master='';
    pl_slave='';
    if~isempty(hbuild.MemPL)

        pl_master_idx=arrayfun(@(x)(strcmpi(x.usage,'memPL')),intc_gp.master,'UniformOutput',true);
        pl_master=intc_gp.master(pl_master_idx);
        intc_gp.master(pl_master_idx)=[];

        pl_slave_idx=arrayfun(@(x)(strcmpi(x.usage,'memPL')),intc_gp.slave,'UniformOutput',true);
        pl_slave=intc_gp.slave(pl_slave_idx);
        intc_gp.slave(pl_slave_idx)=[];
    end

    SEG_idx=0;


    if~isempty(pl_slave)
        jtag_master_idx=arrayfun(@(x)(strcmpi(x.name,'jtag_axi/axi4m')),intc_gp.master,'UniformOutput',true);
        if any(jtag_master_idx)
            jtag_master=intc_gp.master(jtag_master_idx);
            intc_gp.master(jtag_master_idx)=[];
            intc_name='axi_intc_jtag';




            jtag_slave=struct('name','','usage','','clk_rstn',jtag_master.clk_rstn,'offset','','range','');
            jtag_slave=[jtag_slave,jtag_slave];
            SEG_idx=addICConnections(fid,intc_name,jtag_master,jtag_slave,hbuild.SystemClk.source,hbuild.SystemRstn.source,hbuild,SEG_idx,'32');
            pl_master=[pl_master,struct('name',[intc_name,'/M00_AXI'],'usage',jtag_master.usage,'clk_rstn',jtag_master.clk_rstn)];
            intc_gp.master=[intc_gp.master,struct('name',[intc_name,'/M01_AXI'],'usage',jtag_master.usage,'clk_rstn',jtag_master.clk_rstn)];
        end
    end


    intc_name='axi_intc_reg';
    SEG_idx=addICConnections(fid,intc_name,intc_gp.master,intc_gp.slave,hbuild.SystemClk.source,hbuild.SystemRstn.source,hbuild,SEG_idx,'32');



    if~isempty(pl_slave)
        intc_name='axi_intc_pl_mem';
        SEG_idx=addICConnections(fid,intc_name,pl_master,pl_slave,hbuild.MemPLClk.source,hbuild.MemPLRstn.source,hbuild,SEG_idx,hbuild.MemPL.Configuration.mm_dw);
    end


    if~isempty(hbuild.PS7)
        if isempty(hbuild.MemPSClk.source)
            ICClkSrc=hbuild.SystemClk.source;
        else
            ICClkSrc=hbuild.MemPSClk.source;
        end
        if~isempty(hp0_master)
            intc_name='axi_intc_hp0';
            SEG_idx=addICConnections(fid,intc_name,hp0_master,hbuild.PS7.AXI4Slave(1),ICClkSrc,hbuild.MemPSRstn.source,hbuild,SEG_idx,hbuild.MemPS.DataWidth);
        end

        if~isempty(hp1_master)
            intc_name='axi_intc_hp1';
            SEG_idx=addICConnections(fid,intc_name,hp1_master,hbuild.PS7.AXI4Slave(2),ICClkSrc,hbuild.MemPSRstn.source,hbuild,SEG_idx,hbuild.MemPS.DataWidth);%#ok<NASGU>
        end
    end

end


function port_name=get_port_name(m_or_s,idx,type)
    m_or_s_str=upper(m_or_s);
    if idx<=10
        idx_str=['0',num2str(idx-1)];
    else
        idx_str=num2str(idx-1);
    end
    switch lower(type)
    case 'clk'
        type_str='ACLK';
    case 'rstn'
        type_str='ARESETN';
    case 'intf'
        type_str='AXI';
    end
    port_name=[m_or_s_str,idx_str,'_',type_str];
end

function clk_name=get_clk_name(buildinfo,type)
    switch lower(type)
    case 'sys'
        clk_name=buildinfo.SystemClk.source;
    case 'memps'
        clk_name=buildinfo.MemPSClk.source;
    case 'mempl'
        clk_name=buildinfo.MemPLClk.source;
    case 'ipcore'
        clk_name=buildinfo.IPCoreClk.source;
    end
end

function rstn_name=get_rstn_name(buildinfo,type)
    switch lower(type)
    case 'sys'
        rstn_name=buildinfo.SystemRstn.source;
    case 'memps'
        rstn_name=buildinfo.MemPSRstn.source;
    case 'mempl'
        rstn_name=buildinfo.MemPLRstn.source;
    case 'ipcore'
        rstn_name=buildinfo.IPCoreRstn.source;
    end
end

function SEG_idx=addICConnections(fid,intc_name,master,slave,clkSrc,rstSrc,hbuild,SEG_idx,dataWidth)

    soc.xiltcl.addInstance(fid,intc_name,'xilinx.com:ip:axi_interconnect:2.1')
    num_master=numel(master);
    num_slave=numel(slave);
    soc.xiltcl.setInstance(fid,intc_name,{'NUM_MI',num2str(num_slave),...
    'NUM_SI',num2str(num_master),...
    'ENABLE_ADVANCED_OPTIONS','1',...
    'XBAR_DATA_WIDTH',dataWidth});


    soc.xiltcl.addConnections(fid,{clkSrc,[intc_name,'/ACLK']});
    fprintf(fid,'set intc_rstn [get_bd_pins -of_objects  [get_bd_cells -of_objects [get_bd_pins %s]] -filter {CONFIG.TYPE == INTERCONNECT && CONFIG.POLARITY == ACTIVE_LOW}]\n',...
    rstSrc);
    soc.xiltcl.addConnections(fid,{'$intc_rstn',[intc_name,'/ARESETN']});


    for idx_m=1:num_master
        m_source=master(idx_m).name;
        clk_rstn_type=master(idx_m).clk_rstn;
        soc.xiltcl.addConnections(fid,{m_source,[intc_name,'/',get_port_name('s',idx_m,'intf')]});
        soc.xiltcl.addConnections(fid,{get_clk_name(hbuild,clk_rstn_type),[intc_name,'/',get_port_name('s',idx_m,'clk')]});
        soc.xiltcl.addConnections(fid,{get_rstn_name(hbuild,clk_rstn_type),[intc_name,'/',get_port_name('s',idx_m,'rstn')]});

        if idx_m<=10
            fprintf(fid,'set_property -dict [list CONFIG.S0%s_HAS_REGSLICE {3}] [get_bd_cells %s]\n',num2str(idx_m-1),intc_name);
        else
            fprintf(fid,'set_property -dict [list CONFIG.S%s_HAS_REGSLICE {3}] [get_bd_cells %s]\n',num2str(idx_m),intc_name);
        end
    end


    for idx_s=1:num_slave
        s_source=slave(idx_s).name;
        clk_rstn_type=slave(idx_s).clk_rstn;
        if~isempty(s_source)
            soc.xiltcl.addConnections(fid,{s_source,[intc_name,'/',get_port_name('m',idx_s,'intf')]});
        end
        soc.xiltcl.addConnections(fid,{get_clk_name(hbuild,clk_rstn_type),[intc_name,'/',get_port_name('m',idx_s,'clk')]});
        soc.xiltcl.addConnections(fid,{get_rstn_name(hbuild,clk_rstn_type),[intc_name,'/',get_port_name('m',idx_s,'rstn')]});

        if idx_s<=10
            fprintf(fid,'set_property -dict [list CONFIG.M0%s_HAS_REGSLICE {3}] [get_bd_cells %s]\n',num2str(idx_s-1),intc_name);
        else
            fprintf(fid,'set_property -dict [list CONFIG.M%s_HAS_REGSLICE {3}] [get_bd_cells %s]\n',num2str(idx_s),intc_name);
        end
    end


    for idx_s=1:num_slave
        s_source=slave(idx_s).name;
        if~isempty(s_source)
            s_usage=slave(idx_s).usage;
            s_offset=slave(idx_s).offset;
            s_range=slave(idx_s).range;
            for idx_m=1:num_master
                m_source=master(idx_m).name;
                m_usage=master(idx_m).usage;
                if(strcmpi(m_usage,'all')||(strcmpi(m_usage,s_usage)&&~contains(s_source,'axi_traffic_gen')))

                    fprintf(fid,'set seg_name [get_bd_addr_segs -of [get_bd_intf_pins %s]]\n',s_source);
                    fprintf(fid,'set seg_name [lindex $seg_name 0]\n');
                    fprintf(fid,'if {$seg_name eq ""} {\n');
                    fprintf(fid,'set seg_name [get_bd_addr_segs -of [get_bd_intf_pins -of [get_bd_intf_nets  -of [get_bd_intf_pins %s] -boundary_type lower] -filter {PATH != /%s}]]\n',s_source,s_source);
                    fprintf(fid,'}\n');
                    fprintf(fid,'set space_name [get_bd_addr_spaces -of_objects [get_bd_intf_pins %s]]\n',m_source);
                    fprintf(fid,'create_bd_addr_seg -range %s -offset %s $space_name $seg_name SEG%s\n',s_range,s_offset,num2str(SEG_idx));
                    SEG_idx=SEG_idx+1;
                end
            end
        end
    end
end