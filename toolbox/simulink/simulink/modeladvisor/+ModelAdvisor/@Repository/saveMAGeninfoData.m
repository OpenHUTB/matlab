function saveMAGeninfoData(obj,varargin)
    PerfTools.Tracer.logMATLABData('MAGroup','Save MA Geninfo Data',true);

    obj.overwriteLatestData('geninfo','fromTaskAdvisorNode',varargin{1},'generateTime',varargin{2},'passCt',varargin{3},...
    'failCt',varargin{4},'warnCt',varargin{5},'nrunCt',varargin{6},'allCt',varargin{7},'reportName','report.html');

    PerfTools.Tracer.logMATLABData('MAGroup','Save MA Geninfo Data',false);
end
