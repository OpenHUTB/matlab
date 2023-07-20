


function targetName=getTargetForCurrentSimulation(mdl)
    targetName='';
    try

        stf=get_param(mdl,'SystemTargetFile');
        if~strcmpi(stf,'slrealtime.tlc')
            return
        end


        ac=eval('slrealtime.internal.ToolStripContextMgr.getContext(mdl)');
        if~isempty(ac)
            targetName=ac.selectedTarget;
        end

    catch me %#ok<NASGU>

        targetName='';
    end
end
