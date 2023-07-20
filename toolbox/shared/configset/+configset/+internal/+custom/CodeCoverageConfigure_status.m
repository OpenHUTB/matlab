function[status,dscr]=CodeCoverageConfigure_status(cs,~)


    dscr='';

    if isempty(cs.getConfigSet)
        codeCoverageTool='';
    else
        codeCovSettings=get_param(cs,'CodeCoverageSettings');
        codeCoverageTool=codeCovSettings.CoverageTool;
    end

    try
        isSlCovVisible=cs.getComponent('Simulink Coverage').isVisible;
    catch
        isSlCovVisible=false;
    end

    if strcmp(get_param(cs,'CoverageDialogOpen'),'on')||...
        (~isSlCovVisible&&strcmp(codeCoverageTool,'None'))||...
        ~cs.isActive||cs.isObjectLocked
        status=configset.internal.data.ParamStatus.ReadOnly;
    else
        status=configset.internal.data.ParamStatus.Normal;
    end
