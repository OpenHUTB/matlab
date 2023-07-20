function taskCellArray=defineMetricByTaskGroup()

    taskCellArray={};

    mdladvRoot=ModelAdvisor.Root;


    metricGroup=ModelAdvisor.FactoryGroup('ModelMetrics');
    metricGroup.DisplayName=DAStudio.message('ModelAdvisor:metricchecks:MetricByTaskGroup');
    metricGroup.Description=DAStudio.message('ModelAdvisor:metricchecks:MetricByTaskGroupDesc');


    sizeGroup=ModelAdvisor.FactoryGroup('ModelMetrics:Count');
    sizeGroup.DisplayName=DAStudio.message('ModelAdvisor:metricchecks:SizeMetricsGroup');
    sizeGroup.Description=DAStudio.message('ModelAdvisor:metricchecks:SizeMetricsGroupDesc');

    sizeGroup.addCheck('mathworks.metricchecks.SimulinkBlockCount');
    sizeGroup.addCheck('mathworks.metricchecks.SubSystemCount');
    sizeGroup.addCheck('mathworks.metricchecks.LibraryLinkCount');
    sizeGroup.addCheck('mathworks.metricchecks.MatlabLOCCount');
    sizeGroup.addCheck('mathworks.metricchecks.StateflowChartObjectCount');
    sizeGroup.addCheck('mathworks.metricchecks.StateflowLOCCount');
    sizeGroup.addCheck('mathworks.metricchecks.SubSystemDepth');
    metricGroup.addFactoryGroup(sizeGroup);



    complexGroup=ModelAdvisor.FactoryGroup('ModelMetrics:Complexity');
    complexGroup.DisplayName=DAStudio.message('ModelAdvisor:metricchecks:ComplexityMetricsGroup');
    complexGroup.Description=DAStudio.message('ModelAdvisor:metricchecks:ComplexityMetricsGroupDesc');

    complexGroup.addCheck('mathworks.metricchecks.CyclomaticComplexity');
    metricGroup.addFactoryGroup(complexGroup);



    readGroup=ModelAdvisor.FactoryGroup('ModelMetrics:Readability');
    readGroup.DisplayName=DAStudio.message('ModelAdvisor:metricchecks:ReadabilityMetricsGroup');
    readGroup.Description=DAStudio.message('ModelAdvisor:metricchecks:ReadabilityMetricsGroupDesc');

    readGroup.addCheck('mathworks.metricchecks.DescriptiveBlockNames');
    readGroup.addCheck('mathworks.metricchecks.LayerSeparation');

    metricGroup.addFactoryGroup(readGroup);

    mdladvRoot.publish(readGroup);
    mdladvRoot.publish(sizeGroup);
    mdladvRoot.publish(complexGroup);
    mdladvRoot.publish(metricGroup);
end