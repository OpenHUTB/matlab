





function axi_info=getESBAXIInfo(esb_blk,socsysinfo)

    sys=socsysinfo.modelinfo.sys;
    memMap=soc.memmap.getMemoryMap(sys);


    if isfield(socsysinfo.modelinfo,'map_axi2dut')
        map_axi2dut=socsysinfo.modelinfo.map_axi2dut;
    else
        axi_info='';
        return;
    end

    esb_modelref=bdroot(esb_blk);


    esb_subsystem=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ModelName',esb_modelref);
    esb_subsystem=esb_subsystem{1};
    esb_subsystem_top=get_param(esb_subsystem,'Parent');
    if~isequal(esb_subsystem_top,sys)
        h_esb_ports=get_param(esb_subsystem_top,'PortHandles');
    else
        h_esb_ports=get_param(esb_subsystem,'PortHandles');
    end

    esb_blk_ref=soc.util.getRefBlk(esb_blk);
    if any(strcmpi(esb_blk_ref,{'prociolib/Register Write','prociolib/Register Read'}))
        expectedBlkInTop='Register Channel';
    elseif any(strcmpi(esb_blk_ref,{'prociolib/Stream Write','prociolib/Stream Read'}))

        expectedBlkInTop='Memory Channel, AXI4-Stream to Software, Software to AXI4-Stream';
    else
        expectedBlkInTop='SoC Blockset library block';
    end

    metadata=meta.package.fromName('soc.internal.if');
    if(isempty(metadata)||isempty(metadata.FunctionList))
        SourceBlocks={};
        SinkBlocks={};
    else
        fcns={metadata.FunctionList(startsWith({metadata.FunctionList(:).Name},'registerInterfaceBlocks')).Name};
        registeredInterfaceBlks=cell(1,length(fcns));
        for i=1:length(fcns)
            [registeredInterfaceBlks{i}]=soc.internal.if.(fcns{i});
        end
        SourceBlocks=cellfun(@(x)(x.Sources),registeredInterfaceBlks,'UniformOutput',false);
        SourceBlocks=[SourceBlocks{:}];
        SinkBlocks=cellfun(@(x)(x.Sinks),registeredInterfaceBlks,'UniformOutput',false);
        SinkBlocks=[SinkBlocks{:}];
    end
    this_blk=esb_blk;

    if(ismember(esb_blk_ref,SourceBlocks))

        while(1)
            this_blk_ports=get_param(this_blk,'PortHandles');
            this_inport=this_blk_ports.Inport(1);
            this_line=get_param(this_inport,'Line');
            if this_line==-1
                error(message('soc:utils:BuildModel_DisconnectedBlock',this_blk));
            end
            h_src_blk=get_param(get_param(this_line,'NonVirtualSrcPorts'),'Parent');
            if isempty(h_src_blk)
                error(message('soc:utils:BuildModel_DisconnectedSignal',this_blk));
            end
            if strcmpi(get_param(h_src_blk,'BlockType'),'Inport')
                break;
            else
                this_blk=h_src_blk;
            end
        end
        port_num=get_param(h_src_blk,'Port');


        if~isequal(esb_subsystem_top,sys)
            h_esb_subsystem_port=get_param(esb_subsystem,'PortHandles');
            this_ip=h_esb_subsystem_port.Inport(str2double(port_num));
            this_line=get_param(this_ip,'Line');
            port_num=get_param(get_param(this_line,'SrcBlockHandle'),'Port');
        end


        this_inport=h_esb_ports.Inport(str2double(port_num));
        this_line=get_param(this_inport,'Line');

        [src_blk,~,~,h_src_port]=soc.util.getHSBSrcBlk(this_line);

        if isKey(map_axi2dut,src_blk)
            axi_info.hsb_blk=src_blk;
            dut_ip=map_axi2dut(src_blk);
            axi_info.ipcore_name=dut_ip.ipcore_name;

            if(any(strcmpi(soc.util.getRefBlk(src_blk),{'socmemlib/Register Channel'})))
                reg_port=find_system(src_blk,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Outport','Port',num2str(get_param(h_src_port,'PortNumber')));
                reg_name=get_param(reg_port{1},'PortName');
                reg_num=str2double(reg_name(regexp(reg_name,'[0-9]')));
                this_reg_info=get_reg_info(src_blk,reg_num,memMap,dut_ip.name);
                axi_info.offset=this_reg_info.offset;
                axi_info.esb_if='AXI4-Lite';
            elseif strcmpi(soc.util.getRefBlk(src_blk),'socmemlib/Memory Channel')...
                &&strcmpi(get_param(src_blk,'ProtocolWriter'),'AXI4-Stream')...
                &&strcmpi(get_param(src_blk,'ProtocolReader'),'AXI4-Stream Software')
                axi_info.offset='';
                axi_info.esb_if='AXI4-Stream';
            elseif strcmpi(soc.util.getRefBlk(src_blk),'socmemlib/AXI4-Stream to Software')
                axi_info.offset='';
                axi_info.esb_if='AXI4-Stream';
            end
        else
            error(message('soc:msgs:noConnectSoCBlk',esb_blk,expectedBlkInTop));
        end

    elseif(ismember(esb_blk_ref,SinkBlocks))
        if strcmpi(esb_blk_ref,'prociolib/Register Write')&&soc.internal.hasTunableParam(esb_blk)
            tunableParam=soc.internal.getTunableParamName(esb_blk);
            mwipcoreInfo=socsysinfo.ipcoreinfo.mwipcore_info;
            for i=1:numel(mwipcoreInfo)
                tunableParamList=soc.internal.getTunableParameter(mwipcoreInfo(i).blk_name);
                if ismember(tunableParam,tunableParamList)
                    idx=cellfun(@(x)strcmpi(x,tunableParam),{mwipcoreInfo(i).axi_regs.name});
                    axiReg=mwipcoreInfo(i).axi_regs(idx);
                    axi_info.hsb_blk='';
                    axi_info.offset=axiReg.offset;
                    axi_info.esb_if='AXI4-Lite';
                    axi_info.ipcore_name=mwipcoreInfo(i).ipcore_name;
                    return;
                end
            end
            error(message('soc:msgs:NoIPRegReadBlkForRegWrite',tunableParam,esb_blk));
        else

            while(1)
                this_blk_ports=get_param(this_blk,'PortHandles');
                this_outport=this_blk_ports.Outport(1);
                this_line=get_param(this_outport,'Line');
                if this_line==-1
                    error(message('soc:utils:BuildModel_DisconnectedBlock',this_blk));
                end
                h_dst_blk=get_param(get_param(this_line,'NonVirtualDstPorts'),'Parent');
                if isempty(h_dst_blk)
                    error(message('soc:utils:BuildModel_DisconnectedSignal',this_blk));
                end
                if strcmpi(get_param(h_dst_blk,'BlockType'),'Outport')
                    break;
                else
                    this_blk=h_dst_blk;
                end
            end
            port_num=get_param(h_dst_blk,'Port');


            if~isequal(esb_subsystem_top,sys)
                h_esb_subsystem_port=get_param(esb_subsystem,'PortHandles');
                this_op=h_esb_subsystem_port.Outport(str2double(port_num));
                this_line=get_param(this_op,'Line');
                port_num=get_param(get_param(this_line,'DstBlockHandle'),'Port');
            end


            this_outport=h_esb_ports.Outport(str2double(port_num));
            this_line=get_param(this_outport,'Line');

            [dst_blks,~,~,h_dst_ports]=soc.util.getHSBDstBlk(this_line);

            if~isempty(dst_blks)
                dst_blk=dst_blks{1};
                h_dst_port=h_dst_ports(1);
            else
                dst_blk='';
                h_dst_port='';
            end

            if isKey(map_axi2dut,dst_blk)
                axi_info.hsb_blk=dst_blk;
                dut_ip=map_axi2dut(dst_blk);
                axi_info.ipcore_name=dut_ip.ipcore_name;

                if(any(strcmpi(soc.util.getRefBlk(dst_blk),{'socmemlib/Register Channel'})))
                    reg_port=find_system(dst_blk,'LookUnderMasks','all','FollowLinks','on','SearchDepth',1,'BlockType','Inport','Port',num2str(get_param(h_dst_ports,'PortNumber')));
                    reg_name=get_param(reg_port{1},'PortName');
                    reg_num=str2double(reg_name(regexp(reg_name,'[0-9]')));
                    this_reg_info=get_reg_info(dst_blk,reg_num,memMap,dut_ip.name);
                    axi_info.offset=this_reg_info.offset;
                    axi_info.esb_if='AXI4-Lite';
                elseif strcmpi(soc.util.getRefBlk(dst_blk),'socmemlib/Memory Channel')...
                    &&strcmpi(get_param(dst_blk,'ProtocolReader'),'AXI4-Stream')...
                    &&strcmpi(get_param(dst_blk,'ProtocolWriter'),'AXI4-Stream Software')
                    axi_info.offset='';
                    axi_info.esb_if='AXI4-Stream';
                elseif strcmpi(soc.util.getRefBlk(dst_blk),'socmemlib/Software to AXI4-Stream')
                    axi_info.offset='';
                    axi_info.esb_if='AXI4-Stream';
                end
            else
                error(message('soc:msgs:noConnectSoCBlk',esb_blk,expectedBlkInTop));
            end
        end
    else
        error(message('soc:msgs:notRegIntfBlk',esb_blk));
    end

end

function reg_info=get_reg_info(reg_blk,reg_num,memMap,dutName)
    reg_table_names=evalin('base',get_param(reg_blk,'RegTableNames'));

    reg_vec_lengths=evalin('base',get_param(reg_blk,'RegTableVectorSizes'));
    reg_table_rw=evalin('base',get_param(reg_blk,'RegTableRW'));
    reg_table_defaults=evalin('base',get_param(reg_blk,'RegTableDefaultValues'));

    this_reg_offset=soc.memmap.getRegOffset(memMap,dutName,reg_table_names{reg_num});
    this_default_val=reg_table_defaults{reg_num}(regexp(reg_table_defaults{reg_num},'[a-f 0-9]','ignorecase'));

    switch(reg_table_rw{reg_num})
    case{'W','w','Write','write'}
        reg_dir='write';
    case{'R','r','Read','read'}
        reg_dir='read';
    end
    reg_info=struct(...
    'name',reg_table_names{reg_num},...
    'data_type','uint32',...
    'vec_length',str2double(reg_vec_lengths{reg_num}),...
    'offset',this_reg_offset(3:end),...
    'default_val',this_default_val,...
    'direction',reg_dir,...
    'reg_blk',reg_blk...
    );

    if reg_info.vec_length>1
        strobe_reg=reg_info;
        strobe_reg.name=[reg_info.name,'_strobe'];
        strobe_reg.data_type='uint32';
        strobe_reg.offset=dec2hex(2^ceil(log2((reg_info.vec_length)*4))+hex2dec(reg_info.offset),4);
        reg_info=[reg_info,strobe_reg];
    end
end



