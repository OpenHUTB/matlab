function tbl=createActiveVariableTable(KS,type)





    switch type
    case 'initialguesses'
        [ids,jointTypes,jointBlockPaths,baseFrames,folFrames,units]=KS.mSystem.initialGuessVariables;
    case 'targets'
        [ids,jointTypes,jointBlockPaths,baseFrames,folFrames,units]=KS.mSystem.targetVariables;
    case 'outputs'
        [ids,jointTypes,jointBlockPaths,baseFrames,folFrames,units]=KS.mSystem.outputVariables;
    otherwise
        assert(false,'invalid active variable type')
    end

    jt=table(string(jointTypes),string(jointBlockPaths));
    jt.Properties.VariableNames={...
    pm_message('sm:mli:kinematicsSolver:tableHeaders:JointType'),...
    pm_message('sm:mli:kinematicsSolver:tableHeaders:BlockPath')};
    ft=table(string(baseFrames),string(folFrames));
    ft.Properties.VariableNames={...
    pm_message('sm:mli:kinematicsSolver:tableHeaders:Base'),...
    pm_message('sm:mli:kinematicsSolver:tableHeaders:Follower')};
    tbl=table(string(ids),jt,ft,string(units));
    tbl.Properties.VariableNames={...
    pm_message('sm:mli:kinematicsSolver:tableHeaders:Id'),...
    pm_message('sm:mli:kinematicsSolver:tableHeaders:JointVariableInfo'),...
    pm_message('sm:mli:kinematicsSolver:tableHeaders:FrameVariableInfo'),...
    pm_message('sm:mli:kinematicsSolver:tableHeaders:Unit')};
