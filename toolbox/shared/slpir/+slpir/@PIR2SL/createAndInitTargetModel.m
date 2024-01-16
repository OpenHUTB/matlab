function createAndInitTargetModel(this,isInterfaceModel)

    if nargin<2
        isInterfaceModel=false;
    end

    this.resolveOutModelFile(true);
    outModelFile=this.OutModelFile;
    inMdlFile=this.InModelFile;
    if~isInterfaceModel
        this.genmodeldisp(sprintf('Creating Target model %s',outModelFile),3);
    end

    this.createTargetModel(outModelFile);
    slpir.PIR2SL.initOutputModel(inMdlFile,outModelFile);

    this.OutModelWorkSpace=get_param(outModelFile,'ModelWorkspace');

    if strcmpi(this.ShowModel,'yes')
        open_system(outModelFile);
        link=sprintf('<a href="matlab:open_system(''%s'')">%s</a>',...
        outModelFile,outModelFile);
        this.genmodeldisp(message('hdlcoder:hdldisp:GeneratingNewModel',link));
    end

    if~isempty(inMdlFile)
        simMode=get_param(inMdlFile,'SimulationMode');
    else
        simMode='normal';
    end

    if strncmp(simMode,'accel',5)
        simMode='accelerator';
    elseif strncmp(simMode,'rapid',5)
        if~isInterfaceModel
            hDriver=hdlcurrentdriver;
            hDriver.addCheck(hDriver.ModelName,'Warning',...
            message('hdlcoder:engine:GenModelRapidAccelDropped'));
            simMode='accelerator';
        end
    elseif strncmp(simMode,'softw',5)||strncmp(simMode,'proce',5)||strncmp(simMode,'extern',5)
        simMode='normal';
    end

    hD=hdlcurrentdriver;
    if this.DUTMdlRefHandle>0&&hD.mdlIdx==numel(hD.AllModels)
        this.createAndSetGMSubmodelVariant(outModelFile,simMode);
    else
        set_param(outModelFile,'SimulationMode',simMode);
    end
end


