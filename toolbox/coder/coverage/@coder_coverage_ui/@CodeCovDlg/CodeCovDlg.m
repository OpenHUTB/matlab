function h=CodeCovDlg(toolName,toolClass,toolCompany,...
    hParentHSrc,varargin)





    h=coder_coverage_ui.CodeCovDlg;
    h.ToolName=toolName;
    h.ToolClass=toolClass;
    h.ToolCompany=toolCompany;
    h.ParentHSrc=hParentHSrc;

    cs=hParentHSrc.getConfigSet;
    model=hParentHSrc.getModel;
    assert(isa(cs,'Simulink.ConfigSet'),'The CodeCovDlg cannot be attached to a configset reference.');




    set_param(cs.getConfigSetSource,'CoverageDialogOpen','on');

    covHook=coder.coverage.BuildHook.getBuildHookForClass(cs,toolClass);

    assert(~isempty(covHook),'A code coverage hook must be defined.');

    settings=coder.coverage.CodeCoverageHelper.getCovSettingsFromHook(covHook);

    assert(strcmp(settings.CoverageTool,toolName),...
    'The name of the code  coverage tool must remain consistent');

    if strcmp(settings.TopModelCoverage,'on')
        h.IncludeTopModel=true;
    else
        h.IncludeTopModel=false;
    end
    if strcmp(settings.ReferencedModelCoverage,'on')
        h.IncludeReferencedModels=true;
    else
        h.IncludeReferencedModels=false;
    end


    set_param(model,'RTWCodeCoverage',h);
