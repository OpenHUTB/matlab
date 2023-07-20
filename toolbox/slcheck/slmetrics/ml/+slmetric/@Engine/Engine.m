
classdef Engine<handle

    properties(Dependent)
AnalysisRoot
        AnalyzeLibraries,
ModelReferencesSimulationMode
    end

    properties(Dependent,Hidden)
        AnalyzeModelReferences;
    end

    properties(Hidden,Access=private)
engineHandle
    end

    methods
        function obj=Engine()
            warning(message('slcheck:metricengine:MetricsDashboardToBeRemoved'));
            obj.engineHandle=slmetric.internal.Engine();
        end

        function value=get.AnalysisRoot(obj)
            value=obj.engineHandle.AnalysisRoot;
        end

        function value=get.AnalyzeModelReferences(obj)
            if(strcmp(obj.engineHandle.ModelReferencesSimulationMode,"None"))
                value=0;
            else
                value=1;
            end
            MSLDiagnostic('slcheck:metricengine:AnalyzeModelReferencesDeprecate').reportAsWarning
        end

        function set.AnalyzeModelReferences(obj,value)

            if(value==0)
                obj.engineHandle.ModelReferencesSimulationMode="None";
            else
                obj.engineHandle.ModelReferencesSimulationMode="AllModes";
            end

            MSLDiagnostic('slcheck:metricengine:AnalyzeModelReferencesDeprecate').reportAsWarning;
        end

        function value=get.AnalyzeLibraries(obj)
            value=obj.engineHandle.AnalyzeLibraries;
        end

        function set.AnalyzeLibraries(obj,value)
            obj.engineHandle.AnalyzeLibraries=value;
        end

        function value=get.ModelReferencesSimulationMode(obj)
            value=obj.engineHandle.ModelReferencesSimulationMode;
        end

        function set.ModelReferencesSimulationMode(obj,value)
            if((strcmpi(value,"None")==0)&&...
                (strcmpi(value,"NormalModeOnly")==0)&&...
                (strcmpi(value,"AllModes")==0))
                DAStudio.error('slcheck:mmt:InvalidModelReferencesSimulationModeInput');
            end



            if(strcmpi(value,"None"))
                obj.engineHandle.ModelReferencesSimulationMode="None";
            elseif(strcmpi(value,"NormalModeOnly"))
                obj.engineHandle.ModelReferencesSimulationMode="NormalModeOnly";
            elseif(strcmpi(value,"AllModes"))
                obj.engineHandle.ModelReferencesSimulationMode="AllModes";
            end
        end

        function out=getConfiguration(obj)
            out=obj.engineHandle.getConfiguration();
        end

        function out=getThresholds(obj,varargin)
            if(nargin==1)
                out=obj.engineHandle.getThresholds();
            else
                out=obj.engineHandle.getThresholds(varargin{1});
            end
        end

        function setAnalysisRoot(obj,varargin)
            try
                if(nargin==3&&~strcmpi(varargin{1},'root'))
                    obj.engineHandle.setAnalysisRoot(varargin{1},varargin{2});
                else

                    p=inputParser();
                    paramName='root';
                    default='';
                    validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                    addParameter(p,paramName,default,validationFcn);

                    paramName='roottype';
                    default='Model';
                    validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                    addParameter(p,paramName,default,validationFcn);

                    p.parse(varargin{:});
                    compType='';
                    if(strcmpi(p.Results.roottype,'model'))
                        compType=Advisor.component.Types.Model;

                    elseif(strcmpi(p.Results.roottype,'subsystem'))
                        compType=Advisor.component.Types.SubSystem;

                    end
                    obj.engineHandle.setAnalysisRoot(p.Results.root,compType);

                end

            catch err
                throwAsCaller(err);
            end
        end

        function r=getMetrics(obj,varargin)

            try

                if((nargin==3)&&(iscellstr(varargin{1})&&iscellstr(varargin{2})))

                    r=obj.engineHandle.getMetrics(varargin{1},varargin{2});

                else

                    p=inputParser();

                    paramName='metric';
                    default={};
                    validationFcn=@(x)assert(ischar(x)||iscellstr(x)||isstring(x));
                    addOptional(p,paramName,default,validationFcn);

                    paramName='lastruns';
                    default=1;
                    validationFcn=@(x)assert(isnumeric(x));
                    addParameter(p,paramName,default,validationFcn);

                    paramName='startTime';
                    default=datetime;
                    validationFcn=@(x)assert(isdatetime(x));
                    addParameter(p,paramName,default,validationFcn);

                    paramName='endTime';
                    default=datetime;
                    validationFcn=@(x)assert(isdatetime(x));
                    addParameter(p,paramName,default,validationFcn);

                    paramName='aggregationdepth';
                    default='all';
                    validationFcn=@(x)assert(ischar(x)||isstring(x));
                    addParameter(p,paramName,default,validationFcn);


                    p.parse(varargin{:});


                    switch nargin

                    case 1
                        r=obj.engineHandle.getMetrics();

                    case 2
                        r=obj.engineHandle.getMetrics(p.Results.metric);

                    case 3
                        r=obj.engineHandle.getMetrics(p.Results.metric,'aggregationdepth',p.Results.aggregationdepth);

                    case 4
                        if((ischar(varargin{1})||iscellstr(varargin{1}))&&isnumeric(varargin{3}))
                            r=obj.engineHandle.getMetrics(p.Results.metric,p.Results.lastruns);
                        else
                            r=obj.engineHandle.getMetrics(p.Results.metric,'aggregationdepth',p.Results.aggregationdepth);
                        end

                    case 5
                        r=obj.engineHandle.getMetrics(p.Results.metric,p.Results.compIds,'aggregationdepth',p.Results.aggregationdepth);

                    case 6
                        r=obj.engineHandle.getMetrics(p.Results.metric,p.Results.startTime,p.Results.endTime);

                    otherwise

                    end
                end

            catch err
                throwAsCaller(err);
            end
        end

        function execute(obj,varargin)
            temp=varargin;
            if nargin==3&&strcmpi(varargin{1},'CompiledMetrics')
                temp=cell(1,3);
                temp{1}={};
                temp{2}=varargin{1};
                temp{3}=varargin{2};

            end

            ip=inputParser();

            validationFcn=@(x)ischar(x)||iscellstr(x)||isstring(x);
            ip.addOptional('metric',{},validationFcn);

            validationFcn2=@(x)(ischar(x)||isstring(x))&&any(strcmpi(x,{'all','none'}));
            ip.addParameter('CompiledMetrics','all',validationFcn2);
            parse(ip,temp{:});

            if~isempty(obj.engineHandle.AnalysisRoot)

                ar=obj.engineHandle.getAnalysisRootObject();
                type=char(ar.ComponentType);

                if~strcmp(type,'Model')

                    type='Subsystem';
                end

                sessionID=slmetric.internal.getExistingSessionIDForDataSet(...
                ar.Name,type);

                if~isempty(sessionID)

                    MSLDiagnostic('slcheck:metricengine:APIDashboardConflict').reportAsWarning;
                    m=slmetric.internal.mmt.Manager.get();
                    explorer=m.getExplorerByID(sessionID);
                    explorer.close();
                end
            end


            if isstring(ip.Results.metric)
                metric=cellstr(ip.Results.metric);
            elseif ischar(ip.Results.metric)
                metric={ip.Results.metric};
            else
                metric=ip.Results.metric;
            end

            try
                if(strcmpi(ip.Results.CompiledMetrics,'all'))
                    obj.engineHandle.execute(metric,true);
                else
                    obj.engineHandle.execute(metric,false);
                end
            catch err
                throwAsCaller(err);
            end
        end

        function r=getThresholdViolations(obj,varargin)
            try
                if(nargin==1)
                    r=obj.engineHandle.getThresholdViolations();
                else
                    p=inputParser();
                    paramName='metricID';
                    validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                    addRequired(p,paramName,validationFcn);
                    p.parse(varargin{:});

                    r=obj.engineHandle.getThresholdViolations(p.Results.metricID);
                end
            catch err
                throwAsCaller(err);
            end
        end

        function out=getMetricThresholdCategory(obj,metricID)
            out=obj.engineHandle.getMetricThresholdCategory(metricID);
        end

        function r=getMetricDistribution(obj,varargin)
            try
                p=inputParser();
                paramName='metricID';
                validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                addRequired(p,paramName,validationFcn);
                p.parse(varargin{:});

                r=obj.engineHandle.getMetricDistribution(p.Results.metricID);

            catch err
                throwAsCaller(err);
            end
        end

        function r=getAnalysisRootMetric(obj,varargin)
            try
                p=inputParser();
                paramName='metricID';
                validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                addRequired(p,paramName,validationFcn);
                p.parse(varargin{:});

                r=obj.engineHandle.getAnalysisRootMetric(p.Results.metricID);
            catch err
                throwAsCaller(err);
            end
        end

        function exportMetrics(obj,varargin)
            try
                p=inputParser();
                paramName='filename';
                validationFcn=@(x)assert(ischar(x)||isstring(x));
                addRequired(p,paramName,validationFcn);

                paramName='filepath';
                default=pwd();
                validationFcn=@(x)assert(ischar(x)||isstring(x));
                addOptional(p,paramName,default,validationFcn);

                p.parse(varargin{:});

                obj.engineHandle.exportMetrics(p.Results.filename,p.Results.filepath);

            catch err
                throwAsCaller(err);
            end
        end

        function r=getErrorLog(obj)
            try
                r=obj.engineHandle.getErrorLog();
            catch err
                throwAsCaller(err);
            end
        end

        function r=getStatistics(obj,varargin)
            try
                p=inputParser();
                paramName='metricID';
                validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                addRequired(p,paramName,validationFcn);

                p.parse(varargin{:});

                r=obj.engineHandle.getStatistics(p.Results.metricID);


            catch err
                throwAsCaller(err);
            end
        end

        function r=getMetricMetaInformation(obj,varargin)
            try
                p=inputParser();
                paramName='MetricId';
                validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                addRequired(p,paramName,validationFcn);

                p.parse(varargin{:});

                switch nargin

                case 2
                    r=obj.engineHandle.getMetricMetaInformation(p.Results.MetricId);
                end
            catch err
                throwAsCaller(err);
            end
        end


        function delete(obj)
            delete(obj.engineHandle);
        end

        function openResult(this,varargin)
            try
                p=inputParser();
                paramName='MetricID';
                validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                addRequired(p,paramName,validationFcn);

                paramName='ResultID';
                validationFcn=@(x)assert(isa(x,'uint64'));
                addRequired(p,paramName,validationFcn);

                p.parse(varargin{:});

                this.engineHandle.openResult(...
                p.Results.MetricID,...
                p.Results.ResultID);
            catch err
                throwAsCaller(err);
            end
        end

        function openResultDetail(this,varargin)
            try
                p=inputParser();
                paramName='MetricID';
                validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                addRequired(p,paramName,validationFcn);

                paramName='ResultID';
                validationFcn=@(x)assert(isa(x,'uint64'));
                addRequired(p,paramName,validationFcn);

                paramName='DetailID';
                validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                addRequired(p,paramName,validationFcn);

                p.parse(varargin{:});

                this.engineHandle.openResultDetail(...
                p.Results.MetricID,...
                p.Results.ResultID,...
                p.Results.DetailID);
            catch err
                throwAsCaller(err);
            end
        end
    end

    methods(Hidden)
        function openSourceTool(obj,metricID)
            obj.engineHandle.openSourceTool(metricID);
        end

        function openDataSet(obj,varargin)
            try
                obj.engineHandle.openDataSet(varargin{1});
            catch err
                throwAsCaller(err);
            end
        end

        function r=deleteMetricsHistory(obj,varargin)

            try

                p=inputParser();
                paramName='startTime';
                default='';
                validationFcn=@(x)assert(isdatetime(x));
                addParameter(p,paramName,default,validationFcn);

                paramName='endTime';
                default='';
                validationFcn=@(x)assert(isdatetime(x));
                addParameter(p,paramName,default,validationFcn);


                p.parse(varargin{:});


                switch nargin

                case 5
                    r=obj.engineHandle.deleteMetricsHistory(p.Results.startTime,p.Results.endTime);


                otherwise

                end

            catch err
                throwAsCaller(err);
            end
        end

        function r=getAvailableMetricTimestamps(obj,varargin)
            try
                p=inputParser();
                paramName='metricID';
                validationFcn=@(x)assert(ischar(x)||isstring(x)||iscellstr(x));
                addRequired(p,paramName,validationFcn);

                p.parse(varargin{:});

                switch nargin

                case 2
                    r=obj.engineHandle.getAvailableMetricTimestamps(p.Results.metricID);
                end

            catch err
                throwAsCaller(err);
            end
        end

        function setSharedCompileService(obj,service)
            try
                obj.engineHandle.setSharedCompileService(service);
            catch err
                throwAsCaller(err);
            end
        end

        function aggregatedDataStruct=getAggregatedResultDetails(obj,metricID,mode)
            try
                aggregatedDataStruct=obj.engineHandle.getAggregatedResultDetails(metricID,mode);
            catch err
                throwAsCaller(err);
            end
        end
    end
end
