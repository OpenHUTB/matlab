function SFDiagnostics(obj)




    if isR2010aOrEarlier(obj.ver)


        diagnostics=sfprivate('getDiagnosticsList')';
        obj.appendRules(strcat('<Simulink.DebuggingCC<',diagnostics,':remove>>'));
        return;
    end

    if isR2012aOrEarlier(obj.ver)
        obj.appendRule('<Simulink.DebuggingCC<SFUndirectedBroadcastEventsDiag:remove>>');
        obj.appendRule('<Simulink.DebuggingCC<SFTransitionActionBeforeConditionDiag:remove>>');
    end

    if isR2014bOrEarlier(obj.ver)
        obj.appendRule('<Simulink.DebuggingCC<SFOutputUsedAsStateInMooreChartDiag:remove>>');
    end

    if isR2016aOrEarlier(obj.ver)
        obj.appendRule('<Simulink.DebuggingCC<SFTemporalDelaySmallerThanSampleTimeDiag:remove>>');
        obj.appendRule('<Simulink.DebuggingCC<SFSelfTransitionDiag:remove>>');
        obj.appendRule('<Simulink.DebuggingCC<SFExecutionAtInitializationDiag:remove>>');
        obj.appendRule('<Simulink.DebuggingCC<SFMachineParentedDataDiag:remove>>');


        unreachableParamExists=~isempty(find(strcmp(fieldnames(get_param(obj.origModelName,'ObjectParameters')),'SFUnreachableExecutionPathDiag'),1));
        if unreachableParamExists
            obj.appendRule('<Simulink.DebuggingCC<SFUnreachableExecutionPathDiag:rename SFUnconditionalTransitionShadowingDiag>>');
            severity=get_param(obj.origModelName,'SFUnreachableExecutionPathDiag');
            obj.appendRule(['<Simulink.DebuggingCC<SFUnconditionalTransitionShadowingDiag:repval "',severity,'">>']);
        end
    end
end
