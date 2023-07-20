function SoCBuilderGen(modelName,varargin)

    p=inputParser;
    addParameter(p,'ExternalBuild',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'EnableSWMdlGen',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'EnablePrjGen',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'EnableBitGen',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'ExportRD',false,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'PrjDir','soc_prj',@(x)validateattributes(x,{'char'},{}));
    addParameter(p,'ADIHDLDir','',@(x)validateattributes(x,{'char'},{}));
    addParameter(p,'Debug',true,@(x)validateattributes(x,{'logical'},{'nonempty'}));
    addParameter(p,'BuildAction',3);
    addParameter(p,'dutName','',@(x)validateattributes(x,{'char'},{}));
    addParameter(p,'exportRefDirectory',@(x)validateattributes(x,{'char'},{}));
    addParameter(p,'exportBoardDirectory',@(x)validateattributes(x,{'char'},{}));
    addParameter(p,'boardName','My_board',@(x)validateattributes(x,{'char'},{}));
    addParameter(p,'designName','My_design',@(x)validateattributes(x,{'char'},{}));

    parse(p,varargin{:});

    prjDir=p.Results.PrjDir;
    EnablePrjGen=p.Results.EnablePrjGen;
    EnableBitGen=p.Results.EnableBitGen;
    ExternalBuild=p.Results.ExternalBuild;
    EnableSWMdlGen=p.Results.EnableSWMdlGen;
    ADIHDLDir=p.Results.ADIHDLDir;
    Debug=p.Results.Debug;
    BuildAction=p.Results.BuildAction;
    ExportRD=p.Results.ExportRD;

    workflowObj=soc.internal.SoCGenWorkflow(modelName);
    cleanupWkfw=onCleanup(@()delete(workflowObj));

    workflowObj.ProjectDir=soc.internal.makeAbsolutePath(prjDir);
    workflowObj.Debug=Debug;
    workflowObj.BuildAction=BuildAction;

    workflowObj.ExternalBuild=ExternalBuild;
    workflowObj.EnableSWMdlGen=EnableSWMdlGen;
    workflowObj.ADIHDLDir=ADIHDLDir;

    if(ExportRD)
        workflowObj.dutName=p.Results.dutName;
        workflowObj.exportDirectory=p.Results.exportRefDirectory;
        workflowObj.exportBoardDir=p.Results.exportBoardDirectory;
        workflowObj.boardName=p.Results.boardName;
        workflowObj.designName=p.Results.designName;
        workflowObj.ExportRD=ExportRD;
        EnableBitGen=false;
    end

    setpref(soc.internal.getPrefName,'EnablePrjGen',EnablePrjGen);
    setpref(soc.internal.getPrefName,'EnableBitGen',EnableBitGen);
    cleanupPref=onCleanup(@()l_CleanupFun());

    workflowObj.ValidateModel();
    workflowObj.BuildModel();

end

function l_CleanupFun()
    rmpref(soc.internal.getPrefName,'EnablePrjGen');
    rmpref(soc.internal.getPrefName,'EnableBitGen');
end