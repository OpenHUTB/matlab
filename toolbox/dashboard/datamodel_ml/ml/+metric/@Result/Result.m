classdef Result<handle


    properties(Dependent)
        UserData;
        Value;
    end

    properties(Hidden)
        SourceResults;
    end

    properties(Hidden,Dependent,SetAccess=private)
        ID;
        ScopeUuid;
        CollectionScope;
    end

    properties(Dependent,SetAccess=private)
        MetricID;
        Artifacts;
        Scope;
    end


    properties(Hidden,Access=private)
        mf_model;
        ResultData;
    end

    properties(Dependent,Hidden)
        TaskEvidenceUuid;
    end

    methods(Hidden)
        function mfResult=getMfResult(obj)
            mfResult=obj.ResultData;
        end
        function setMfResult(obj,value)
            obj.ResultData=value;
        end
    end

    methods
        function obj=Result(varargin)
            if(nargin==0)
                obj.mf_model=mf.zero.Model;
                obj.ResultData=metric.data.Result(obj.mf_model);

            elseif isa(varargin{1},'metric.data.Result')
                obj.mf_model=mf.zero.getModel(varargin{1});
                obj.ResultData=varargin{1};

            else
                obj.mf_model=varargin{1};
                obj.ResultData=metric.data.Result(obj.mf_model);

            end
        end

        function value=get.ID(obj)
            value=obj.ResultData.UUID;
        end

        function value=get.TaskEvidenceUuid(obj)
            value=obj.ResultData.TaskEvidenceUuid;
        end

        function set.TaskEvidenceUuid(obj,value)
            obj.ResultData.TaskEvidenceUuid=value;
        end

        function value=get.ScopeUuid(obj)
            value=obj.ResultData.ScopeUuid;
        end

        function value=get.MetricID(obj)
            value=obj.ResultData.MetricID;
        end

        function set.Value(obj,value)


            metricValue=metric.internal.convertToMetricDynamicValue(obj.mf_model,value);
            txn=obj.mf_model.beginTransaction;
            obj.ResultData.Value=metricValue;
            txn.commit;
        end

        function value=get.Value(obj)
            mfValue=obj.ResultData.Value;
            value=metric.internal.convertFromMetricDynamicValue(mfValue);
        end


        function set.UserData(obj,value)
            txn=obj.mf_model.beginTransaction;
            obj.ResultData.UserData=value;
            txn.commit;
        end

        function value=get.UserData(obj)
            value=obj.ResultData.UserData;
        end

        function value=get.Artifacts(obj)
            value=convertArtifactReferencesToStruct(obj,...
            obj.ResultData.Artifacts.toArray());
        end

        function value=get.Scope(obj)
            ref=obj.mf_model.findElement(obj.ResultData.ScopeUuid);
            if~isempty(ref)
                value=convertArtifactReferencesToStruct(obj,ref);
            else
                value=[];
            end
        end



        function value=get.CollectionScope(obj)
            value=obj.Scope;
        end

        function set.SourceResults(obj,value)

            if~iscell(value)
                value={value};
            end

            txn=obj.mf_model.beginTransaction;
            obj.ResultData.SourceResults.clear();
            for i=1:length(value)

                obj.ResultData.SourceResults.insertAt(value{i},i);
            end
            txn.commit;
        end

        function value=get.SourceResults(obj)

            value=obj.ResultData.SourceResults.toArray();
        end
    end

    methods(Access=private)
        function value=convertArtifactReferencesToStruct(~,refs)
            value=struct('UUID',{},'Name',{},'Type',{},...
            'ParentUUID',{},'ParentName',{},'ParentType',{});
            for n=1:numel(refs)
                value(end+1).UUID=refs(n).ArtifactUuid;%#ok<AGROW>
                value(end).Name=refs(n).Name;
                value(end).Type=refs(n).Type;
                value(end).ParentUUID=refs(n).ParentUuid;
                value(end).ParentName=refs(n).ParentName;
                value(end).ParentType=refs(n).ParentType;

            end
        end
    end

end
