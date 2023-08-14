function defineMetricChecks()

    mdladvRoot=ModelAdvisor.Root;

    byProductGroup=['Simulink Check|'...
    ,DAStudio.message('ModelAdvisor:metricchecks:MetricByTaskGroup')];

    checkInfo=getMetricChecks();

    for n=1:length(checkInfo)
        rec=ModelAdvisor.check.metriccheck.MetricCheck(checkInfo(n).CheckID);
        rec.setCheckInfo(checkInfo(n));
        mdladvRoot.publish(rec,byProductGroup);
    end
end