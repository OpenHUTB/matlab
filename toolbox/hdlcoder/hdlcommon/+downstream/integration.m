function varargout=integration(varargin)






















    inputArgs=parseInputArgs(varargin{:});
    modelName=inputArgs.Model;
    cmdDisplay=inputArgs.cmdDisplay;
    tclOnly=inputArgs.tclOnly;
    tclOnlyTool=inputArgs.tclOnlyTool;
    isMLHDLC=inputArgs.isMLHDLC;
    hdlDrv=inputArgs.HDLDriver;
    cdflag=inputArgs.cdflag;
    keepCodegenDir=inputArgs.keepCodegenDir;
    cliDisplay=inputArgs.cliDisplay;
    projectFolder=inputArgs.ProjectFolder;
    verbosity=inputArgs.Verbosity;


    hDI=downstream.handle('Model',modelName,'isMLHDLC',isMLHDLC);

    if isMLHDLC
        modelRoot=modelName;
    else
        try
            modelRoot=bdroot(modelName);
        catch %#ok<CTCH>
            modelRoot=modelName;
        end
    end

    if~isempty(hDI)...
        &&~isempty(hDI.hCodeGen)...
        &&~strcmp(hDI.hCodeGen.ModelName,modelRoot)

        hDI=[];
    end

    if~isempty(hDI)&&~hDI.hAvailableToolList.isToolListEmpty

        hDI.cmdDisplay=cmdDisplay;
        hDI.cliDisplay=cliDisplay;
        hDI.Verbosity=verbosity;
        hDI.tclOnly=tclOnly;
        hDI.tclOnlyTool=tclOnlyTool;

        hDI.hAvailableToolList=downstream.AvailableToolList(hDI);
        hDI.hAvailableSimulationToolList=downstream.AvailableSimulationToolList;


        if~isempty(projectFolder)
            hDI.hWCProjectFolder=projectFolder;
        end



        hDI.loadTargetWorkflow(modelName);
        if hDI.isDynamicWorkflow





            workflow=hDI.get('workflow');
            hWorkflowList=hdlworkflow.getWorkflowList;
            hWorkflow=hWorkflowList.getWorkflow(workflow);
            hWorkflow.loadModelSettings(modelName);
        else
            hDI.loadModelSettings(modelName);
        end
















        hDI.populateTransientCLIMaps;
    else



        hDI=downstream.DownstreamIntegrationDriver(modelName,...
        cmdDisplay,tclOnly,tclOnlyTool,downstream.queryflowmodesenum.NONE,hdlDrv,isMLHDLC,cdflag,keepCodegenDir,cliDisplay,projectFolder,verbosity);
    end


    if nargout==1
        varargout{1}=hDI;
    end

end


function inputArgs=parseInputArgs(varargin)


    persistent p;
    if isempty(p)
        p=inputParser;
        p.addParameter('Model','');
        p.addParameter('cmdDisplay',false);
        p.addParameter('cliDisplay',false);
        p.addParameter('tclOnly',false);
        p.addParameter('tclOnlyTool','');
        p.addParameter('HDLDriver',[]);
        p.addParameter('isMLHDLC',false);


        p.addParameter('cdflag',false);

        p.addParameter('keepCodegenDir',false);
        p.addParameter('ProjectFolder','');

        p.addParameter('Verbosity',0);
    end

    p.parse(varargin{:});
    inputArgs=p.Results;

end


