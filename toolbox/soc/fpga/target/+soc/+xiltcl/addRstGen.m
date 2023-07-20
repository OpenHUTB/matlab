function addRstGen(fid,hbuild)










    ip_name='sys_rstgen';
    soc.xiltcl.addInstance(fid,ip_name,'xilinx.com:ip:proc_sys_reset:5.0');
    soc.xiltcl.setInstance(fid,ip_name,{...
    'C_EXT_RST_WIDTH','1'});
    soc.xiltcl.addConnections(fid,{hbuild.SystemClk.source,[ip_name,'/slowest_sync_clk']});
    ps_rst_str='';
    if~isempty(hbuild.PS7)
        ps_rst_str=hbuild.PS7.ResetOutputPort;
    end

    if~isempty(ps_rst_str)
        soc.xiltcl.addConnections(fid,{ps_rst_str,[ip_name,'/ext_reset_in']});
    else
        if~isempty(hbuild.InputRst)
            soc.xiltcl.addConnections(fid,{hbuild.InputRst.source,[ip_name,'/ext_reset_in']});
        else
            error(message('soc:msgs:noResetSignal'));
        end
    end


    ip_name='ipcore_rstgen';
    soc.xiltcl.addInstance(fid,ip_name,'xilinx.com:ip:proc_sys_reset:5.0');
    soc.xiltcl.setInstance(fid,ip_name,{...
    'C_EXT_RST_WIDTH','1'});
    soc.xiltcl.addConnections(fid,{hbuild.IPCoreClk.source,[ip_name,'/slowest_sync_clk']});
    if~isempty(ps_rst_str)
        soc.xiltcl.addConnections(fid,{ps_rst_str,[ip_name,'/ext_reset_in']});
    else
        if~isempty(hbuild.InputRst)
            soc.xiltcl.addConnections(fid,{hbuild.InputRst.source,[ip_name,'/ext_reset_in']});
        else
            error(message('soc:msgs:noResetSignal'));
        end
    end


    if~isempty(hbuild.MemPS)
        ip_name='mem_rstgen';
        soc.xiltcl.addInstance(fid,ip_name,'xilinx.com:ip:proc_sys_reset:5.0');
        soc.xiltcl.setInstance(fid,ip_name,{...
        'C_EXT_RST_WIDTH','1'});
        soc.xiltcl.addConnections(fid,{hbuild.MemPSClk.source,[ip_name,'/slowest_sync_clk']});
        if~isempty(ps_rst_str)
            soc.xiltcl.addConnections(fid,{ps_rst_str,[ip_name,'/ext_reset_in']});
        else
            if~isempty(hbuild.InputRst)
                soc.xiltcl.addConnections(fid,{hbuild.InputRst.source,[ip_name,'/ext_reset_in']});
            else
                error(message('soc:msgs:noResetSignal'));
            end
        end

    elseif~isempty(hbuild.MemPL)

    else

    end

end