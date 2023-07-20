function updateDeps=sldvCallback(cs,msg)









    updateDeps=false;

    if isa(cs,'Simulink.ConfigSet')
        sldv=cs.getComponent('Design Verifier');
    else
        sldv=cs;
        if~isempty(cs.getConfigSet)
            cs=cs.getConfigSet;
        end
    end

    dlg=msg.dialog;
    tag=msg.data.getTag(cs);
    action=[];
    action.enableApply=ismember(msg.name,{...
    'DVParametersConfigFileBrowse',...
    'sldvParamConfigRefreshModel',...
    'sldvParamConfigImport',...
    'sldvParamConfigClear',...
    'sldvParamConfigSelectAll',...
    'sldvParamConfigDeselectAll',...
    'DVExistingTestFileBrowse',...
    'DVCoverageDataFileBrowse',...
    'DVCovFilterFileBrowse',...
    'DVAnalysisFilterFileBrowse',...
    });
    if isfield(msg,'table')&&isfield(msg.table,'select')

        action.selectedTableRow=msg.table.select;
    else
        action.selectedTableRow=[];
    end

    sldv.dialogCallback(dlg,tag,jsonencode(action));
