










function hbuild=genRefDesign(sys,varargin)

    p=inputParser;
    addParameter(p,'ExternalBuild',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'EnableIPCoreGen',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'EnablePrjGen',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'EnableBitGen',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'Verbose',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'PrjDir','',@(x)validateattributes(x,{'char'},{}));
    addParameter(p,'ADIHDLDir','');
    addParameter(p,'NumJobs',min(feature('numthreads'),20),@(x)validateattributes(x,{'numeric'},{'nonempty'}));
    addParameter(p,'EnableCompilation',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    parse(p,varargin{:});

    prjDir=p.Results.PrjDir;
    adiDir=p.Results.ADIHDLDir;
    verbose=p.Results.Verbose;


    soc.internal.validateModelName(sys);
    if isstring(sys)
        sys=char(sys);
    end
    if~bdIsLoaded(sys)
        load_system(sys);
    end


    if isempty(prjDir)
        prjDir='soc_prj';
    end
    soc.internal.validateProjectDir(prjDir);
    prjDir=soc.internal.makeAbsolutePath(prjDir);


    soc.internal.validateCompatibleBoard(sys);


    [fpgaModelBlock,fpgaModel]=soc.util.getHSBSubsystem(sys);
    if~isempty(fpgaModelBlock)&&verbose
        fprintf('### Set %s as FPGA model block.\n',fpgaModelBlock);
    end


    if~isempty(fpgaModel)
        load_system(fpgaModel);
        dut=soc.util.getDUT(fpgaModel);
        if isempty(dut)
            error(message('soc:msgs:checkFpgaNoDUTFound',fpgaModel));
        else
            if verbose
                fprintf('### Set %s as DUT automatically.\n',string(dut));
            end
            dut=get_param(dut,'Name');
        end
    else
        dut='';
    end

    if~isempty(dut)&&~builtin('license','checkout','Simulink_HDL_Coder')
        error(message('soc:msgs:NoHDLCoderLicense'));
    end


    if p.Results.EnableCompilation
        try

            set_param(sys,'SimulationCommand','update');
        catch ME

            ME.getReport();
            rethrow(ME);
        end
    end


    [status,statusMsg,memMap]=soc.memmap.getMapForWorkflow(sys);
    switch status
    case 'info',disp(statusMsg.getString());
    case 'warning',warning(statusMsg);
    case 'error',error(statusMsg);
    end


    topInfo=soc.getTopInfo(sys,memMap,dut);


    intfInfo=soc.getIOInterface(fpgaModel,dut,topInfo);


    hbuild=soc.BuildInfo(fpgaModel,sys,dut,...
    prjDir,'TopInfo',topInfo,'Verbose',verbose,...
    'NumJobs',p.Results.NumJobs,'IntfInfo',intfInfo,'MemMap',memMap);


    if p.Results.EnableIPCoreGen&&~isempty(fpgaModelBlock)

        vendor=soc.internal.getVendor(sys);
        soc.internal.validateToolVersion(vendor);
        for i=1:numel(dut)

            soc.setIOInterface(fpgaModel,dut{i},intfInfo,verbose);
        end
        soc.internal.genIPCore(hbuild);
    end


    socsysinfo=soc.getHandoffInfo(hbuild);

    AXIMasterInfo=soc.genIPCoreRegInfo(socsysinfo,topInfo);

    soc.genReport(socsysinfo,verbose);

    soc.genJTAGScript(AXIMasterInfo,hbuild,socsysinfo,verbose);

    soc.checkFPGADesign(hbuild,socsysinfo,topInfo);

    if p.Results.EnablePrjGen
        soc.internal.genDesignTcl(hbuild);
        soc.internal.genDesignConstraint(hbuild);
        soc.internal.createProject(hbuild,'ADIHDLDir',adiDir);
        if p.Results.EnableBitGen
            soc.internal.buildProject(hbuild,p.Results.ExternalBuild);
        end
    end

end