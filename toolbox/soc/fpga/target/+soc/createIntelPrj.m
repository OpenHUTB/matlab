function createIntelPrj(hbuild,varargin)

    p=inputParser;
    addParameter(p,'ADIHDLDir','');
    parse(p,varargin{:});


    prj_dir=hbuild.ProjectDir;


    hsb_hw_dir=fullfile(matlabroot,'toolbox/soc/fpga/target/hw');
    copyfile(fullfile(hsb_hw_dir,'script','intel'),prj_dir,'f');


    ipcore_dir=fullfile(prj_dir,'ipcore');
    if~isfolder(ipcore_dir)
        mkdir(ipcore_dir);
    end


    if any(cellfun(@(x)isa(x,'soc.intelcomp.JTAGMaster'),hbuild.ComponentList))
        hdlv_ip_dir=fileparts(which('hdlverifier.fpga.quartus.iplist'));
        if~isfolder(hdlv_ip_dir)
            error(message('soc:msgs:JTAGMasterNotFound'));
        end
        copyfile(fullfile(hdlv_ip_dir),fullfile(ipcore_dir,'hdlverifier_axi_manager'),'f');
    end


    if any(cellfun(@(x)isa(x,'soc.intelcomp.ATG'),hbuild.ComponentList))
        copyfile(fullfile(hsb_hw_dir,'ipcore','MW_ATG'),fullfile(ipcore_dir,'MW_ATG'),'f');
    end


    if any(cellfun(@(x)isa(x,'soc.intelcomp.APM'),hbuild.ComponentList))
        copyfile(fullfile(hsb_hw_dir,'ipcore','MW_PerfMon'),fullfile(ipcore_dir,'MW_PerfMon'),'f');
    end


    if any(cellfun(@(x)isa(x,'soc.intelcomp.DMAWrite'),hbuild.ComponentList))||...
        any(cellfun(@(x)isa(x,'soc.intelcomp.DMARead'),hbuild.ComponentList))

        adi_dir=fullfile(hsb_hw_dir,'ipcore','analogdevices-dmac');
        if~isfolder(fullfile(ipcore_dir,'ADI_DMAC'))
            mkdir(fullfile(ipcore_dir,'ADI_DMAC'));
        end
        copyfile(fullfile(adi_dir,'library'),fullfile(ipcore_dir,'ADI_DMAC/library'),'f');

        copyfile(fullfile(hsb_hw_dir,'ipcore','axis_slave_gasket'),fullfile(ipcore_dir,'axis_slave_gasket'),'f');

        copyfile(fullfile(hsb_hw_dir,'ipcore','axis_master_gasket'),fullfile(ipcore_dir,'axis_master_gasket'),'f');
    end


    fprintf('---------- Creating Quartus Project ----------\n');
    restore.path=pwd;
    cd(prj_dir);

    [err,~]=system(['quartus_sh -t ',hbuild.DesignTclFile.quartus]);
    if err
        error(message('soc:msgs:createQuartusPrjError'));
    end




    [~,quartusPath]=soc.util.which('quartus');
    ipmakePath=fullfile(quartusPath,'..','sopc_builder','bin','ip-make-ipx');
    [err,~]=system([ipmakePath,' --source-directory=ipcore']);
    if err
        error(message('soc:msgs:genIPIndexFileError'));
    end

    fprintf('---------- Running Qsys ----------\n');
    qsysScriptPath=fullfile(quartusPath,'..','sopc_builder','bin','qsys-script');
    [err,log]=system([qsysScriptPath,' --script=',hbuild.DesignTclFile.qsys]);

    fid=fopen(fullfile(prj_dir,'qsys_create.log'),'w');
    fprintf(fid,'%s',log);
    fclose(fid);
    if err
        qsysCreateLocation=fullfile(prj_dir,'qsys_create.log');
        qsysCreateName='qsys_create.log';
        qsysCreateLink=sprintf('''<a href="matlab:open(''%s'')">%s</a>''',qsysCreateLocation,qsysCreateName);
        error(message('soc:msgs:executingQsysError','qsys-script',qsysCreateLink));
    end

    qsysGeneratePath=fullfile(quartusPath,'..','sopc_builder','bin','qsys-generate');
    [err,log]=system([qsysGeneratePath,' system_top.qsys --synthesis=VERILOG']);
    fid=fopen(fullfile(prj_dir,'qsys_generate.log'),'w');
    fprintf(fid,'%s',log);
    fclose(fid);

    if err
        qsysGeneateLocation=fullfile(prj_dir,'qsys_generate.log');
        qsysGenerateName='qsys_generate.log';
        qsysGenerateLink=sprintf('''<a href="matlab:open(''%s'')">%s</a>''',qsysGeneateLocation,qsysGenerateName);
        cd(restore.path);
        error(message('soc:msgs:executingQsysError','qsys-generate',qsysGenerateLink));
    end

    cd(restore.path);

end
