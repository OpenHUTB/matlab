function createXilinxPrj(hbuild,varargin)

    p=inputParser;
    addParameter(p,'ADIHDLDir','');
    parse(p,varargin{:});
    adi_dir=p.Results.ADIHDLDir;

    hsb_hw_dir=fullfile(matlabroot,'toolbox/soc/fpga/target/hw');
    prj_dir=hbuild.ProjectDir;
    ipcore_dir=fullfile(prj_dir,'ipcore');
    if~isfolder(ipcore_dir)
        mkdir(ipcore_dir);
    end


    copyfile(fullfile(hsb_hw_dir,'script','xilinx'),prj_dir,'f');


    if any(cellfun(@(x)isa(x,'soc.xilcomp.DMAWrite'),hbuild.ComponentList))||...
        any(cellfun(@(x)isa(x,'soc.xilcomp.DMARead'),hbuild.ComponentList))||...
        any(cellfun(@(x)isa(x,'soc.xilcomp.VDMAWrite'),hbuild.ComponentList))||...
        any(cellfun(@(x)isa(x,'soc.xilcomp.VDMARead'),hbuild.ComponentList))||...
        any(cellfun(@(x)isa(x,'soc.xilcomp.VDMAFrameBuffer'),hbuild.ComponentList))||...
        any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),hbuild.FMCIO))

        adi_dma_dir=fullfile(hsb_hw_dir,'ipcore','analogdevices-dmac/library');

        if~isfolder(fullfile(ipcore_dir,'ADI_DMAC'))
            mkdir(fullfile(ipcore_dir,'ADI_DMAC'));
        end
        copyfile(fullfile(adi_dma_dir),fullfile(ipcore_dir,'ADI_DMAC/library'),'f');

        copyfile(fullfile(hsb_hw_dir,'ipcore','adi_dma','dma'),fullfile(ipcore_dir,'ADI_DMAC','library','axi_dmac'),'f');
        copyfile(fullfile(hsb_hw_dir,'ipcore','adi_dma','dma_fifo'),fullfile(ipcore_dir,'ADI_DMAC','library','util_axis_fifo'),'f');
        copyfile(fullfile(hsb_hw_dir,'ipcore','adi_dma','dma_resize'),fullfile(ipcore_dir,'ADI_DMAC','library','util_axis_resize'),'f');
        copyfile(fullfile(hsb_hw_dir,'ipcore','adi_dma','dma_cdc'),fullfile(ipcore_dir,'ADI_DMAC','library','util_cdc'),'f');
        copyfile(fullfile(hsb_hw_dir,'ipcore','adi_dma','dma_interfaces'),fullfile(ipcore_dir,'ADI_DMAC','library','interfaces'),'f');


        copyfile(fullfile(ipcore_dir,'ADI_DMAC','library','common','*'),fullfile(ipcore_dir,'ADI_DMAC','library'),'f');
    end


    if any(cellfun(@(x)isa(x,'soc.xilcomp.AD9361'),hbuild.FMCIO))

        if isempty(adi_dir)

            adi_dir=matlab.internal.get3pInstallLocation('analogdevices-hdl_soc.instrset');
            if~isfolder(adi_dir)
                error(message('soc:msgs:ADILibraryNotFound'));
            end
        end
        spkg_hw_dir=fullfile(fileparts(fileparts(which('xilinxsocad9361lib'))),'hw');
        mkdir(fullfile(ipcore_dir,'library'));
        mkdir(fullfile(ipcore_dir,'library','xilinx'));
        copyfile(fullfile(adi_dir,'library','common'),fullfile(ipcore_dir,'library','common'),'f');
        copyfile(fullfile(adi_dir,'library','axi_ad9361'),fullfile(ipcore_dir,'library','axi_ad9361'),'f');
        copyfile(fullfile(adi_dir,'library','xilinx','common'),fullfile(ipcore_dir,'library','xilinx','common'),'f');
        copyfile(fullfile(spkg_hw_dir,'ipcore','ad9361'),fullfile(ipcore_dir,'library','axi_ad9361'),'f');

        if isunix
            fileattrib(fullfile(ipcore_dir,'library'),'+w','a','s');
        end


        copyfile(fullfile(spkg_hw_dir,'ipcore','clock_gen'),fullfile(ipcore_dir,'clock_gen'),'f');

        copyfile(fullfile(spkg_hw_dir,'ipcore','gpio_tribus_slice_v1_00_a'),fullfile(ipcore_dir,'gpio_tribus_slice_v1_00_a'),'f');
    end


    if any(cellfun(@(x)isa(x,'soc.xilcomp.HDMIRx'),hbuild.FMCIO))||...
        any(cellfun(@(x)isa(x,'hsb.xilcomp.HDMITx'),hbuild.FMCIO))
        if~isfolder(fileparts(which('shared_hdmi.internal.getSpPkgRootDir')))
            error(message('soc:msgs:HDMILibraryNotFound'));
        else
            spkgRootDir=shared_hdmi.internal.getSpPkgRootDir();
        end
        HDMIIPDir=fullfile(spkgRootDir,'target','ipcore','+adi','+hdmi','+vivado');
        requiredIP={'hdmi_rx_if','hdmi_tx_if','imageon_init'};
        for nn=1:numel(requiredIP)
            copyfile(fullfile(HDMIIPDir,requiredIP{nn}),fullfile(ipcore_dir,requiredIP{nn}),'f');
        end


        if~isfile(fullfile(ipcore_dir,'hdmi_rx_if','axi_hdmi_rx_es.v'))
            adi_dir=matlab.internal.get3pInstallLocation('analogdevices-hdl_soc.instrset');
            if~isfolder(adi_dir)
                error(message('soc:msgs:ADILibraryNotFound'));
            end
            copyfile(fullfile(adi_dir,'library','axi_hdmi_rx','axi_hdmi_rx_es.v'),fullfile(ipcore_dir,'hdmi_rx_if'),'f');
            copyfile(fullfile(adi_dir,'library','axi_hdmi_tx','axi_hdmi_tx_es.v'),fullfile(ipcore_dir,'hdmi_tx_if'),'f');
        end
    end



    if any(cellfun(@(x)isa(x,'soc.xilcomp.JTAGMaster'),hbuild.ComponentList))
        hdlv_ip_dir=fileparts(which('hdlverifier.fpga.vivado.iplist'));
        if~isfolder(hdlv_ip_dir)
            error(message('soc:msgs:JTAGMasterNotFound'));
        end
        copyfile(fullfile(hdlv_ip_dir),fullfile(ipcore_dir,'hdlverifier_axi_manager'),'f');
    end


    if any(cellfun(@(x)isa(x,'soc.xilcomp.ATG'),hbuild.ComponentList))
        copyfile(fullfile(hsb_hw_dir,'ipcore','MW_ATG'),fullfile(ipcore_dir,'MW_ATG'),'f');
    end


    if any(cellfun(@(x)isa(x,'soc.xilcomp.APM'),hbuild.ComponentList))
        copyfile(fullfile(hsb_hw_dir,'ipcore','MW_PerfMon'),fullfile(ipcore_dir,'MW_PerfMon'),'f');
    end

    for i=1:numel(hbuild.CustomIP)
        if strcmpi(hbuild.CustomIP{i}.CustomIPParams.useXilinxIP,'OFF')
            [~,srcFolder]=fileparts(hbuild.CustomIP{i}.CustomIPParams.ipcoresrcfolder);
            copyfile(hbuild.CustomIP{i}.CustomIPParams.ipcoresrcfolder,fullfile(ipcore_dir,srcFolder),'f');
        end
    end



    if any(cellfun(@(x)isa(x,'soc.xilcomp.RFDataConverter'),hbuild.FMCIO))
        spkg_hw_dir=fullfile(fileparts(fileparts(which('xilinxrfsoclib'))),'hw');

        copyfile(fullfile(matlabroot,'toolbox/soc/fpga/target/hw','ipcore','sync'),fullfile(ipcore_dir,'sync'),'f');

        copyfile(fullfile(matlabroot,'toolbox/soc/fpga/target/hw','ipcore','DAC_Muxer'),fullfile(ipcore_dir,'DAC_Muxer'),'f');

        copyfile(fullfile(matlabroot,'toolbox/soc/fpga/target/hw','ipcore','ADC_Muxer'),fullfile(ipcore_dir,'ADC_Demuxer'),'f');

        copyfile(fullfile(spkg_hw_dir,'ipcore','ADC_IQSeperator'),fullfile(ipcore_dir,'ADC_IQSeperator'),'f');

        copyfile(fullfile(spkg_hw_dir,'ipcore','rfdc_util'),fullfile(ipcore_dir,'rfdc_util'),'f');
    end


    vivadoToolExe=soc.util.getVivadoPath();


    soc.xiltcl.updateIPCore(hbuild);


    fprintf('---------- Creating Vivado project ----------\n');
    restore.path=pwd;
    cd(prj_dir);

    [err,~]=system([vivadoToolExe,' -log vivado_create_prj.log -mode batch -source create_prj.tcl -tclargs ',hbuild.Board.Device,' ',hbuild.SynOption]);

    if err
        vivadoCreatePrjLogDir=fullfile(pwd,'vivado_create_prj.log');
        vivadoCreatePrjLogName='vivado_create_prj.log';
        vivadoCreatePrjLink=sprintf('''<a href="matlab:open(''%s'')">%s</a>''',vivadoCreatePrjLogDir,vivadoCreatePrjLogName);
        cd(restore.path);
        error(message('soc:msgs:createVivadoPrjError',vivadoCreatePrjLink));
    end
    cd(restore.path);

end