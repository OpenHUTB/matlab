function dispECBWarning(blk)







    refBlk=get_param(blk,'ReferenceBlock');
    if~strcmp(refBlk,['simulink_need_slupdate/Environment',newline,'Controller'])
        return;
    end

    warnExcep=MSLException([],message('Simulink:VariantAdvisorChecks:ObsoleteSlEnvironmentControllerBlockCauseWithArg',blk));
    sldiagviewer.reportWarning(warnExcep);
end
