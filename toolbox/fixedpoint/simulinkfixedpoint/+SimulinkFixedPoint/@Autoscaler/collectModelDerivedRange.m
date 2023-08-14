function collectModelDerivedRange(subsysObj,selectedRunName)





    if isa(subsysObj,'Simulink.SubSystem')
        mdl=bdroot(subsysObj.getFullName);
    else
        mdl=subsysObj.getFullName;
    end

    mdlRefTargetType=get_param(mdl,'ModelReferenceTargetType');
    targetName=slprivate('perf_logger_target_resolution',mdlRefTargetType,mdl,false,false);

    PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Collect Model Derived Range',...
    true);

    cleanupObj=onCleanup(@()PerfTools.Tracer.logSimulinkData('Range Analysis For Autoscaling',...
    mdl,...
    targetName,...
    'Collect Model Derived Range',...
    false));

    if isa(subsysObj,'Simulink.SubSystem')


        if strcmpi(subsysObj.TreatAsAtomicUnit,'off')
            ME=fxptui.FPTMException('SimulinkFixedPoint:autoscaling:derivedFailNotAtomic',...
            DAStudio.message('SimulinkFixedPoint:autoscaling:derivedFailNotAtomic'),...
            get_param(subsysObj.getFullName,'Handle'));
            throw(ME);
        elseif strcmpi(subsysObj.IsSimulinkFunction,'on')
            ME=fxptui.FPTMException('SimulinkFixedPoint:autoscaling:derivedFailSLFunction',...
            DAStudio.message('SimulinkFixedPoint:autoscaling:derivedFailSLFunction'),...
            get_param(subsysObj.getFullName,'Handle'));
            throw(ME);
        end
    end

    rangeAnalyzer=Simulink.FixedPointAutoscaler.RangeAnalyzer(subsysObj.getFullName);
    rangeAnalyzer.setRunName(selectedRunName);
    rangeAnalyzer.analyze;


