function[status,errMsg]=postApplyCallback(hSrc,~)






    status=true;
    errMsg='';

    cs=hSrc.ParentHSrc.getConfigSet;

    settings=get_param(cs,'CodeCoverageSettings');

    if hSrc.IncludeTopModel
        settings.TopModelCoverage='on';
    else
        settings.TopModelCoverage='off';
    end
    if hSrc.IncludeReferencedModels
        settings.ReferencedModelCoverage='on';
    else
        settings.ReferencedModelCoverage='off';
    end

    assert(strcmp(settings.CoverageTool,hSrc.ToolName),...
    'Coverage settings will be applied for the selected tool class.')

    set_param(cs,'CodeCoverageSettings',settings);

