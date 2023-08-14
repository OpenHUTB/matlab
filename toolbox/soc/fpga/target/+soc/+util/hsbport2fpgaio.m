function fpga_io=hsbport2fpgaio(vendor,hsb_blk,hsb_port,intfInfo)

    blk_ref=soc.util.getRefBlk(hsb_blk);
    [isCstmIP,internalCstmIPBlk]=soc.internal.isSoCBCustomIPBlk(hsb_blk);
    fpga_io='';
    switch blk_ref
    case 'hwlogicconnlib/Stream Connector'
        if isWritePort(hsb_port)
            [dst_blks,dst_ports,~,~]=soc.util.getConnectedBlk([hsb_blk,'/rdData']);
            if~isempty(dst_blks)
                fpga_io=soc.util.dutport2fpgaio(vendor,dst_blks{1},dst_ports{1},intfInfo);
            end
        elseif isReadPort(hsb_port)
            [src_blk,src_port,~,~]=soc.util.getConnectedBlk([hsb_blk,'/wrData']);
            if~isempty(src_blk)
                fpga_io=soc.util.dutport2fpgaio(vendor,src_blk,src_port,intfInfo);
            end
        end
    case 'hwlogicconnlib/Video Stream Connector'
        if isWritePort(hsb_port)
            [dst_blks,dst_ports,~,~]=soc.util.getConnectedBlk([hsb_blk,'/rdData']);
            if~isempty(dst_blks)
                if strcmp(soc.util.getRefBlk(dst_blks{1}),'xilinxsocvisionlib/HDMI Tx')
                    fpga_io='axi_vdma_s2mm_2/s_axis';
                elseif strcmp(get_param(dst_blks{1},'BlockType'),'Outport')
                    thisIntfInfo=intfInfo(dst_blks{1});
                    if strcmp(thisIntfInfo.interface,'HDMI/video_in')
                        fpga_io='axi_vdma_s2mm_2/s_axis';
                    else
                        fpga_io=soc.util.dutport2fpgaio(vendor,dst_blks{1},dst_ports{1},intfInfo);
                    end
                else
                    fpga_io=soc.util.dutport2fpgaio(vendor,dst_blks{1},dst_ports{1},intfInfo);
                end
            end
        else
            [src_blk,src_port,~,~]=soc.util.getConnectedBlk([hsb_blk,'/wrData']);
            if~isempty(src_blk)
                if strcmp(soc.util.getRefBlk(src_blk),'xilinxsocvisionlib/HDMI Rx')
                    fpga_io='HDMI/video_out';
                elseif strcmp(get_param(src_blk,'BlockType'),'Inport')
                    thisIntfInfo=intfInfo(src_blk);
                    if strcmp(thisIntfInfo.interface,'HDMI/video_out')
                        fpga_io='HDMI/video_out';
                    else
                        fpga_io=soc.util.dutport2fpgaio(vendor,src_blk,src_port,intfInfo);
                    end
                else
                    fpga_io=soc.util.dutport2fpgaio(vendor,src_blk,src_port,intfInfo);
                end
            end
        end
    case{'hwlogiciolib/DIP Switch','hwlogiciolib/Push Button','hwlogiciolib/LED','xilinxsocaudiocodeclib/ADAU1761 Codec','soclib_beta/I//O Pin'}
        fpga_io=hsb_port;

    case{'socmemlib/AXI4-Stream to Software','socmemlib/Software to AXI4-Stream'}
        if isWritePort(hsb_port)
            if strcmpi(vendor,'xilinx')
                fpga_io='dma_s2mm/s_axis';
            else
                fpga_io='axis_slave_gasket.axi4stream_slave';
            end
        elseif isReadPort(hsb_port)
            if strcmpi(vendor,'xilinx')
                fpga_io='dma_mm2s/m_axis';
            else
                fpga_io='axis_master_gasket.axi4stream_master';
            end
        end
    case 'socmemlib/AXI4 Random Access Memory'
        if isWritePort(hsb_port)
            fpga_io=['axim_wr/',get_param(hsb_blk,'Name')];
        elseif isReadPort(hsb_port)
            fpga_io=['axim_rd/',get_param(hsb_blk,'Name')];
        end
    case 'socmemlib/AXI4 Video Frame Buffer'
        if isWritePort(hsb_port)
            fpga_io='axi_vdma_s2mm_1/s_axis';
        elseif isReadPort(hsb_port)
            fpga_io='axi_vdma_mm2s_1/m_axis';
        end
    case 'socmemlib/Memory Channel'
        if any(strcmpi(get_param(hsb_blk,'ProtocolReader'),{'AXI4-Stream Software','AXI4-Stream'}))...
            &&any(strcmpi(get_param(hsb_blk,'ProtocolWriter'),{'AXI4-Stream Software','AXI4-Stream'}))
            if isWritePort(hsb_port)
                if strcmpi(vendor,'xilinx')
                    fpga_io='dma_s2mm/s_axis';
                else
                    fpga_io='axis_slave_gasket.axi4stream_slave';
                end
            elseif isReadPort(hsb_port)
                if strcmpi(vendor,'xilinx')
                    fpga_io='dma_mm2s/m_axis';
                else
                    fpga_io='axis_master_gasket.axi4stream_master';
                end
            end
        elseif strcmpi(get_param(hsb_blk,'ProtocolReader'),'AXI4-Stream Video with Frame Sync')...
            &&strcmpi(get_param(hsb_blk,'ProtocolWriter'),'AXI4-Stream Video')
            if isWritePort(hsb_port)
                fpga_io='axi_vdma_s2mm_1/s_axis';
            elseif isReadPort(hsb_port)
                fpga_io='axi_vdma_mm2s_1/m_axis';
            end
        elseif strcmpi(get_param(hsb_blk,'ProtocolReader'),'AXI4')...
            &&strcmpi(get_param(hsb_blk,'ProtocolWriter'),'AXI4')
            if isWritePort(hsb_port)
                fpga_io=['axim_wr/',get_param(hsb_blk,'Name')];
            elseif isReadPort(hsb_port)
                fpga_io=['axim_rd/',get_param(hsb_blk,'Name')];
            end
        elseif strcmpi(get_param(hsb_blk,'ProtocolReader'),'AXI4-Stream Video')...
            &&strcmpi(get_param(hsb_blk,'ProtocolWriter'),'AXI4-Stream Video')
            if isWritePort(hsb_port)
                fpga_io='axi_vdma_s2mm_0/s_axis';
            elseif isReadPort(hsb_port)
                fpga_io='axi_vdma_mm2s_0/m_axis';
            end
        end
    case 'hwlogicconnlib/SoC Bus Creator'
        if strcmpi(hsb_port,'fsync')
            fpga_io='axi_vdma_mm2s_1/dest_ext_sync';
        end
    case 'xilinxsocad9361lib/AD9361Tx'
        if strcmpi(hsb_port,'tx_data_in')
            fpga_io='AD9361/tx_data_in';
        end
        if strcmpi(hsb_port,'tx_valid')
            fpga_io='AD9361/tx_valid';
        end
    case 'xilinxsocad9361lib/AD9361Rx'
        fpga_io=['AD9361/',hsb_port];
    case 'xilinxsocvisionlib/HDMI Rx'
        fpga_io='HDMI/video_out';
    case 'xilinxsocvisionlib/HDMI Tx'
        fpga_io='HDMI/video_in';
    case 'xilinxrfsoclib/RF Data Converter'
        fpga_io=soc.internal.getRFDCIOName(hsb_blk,hsb_port);
    case 'xilinxrfsoclib/RFDC Bus Creator'
        fpga_io=soc.internal.getRFDCIOName('','',blk_ref,hsb_blk,hsb_port,intfInfo);
    case 'xilinxrfsoclib/RFDC Bus Selector'
        fpga_io=soc.internal.getRFDCIOName('','',blk_ref,hsb_blk,hsb_port,intfInfo);

    end

    if isCstmIP
        portIntfInfo=soc.blkcb.customIPCb('getPortIntfInfo',internalCstmIPBlk,hsb_port);
        fpga_io=[(get_param(internalCstmIPBlk,'ipInstanceName')),'/',portIntfInfo.Name];
    end


    if strcmpi(get_param(hsb_blk,'BlockType'),'Inport')...
        ||strcmpi(get_param(hsb_blk,'BlockType'),'Outport')
        thisIntfInfo=intfInfo(hsb_blk);
        if strcmpi(thisIntfInfo.interface,'HDMI/video_in')
            fpga_io='axi_vdma_s2mm_2/s_axis';
        else
            fpga_io=thisIntfInfo.interface;
        end
        if strcmpi(fpga_io,'axi4_lite')||strcmpi(fpga_io,'axi4')
            fpga_io='';
        end
    end
end

function result=isWritePort(portName)
    if any(strcmpi(portName,{'wrdata','wrctrlin','wrctrlout','wrvalid','wrready','wrlast'}))
        result=true;
    else
        result=false;
    end
end

function result=isReadPort(portName)
    if any(strcmpi(portName,{'rddata','rdctrlout','rdctrlin','rdvalid','rdready','rdlast'}))
        result=true;
    else
        result=false;
    end
end