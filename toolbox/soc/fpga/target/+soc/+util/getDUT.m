function dut=getDUT(sys)




    non_subsystem_blks=find_system(sys,'SearchDepth',1);
    non_subsystem_blks(strcmpi(non_subsystem_blks,sys))=[];
    subsystem_blks=find_system(sys,'SearchDepth',1,'BlockType','SubSystem');
    for i=1:numel(subsystem_blks)
        non_subsystem_blks(strcmpi(non_subsystem_blks,subsystem_blks{i}))=[];
    end
    allowed_ports_ref={'Inport','Outport','Terminator','Scope','Constant',};
    allowed_ports={};
    for i=1:numel(allowed_ports_ref)
        p=find_system(sys,'SearchDepth',1,'BlockType',allowed_ports_ref{i});
        allowed_ports={allowed_ports{:},p{:}};
    end
    for i=1:numel(allowed_ports)
        non_subsystem_blks(strcmpi(non_subsystem_blks,allowed_ports{i}))=[];
    end
    hsblib_blks=[...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^socmemlib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hsblib_beta2');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hsbhdllib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hwlogiciolib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^soclib_beta');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hwlogicconnlib')];
    for i=1:numel(hsblib_blks)
        non_subsystem_blks(strcmpi(non_subsystem_blks,hsblib_blks{i}))=[];
    end

    if~isempty(non_subsystem_blks)
        error(message('soc:msgs:nonSubsystemExistInFPGAModel',non_subsystem_blks{1},sys));
    end


    illegal_hsb_blks=[...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^socmemlib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hsblib_beta2');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hsbhdllib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hwlogiciolib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^soclib_beta');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hwlogicconnlib')];
    allowed_hsb_ref={...
    'hwlogicconnlib/Stream Connector',...
    'hwlogicconnlib/Video Stream Connector',...
    'hwlogicconnlib/SoC Bus Selector',...
    'hwlogicconnlib/SoC Bus Creator',...
'hwlogiciolib/I2C Master'...
    };
    allowed_hsb_blks={};
    for i=1:numel(allowed_hsb_ref)
        b=find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock',allowed_hsb_ref{i});
        allowed_hsb_blks={allowed_hsb_blks{:},b{:}};
    end
    for i=1:numel(allowed_hsb_blks)
        illegal_hsb_blks(strcmpi(illegal_hsb_blks,allowed_hsb_blks{i}))=[];
    end
    if~isempty(illegal_hsb_blks)
        error(message('soc:msgs:illegalSoCBlkExistInFPGAModel',illegal_hsb_blks{1},sys,strjoin(allowed_hsb_ref,''', ''')));
    end


    hsb_blks=[...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^socmemlib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hsblib_beta2');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hsbhdllib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hwlogiciolib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^soclib_beta');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hwlogicconnlib');...
    find_system(sys,'SearchDepth',1,'ReferenceBlock','xilinxrfsoclib/RFDC Bus Creator');...
    find_system(sys,'SearchDepth',1,'ReferenceBlock','xilinxrfsoclib/RFDC Bus Selector');...
    soc.internal.findAllCustomIPBlks(sys)'];
    ad9361Tx_blk=find_system(sys,'SearchDepth',1,'ReferenceBlock','xilinxsocad9361lib/AD9361Tx');
    ad9361Rx_blk=find_system(sys,'SearchDepth',1,'ReferenceBlock','xilinxsocad9361lib/AD9361Rx');
    adau1761_blk=find_system(sys,'SearchDepth',1,'ReferenceBlock','xilinxsocaudiocodeclib/ADAU1761 Codec');
    hsb_ad9361_blks={hsb_blks{:},ad9361Rx_blk{:},ad9361Tx_blk{:},adau1761_blk{:}};
    HDMIBlks=find_system(sys,'SearchDepth',1,'ReferenceBlock','xilinxsocvisionlib/HDMI Rx');
    HDMIBlks=[HDMIBlks,find_system(sys,'SearchDepth',1,'ReferenceBlock','xilinxsocvisionlib/HDMI Tx')];
    subsystems=find_system(sys,'SearchDepth',1,'BlockType','SubSystem');
    for i=1:numel(hsb_ad9361_blks)
        subsystems(strcmpi(subsystems,hsb_ad9361_blks{i}))=[];
    end
    for nn=1:numel(HDMIBlks)
        subsystems(strcmpi(subsystems,HDMIBlks{nn}))=[];
    end
    for i=1:numel(subsystems)
        refBlk=get_param(subsystems{i},'ReferenceBlock');
        if~isempty(refBlk)
            error(message('soc:msgs:libraryBlkExistInFGPAModel',[subsystems{i},' from ',refBlk],sys))
        end
    end

    dut=find_system(sys,'SearchDepth',1,'BlockType','SubSystem');

    hsblib_blks=[...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^socmemlib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hsblib_beta2');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hsbhdllib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hwlogiciolib');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^soclib_beta');...
    find_system(sys,'SearchDepth',1,'RegExp','on','ReferenceBlock','^hwlogicconnlib');...
    find_system(sys,'SearchDepth',1,'ReferenceBlock','xilinxrfsoclib/RFDC Bus Creator');...
    find_system(sys,'SearchDepth',1,'ReferenceBlock','xilinxrfsoclib/RFDC Bus Selector');...
    soc.internal.findAllCustomIPBlks(sys)'];
    for i=1:numel(hsblib_blks)
        dut(strcmpi(dut,hsblib_blks{i}))=[];
    end


    ad9361Tx_blk=find_system(dut,'SearchDepth',1,'ReferenceBlock','xilinxsocad9361lib/AD9361Tx');
    if~isempty(ad9361Tx_blk)
        dut(strcmpi(dut,ad9361Tx_blk{1}))=[];
    end

    ad9361Rx_blk=find_system(dut,'SearchDepth',1,'ReferenceBlock','xilinxsocad9361lib/AD9361Rx');
    if~isempty(ad9361Rx_blk)
        dut(strcmpi(dut,ad9361Rx_blk{1}))=[];
    end




    adau1761_blk=find_system(dut,'SearchDepth',1,'ReferenceBlock','xilinxsocaudiocodeclib/ADAU1761 Codec');
    if~isempty(adau1761_blk)
        dut(strcmpi(dut,adau1761_blk{1}))=[];
    end




    HDMIBlks=find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','xilinxsocvisionlib/HDMI Rx');
    HDMIBlks=[HDMIBlks,find_system(sys,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'ReferenceBlock','xilinxsocvisionlib/HDMI Tx')];
    if~isempty(HDMIBlks)
        for nn=1:numel(HDMIBlks)
            dut(strcmpi(dut,HDMIBlks{nn}))=[];
        end
    end
end