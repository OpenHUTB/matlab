function cleanupFcn=mpt_ecoder_hook(hook,modelName,lAnchorFolder,lModelReferenceTargetType)





    cleanupFcn=@()[];

    switch hook
    case 'entry'

        rtwprivate('ec_set_replacement_flag',modelName);


        [repStatus,errMsg]=ec_replacetype_consistency_check(modelName);
        if repStatus==0
            DAStudio.error('RTW:mpt:MPTecHookReplaceTypeConsistencyCheckErr',errMsg);
        end


        packageCSCDef=ec_record_csc_def;


        ec_apply_tune_display_rules(modelName,packageCSCDef);


        ec_apply_name_rules(modelName,packageCSCDef);



        cleanupFcn=ec_scope_listener_attach(modelName);

    case 'before_tlc'
        templateList=[];
        init_mpm_from_rtw(modelName,templateList);

    case 'after_tlc'
        ec_deapply_name_rules(modelName);
        ec_deapply_tune_display_rules(modelName);


        if rtwprivate('rtwattic','AtticData','isReplacementOn')
            ec_employ_replacement(modelName,lAnchorFolder,lModelReferenceTargetType);
        end
    case{'exit','error'}
        ec_deapply_name_rules(modelName);
        ec_deapply_tune_display_rules(modelName);
    end


