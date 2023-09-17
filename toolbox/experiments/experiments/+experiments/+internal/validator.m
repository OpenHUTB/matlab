classdef validator

    methods(Static)
        function TF=validateInfo(emInterface,val,infoName)
            TF=true;
            if ischar(val)
                val=string(val);
            end
            if~isscalar(val)
                ME=MException(message('experiments:customExperiment:InfoNotScalar',infoName));
                throwAsCaller(ME);
            end
            if isfi(val)
                ME=MException(message('experiments:customExperiment:InfoErrorFixPointType',infoName));
                throwAsCaller(ME);
            end
            if iscell(val)||~(isstring(val)||isnumeric(val)||isenum(val)||islogical(val))
                ME=MException(message('experiments:customExperiment:InfoErrorType',infoName));
                throwAsCaller(ME);
            end
            outputClass=class(val);
            if~emInterface.InfoClassMap.isKey(infoName)
                emInterface.InfoClassMap(infoName)=outputClass;
            end
            if~strcmp(emInterface.InfoClassMap(infoName),outputClass)
                ME=MException(message('experiments:customExperiment:InfoErrorTypeMismatch',...
                infoName,emInterface.InfoClassMap(infoName),outputClass));
                throwAsCaller(ME);
            end
        end

        function TF=isAdouble(val)
            TF=isscalar(val)&&...
            ~isstruct(val)&&...
            ~iscell(val)&&...
            ~issparse(val)&&...
            isa(double(val),'double')&&...
            isreal(val);
        end

        function TF=validateMetric(val,field)
            TF=experiments.internal.validator.isAdouble(val);
            if~TF
                ME=MException(message('experiments:customExperiment:MetricNotScalar',field));
                throwAsCaller(ME);
            end
        end

        function TF=validateIndex(val)
            TF=experiments.internal.validator.isAdouble(val);
            if~TF
                ME=MException(message('experiments:customExperiment:IndexNotScalar','Index'));
                throwAsCaller(ME);
            end
        end

        function mustBeAMetric(emInterface,values)
            if~isempty(setdiff(values,emInterface.Metrics))
                ME=MException(message('experiments:customExperiment:MetricNotDefined','metrics'));
                throwAsCaller(ME);
            end
        end

        function mustHaveUniqueValues(value)
            if numel(unique(value))~=numel(value)
                ME=MException(message('experiments:customExperiment:MustHaveUniqueValues'));
                throwAsCaller(ME);
            end
        end

        function p=createInputParser(mthname)
            p=inputParser();
            p.CaseSensitive=true;
            p.FunctionName=mthname;
            p.PartialMatching=false;
            p.KeepUnmatched=true;
        end

        function throwIfInputHasUndefinedName(p,name)
            fnames=fieldnames(p.Unmatched);
            if~isempty(fnames)
                ME=MException(message('experiments:customExperiment:UndefinedName',fnames{1},name));
                throwAsCaller(ME);
            end
        end

        function info=parseInfo(eminterface,mthname,varargin)
            p=experiments.internal.validator.createInputParser(mthname);
            for field=eminterface.Info
                p.addParameter(field,'',@(val)experiments.internal.validator.validateInfo(eminterface,val,char(field)));
            end
            try
                p.parse(varargin{:});
            catch ME
                throwAsCaller(ME);
            end
            experiments.internal.validator.throwIfInputHasUndefinedName(p,'Info');
            info=rmfield(p.Results,p.UsingDefaults);
        end


        function[index,metrics]=parseMetrics(eminterface,mthname,index,varargin)
            p=experiments.internal.validator.createInputParser(mthname);
            addRequired(p,'index',@(val)experiments.internal.validator.validateIndex(val));
            for field=eminterface.Metrics
                p.addParameter(field,'',@(val)experiments.internal.validator.validateMetric(val,field));
            end
            try
                p.parse(index,varargin{:});
            catch ME
                throwAsCaller(ME);
            end
            experiments.internal.validator.throwIfInputHasUndefinedName(p,'Metrics');
            fnames=setdiff(eminterface.Metrics,p.UsingDefaults);
            index=double(index);
            metrics=struct();
            for field=fnames
                metrics.(field)=double(p.Results.(field));
            end
        end
    end
end
