function onHardwareSelect(hCS)




    try
        if~codertarget.utils.isMdlConfiguredForSoC(hCS)&&...
            ~strcmpi(get_param(hCS,'SolverType'),'Fixed-step')

            return;
        end
        if~codertarget.utils.isMdlConfiguredForSoC(hCS)&&...
            strcmpi(get_param(hCS,'SampleTimeConstraint'),'STIndependent')

            return;
        end



        hCS.setPropEnabled('PositivePriorityOrder',true);
        set_param(hCS,'PositivePriorityOrder','on');
        set_param(hCS,'EnableMultiTasking','on');
        set_param(hCS,'ModelReferenceNumInstancesAllowed','Single');
    catch ME
        warning(ME.identifier,'%s',ME.message);
    end

end
