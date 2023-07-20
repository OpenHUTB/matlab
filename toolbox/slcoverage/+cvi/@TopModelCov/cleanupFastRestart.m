function cleanupFastRestart(modelH)






    try

        fastRestartEnd=(get_param(modelH,'InteractiveSimInterfaceExecutionStatus')==2);
        if(~fastRestartEnd)
            return;
        end



        coveng=cvi.TopModelCov.getInstance(modelH);
        if~isempty(coveng)&&~isempty(coveng.restorableParams)
            prevDirty=get_param(coveng.topModelH,'Dirty');
            cs=getActiveConfigSet(coveng.topModelH);
            params=fieldnames(coveng.restorableParams);
            for i=1:length(params)
                configset.internal.setParam(cs,params{i},coveng.restorableParams.(params{i}),'Apply','off');
            end
            set_param(coveng.topModelH,'Dirty',prevDirty);
        end

    catch MEx
        rethrow(MEx);
    end


