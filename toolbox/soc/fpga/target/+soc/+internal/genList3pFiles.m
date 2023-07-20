function genList3pFiles(hbuild)
    fid=fopen('list3pFiles.m','w');
    fprintf(fid,'%% dstList: destination file locations, relative to plugin_rd IPCore folder\n');
    fprintf(fid,'%% srcLIst: source file locations, relative to matlab.internal.get3pInstallLocation(''analogdevices-hdl_soc.instrset'')\n\n\n');

    fprintf(fid,'function [srcList, dstList] = list3pFiles\n');



    if any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),hbuild.FMCIO))||...
        any(cellfun(@(x)isa(x,'hsb.xilcomp.HDMITx'),hbuild.FMCIO))

        [srcList,dstList]=hdmifilelist;
        fprintf(fid,'%%FOR HDMI\n');

        fprintf(fid,'dstList = {...\n');
        for ii=1:numel(dstList)
            fprintf(fid,'%s''%s''\n',getTabStr(1),dstList{ii});
        end
        fprintf(fid,'%s};\n\n',getTabStr(1));


        fprintf(fid,'srcList = {...\n');
        for ii=1:numel(srcList)
            fprintf(fid,'%s''%s''\n',getTabStr(1),srcList{ii});
        end
        fprintf(fid,'%s};\n',getTabStr(1));

    end

    if any(cellfun(@(x)isa(x,'soc.xilcomp.AD9361'),hbuild.FMCIO))
        [~,dstList]=sdrfilelist;
        fprintf(fid,'%%FOR SDR\n');


        fprintf(fid,'dstList = {...\n');
        for ii=1:numel(dstList)
            fprintf(fid,'%s''%s''\n',getTabStr(1),dstList{ii});
        end
        fprintf(fid,'%s};\n\n',getTabStr(1));


        fprintf(fid,'srcList = dstList;\n');
    end
    fprintf(fid,'end\n');
    fclose(fid);
    for i=1:numel(dstList)
        delete(fullfile('ipcore',dstList{i}));
    end

end
function[srcList,dstList]=sdrfilelist
    dstList={...
'library/axi_ad9361/Makefile'
'library/axi_ad9361/axi_ad9361.v'
'library/axi_ad9361/axi_ad9361_constr.sdc'
'library/axi_ad9361/axi_ad9361_constr.xdc'
'library/axi_ad9361/axi_ad9361_delay.tcl'
'library/axi_ad9361/axi_ad9361_hw.tcl'
'library/axi_ad9361/axi_ad9361_ip.tcl'
'library/axi_ad9361/axi_ad9361_rx.v'
'library/axi_ad9361/axi_ad9361_rx_channel.v'
'library/axi_ad9361/axi_ad9361_rx_pnmon.v'
'library/axi_ad9361/axi_ad9361_tdd.v'
'library/axi_ad9361/axi_ad9361_tdd_if.v'
'library/axi_ad9361/axi_ad9361_tx.v'
'library/axi_ad9361/axi_ad9361_tx_channel.v'
'library/axi_ad9361/altera/axi_ad9361_alt_lvds_rx.v'
'library/axi_ad9361/altera/axi_ad9361_alt_lvds_tx.v'
'library/axi_ad9361/altera/axi_ad9361_cmos_if.v'
'library/axi_ad9361/altera/axi_ad9361_lvds_if.v'
'library/axi_ad9361/altera/axi_ad9361_lvds_if_10.v'
'library/axi_ad9361/altera/axi_ad9361_lvds_if_c5.v'
'library/axi_ad9361/xilinx/axi_ad9361_cmos_if.v'
'library/axi_ad9361/xilinx/axi_ad9361_lvds_if.v'
'library/common/ad_addsub.v'
'library/common/ad_adl5904_rst.v'
'library/common/ad_axis_inf_rx.v'
'library/common/ad_b2g.v'
'library/common/ad_csc_1.v'
'library/common/ad_csc_1_add.v'
'library/common/ad_csc_1_mul.v'
'library/common/ad_csc_CrYCb2RGB.v'
'library/common/ad_csc_RGB2CrYCb.v'
'library/common/ad_datafmt.v'
'library/common/ad_dds.v'
'library/common/ad_dds_1.v'
'library/common/ad_dds_2.v'
'library/common/ad_dds_cordic_pipe.v'
'library/common/ad_dds_sine.v'
'library/common/ad_dds_sine_cordic.v'
'library/common/ad_edge_detect.v'
'library/common/ad_g2b.v'
'library/common/ad_iqcor.v'
'library/common/ad_mem.v'
'library/common/ad_mem_asym.v'
'library/common/ad_perfect_shuffle.v'
'library/common/ad_pnmon.v'
'library/common/ad_pps_receiver.v'
'library/common/ad_pps_receiver_constr.ttcl'
'library/common/ad_rst.v'
'library/common/ad_ss_422to444.v'
'library/common/ad_ss_444to422.v'
'library/common/ad_sysref_gen.v'
'library/common/ad_tdd_control.v'
'library/common/ad_xcvr_rx_if.v'
'library/common/axi_ctrlif.vhd'
'library/common/axi_streaming_dma_rx_fifo.vhd'
'library/common/axi_streaming_dma_tx_fifo.vhd'
'library/common/dma_fifo.vhd'
'library/common/pl330_dma_fifo.vhd'
'library/common/up_adc_channel.v'
'library/common/up_adc_common.v'
'library/common/up_axi.v'
'library/common/up_clkgen.v'
'library/common/up_clock_mon.v'
'library/common/up_dac_channel.v'
'library/common/up_dac_common.v'
'library/common/up_delay_cntrl.v'
'library/common/up_hdmi_rx.v'
'library/common/up_hdmi_tx.v'
'library/common/up_pmod.v'
'library/common/up_tdd_cntrl.v'
'library/common/up_xfer_cntrl.v'
'library/common/up_xfer_status.v'
'library/common/util_axis_upscale.v'
'library/common/util_delay.v'
'library/common/util_pulse_gen.v'
'library/xilinx/common/ad_data_clk.v'
'library/xilinx/common/ad_data_in.v'
'library/xilinx/common/ad_data_out.v'
'library/xilinx/common/ad_dcfilter.v'
'library/xilinx/common/ad_iobuf.v'
'library/xilinx/common/ad_mmcm_drp.v'
'library/xilinx/common/ad_mul.v'
'library/xilinx/common/ad_rst_constr.xdc'
'library/xilinx/common/ad_serdes_clk.v'
'library/xilinx/common/ad_serdes_in.v'
'library/xilinx/common/ad_serdes_out.v'
'library/xilinx/common/up_clock_mon_constr.xdc'
'library/xilinx/common/up_xfer_cntrl_constr.xdc'
'library/xilinx/common/up_xfer_status_constr.xdc'
    };
    srcList=dstList;
end
function[srcList,dstList]=hdmifilelist
    dstList={...
'hdmi_rx_if/axi_hdmi_rx_es.v'
    'hdmi_tx_if/axi_hdmi_tx_es.v'};

    srcList={...
'library/axi_hdmi_rx/axi_hdmi_rx_es.v'
    'library/axi_hdmi_tx/axi_hdmi_tx_es.v'};
end
function tabs=getTabStr(num)
    tab='    ';
    tabs='';
    if eq(num,1)
        tabs=tab;
    else
        for nn=1:num
            tabs=[tabs,tab];%#ok<AGROW>
        end
    end
end
