



function metricCheckInfo=getMetricChecks()

    metricCheckInfo=struct(...
    'CheckID',[],...
    'MetricID',[],...
    'MessagePrefix',[],...
    'CSHParameters',[],...
    'DefaultThreshold',[],...
    'ThresholdType',[]);

    idx=1;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.SimulinkBlockCount';
    metricCheckInfo(idx).MetricID='mathworks.metrics.SimulinkBlockCount';
    metricCheckInfo(idx).MessagePrefix='SimulinkBlockCount';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='SimulinkBlockCount';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;

    idx=2;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.CyclomaticComplexity';
    metricCheckInfo(idx).MetricID='mathworks.metrics.CyclomaticComplexity';
    metricCheckInfo(idx).MessagePrefix='CyclomaticComplexity';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='CyclomaticComplexity';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;

    idx=3;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.SubSystemCount';
    metricCheckInfo(idx).MetricID='mathworks.metrics.SubSystemCount';
    metricCheckInfo(idx).MessagePrefix='SubSystemCount';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='SubSystemCount';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;

    idx=4;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.LibraryLinkCount';
    metricCheckInfo(idx).MetricID='mathworks.metrics.LibraryLinkCount';
    metricCheckInfo(idx).MessagePrefix='LibraryLinkCount';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='LibraryLinkCount';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;

    idx=5;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.MatlabLOCCount';
    metricCheckInfo(idx).MetricID='mathworks.metrics.MatlabLOCCount';
    metricCheckInfo(idx).MessagePrefix='MatlabLOCCount';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='MatlabLOCCount';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;

    idx=6;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.StateflowChartObjectCount';
    metricCheckInfo(idx).MetricID='mathworks.metrics.StateflowChartObjectCount';
    metricCheckInfo(idx).MessagePrefix='StateflowChartObjectCount';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='StateflowObjectCount';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;

    idx=7;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.StateflowLOCCount';
    metricCheckInfo(idx).MetricID='mathworks.metrics.StateflowLOCCount';
    metricCheckInfo(idx).MessagePrefix='StateflowLOCCount';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='StateflowLOCCount';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;

    idx=8;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.DescriptiveBlockNames';
    metricCheckInfo(idx).MetricID='mathworks.metrics.DescriptiveBlockNames';
    metricCheckInfo(idx).MessagePrefix='DescriptiveBlockNames';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='DescriptiveBlockNames';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;

    idx=9;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.LayerSeparation';
    metricCheckInfo(idx).MetricID='mathworks.metrics.LayerSeparation';
    metricCheckInfo(idx).MessagePrefix='LayerSeparation';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='LayerSeparation';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;

    idx=10;
    metricCheckInfo(idx).CheckID='mathworks.metricchecks.SubSystemDepth';
    metricCheckInfo(idx).MetricID='mathworks.metrics.SubSystemDepth';
    metricCheckInfo(idx).MessagePrefix='SubSystemDepth';
    metricCheckInfo(idx).CSHParameters.MapKey='ma.metricchecks';
    metricCheckInfo(idx).CSHParameters.TopicID='SubSystemDepth';
    metricCheckInfo(idx).DefaultThreshold=Inf;
    metricCheckInfo(idx).ThresholdType=2;
...
...
...
...
...
...
...
...
...
...
...
end