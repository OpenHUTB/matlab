classdef(CaseInsensitiveProperties=true)OldResultDetail<matlab.mixin.Heterogeneous&matlab.mixin.Copyable

    properties
        Data='';
        Type=ModelAdvisor.ResultDetailType.SID;
        IsInformer=false;
        IsViolation=true;
        Description='';
        Title='';
        Information='';
        Status='';
        RecAction='';
    end

    properties(Hidden=true,SetAccess=public)


        CustomData=[];
        Format=[];
        Tags='';
        Severity=0;
        TaskID='';
        CheckID='';
        CheckAlgoID='';
    end

    properties(Hidden=true,SetAccess=protected)
        ID;

        Expression='';
        Model='';
        Parameter='';
        Block='';
        FileName='';
        Line='';
        Column='';
        TextHighlightStart='';
        TextHighlightEnd='';
        SlVarSource='';
        SlVarSourceType='';
    end

    methods
        function obj=ResultDetail(varargin)
            obj.ID=matlab.lang.internal.uuid;

            for j=1:(nargin)/2
                name=varargin{2*j-1};
                value=varargin{2*j};
                obj.(name)=value;
            end
        end










        function setData(obj,varargin)
            if nargin>1
                [varargin{:}]=convertStringsToChars(varargin{:});
            end

            if(nargin==2)
                varargin=['SID',varargin];
            end
            p=inputParser;
            validateCallback=@(x)ischar(x);
            addRequired(p,'Type',validateCallback);
            parse(p,varargin{1});

            if strcmp(varargin{1},'SID')
                ObjType=ModelAdvisor.ResultDetailType.SID;
            elseif strcmp(varargin{1},'Model')
                ObjType=ModelAdvisor.ResultDetailType.ConfigurationParameter;
            elseif strcmp(varargin{1},'Block')
                ObjType=ModelAdvisor.ResultDetailType.BlockParameter;
            elseif strcmp(varargin{1},'FileName')
                ObjType=ModelAdvisor.ResultDetailType.Mfile;
            elseif strcmp(varargin{1},'Signal')
                ObjType=ModelAdvisor.ResultDetailType.Signal;
            elseif strcmp(varargin{1},'String')
                ObjType=ModelAdvisor.ResultDetailType.String;
            elseif strcmp(varargin{1},'Constraint')
                ObjType=ModelAdvisor.ResultDetailType.Constraint;
            elseif strcmp(varargin{1},'RootLevelStateflowData')
                ObjType=ModelAdvisor.ResultDetailType.RootLevelStateflowData;
            elseif strcmp(varargin{1},'SimulinkVariableUsage')
                ObjType=ModelAdvisor.ResultDetailType.SimulinkVariableUsage;
            elseif strcmp(varargin{1},'Group')
                ObjType=ModelAdvisor.ResultDetailType.Group;
            elseif strcmp(varargin{1},'Custom')
                ObjType=ModelAdvisor.ResultDetailType.Custom;
            else
                error('wrong syntax');
            end
            if obj.Type~=ObjType
                obj.Type=ObjType;
            end
            p=inputParser;
            switch(obj.Type)
            case ModelAdvisor.ResultDetailType.SID
                if~isempty(varargin{2})
                    if ischar(varargin{2})&&Simulink.ID.isValid(varargin{2})

                        obj.Data=varargin{2};
                    else
                        if isa(varargin{2},'Simulink.VariableUsage')
                            obj=loc_handle_slVarUsage(obj,varargin{2});
                            obj.Type=ModelAdvisor.ResultDetailType.SimulinkVariableUsage;
                        elseif isa(varargin{2},'Stateflow.Data')&&...
                            isa(idToHandle(sfroot,sf('ParentOf',varargin{2}.Id)),'Stateflow.Machine')
                            obj.Model=Simulink.ID.getSID(varargin{2}.Machine);
                            obj.Data=varargin{2}.Name;
                            obj.Type=ModelAdvisor.ResultDetailType.RootLevelStateflowData;
                        else
                            obj.Data=Simulink.ID.getSID(varargin{2});
                        end
                    end
                    if iscell(obj.Data)&&~isempty(obj.Data)
                        obj.Data=obj.Data{1};
                    end
                end
                if nargin>4
                    p.addParameter('Expression','');
                    p.addParameter('TextStart','');
                    p.addParameter('TextEnd','');
                    p.parse(varargin{3:end});
                    obj.Expression=p.Results.Expression;
                    obj.TextHighlightStart=p.Results.TextStart;
                    obj.TextHighlightEnd=p.Results.TextEnd;
                end
            case ModelAdvisor.ResultDetailType.ConfigurationParameter
                p.KeepUnmatched=true;
                p.addParameter('Model','');
                p.addParameter('Parameter','');
                p.parse(varargin{:});
                obj.Model=p.Results.Model;
                obj.Parameter=p.Results.Parameter;
                unMatchedFields=fields(p.Unmatched);
                for i=1:numel(unMatchedFields)
                    obj.CustomData.(unMatchedFields{i})=p.Unmatched.(unMatchedFields{i});
                end
            case ModelAdvisor.ResultDetailType.BlockParameter
                p.KeepUnmatched=true;
                p.addParameter('Block','');
                p.addParameter('Parameter','');
                p.parse(varargin{:});
                obj.Block=Simulink.ID.getSID(p.Results.Block);
                if iscell(obj.Block)
                    obj.Block=obj.Block{1};
                end
                obj.Parameter=p.Results.Parameter;
                unMatchedFields=fields(p.Unmatched);
                for i=1:numel(unMatchedFields)
                    obj.CustomData.(unMatchedFields{i})=p.Unmatched.(unMatchedFields{i});
                end
            case ModelAdvisor.ResultDetailType.Mfile
                p.addParameter('FileName','');
                p.addParameter('Expression','');
                p.addParameter('TextStart','');
                p.addParameter('TextEnd','');
                p.parse(varargin{:});
                obj.FileName=p.Results.FileName;
                obj.Expression=p.Results.Expression;
                obj.TextHighlightStart=p.Results.TextStart;
                obj.TextHighlightEnd=p.Results.TextEnd;
            case ModelAdvisor.ResultDetailType.Signal
                obj.Data=varargin{2};
            case ModelAdvisor.ResultDetailType.String
                obj.Data=varargin{2};
            case ModelAdvisor.ResultDetailType.Constraint
                obj.Data=varargin{2};
            case ModelAdvisor.ResultDetailType.RootLevelStateflowData
                obj.Model=Simulink.ID.getSID(varargin{2}.Machine);
                obj.Data=varargin{2}.Name;
            case ModelAdvisor.ResultDetailType.SimulinkVariableUsage
                obj=loc_handle_slVarUsage(obj,varargin{2});
            case ModelAdvisor.ResultDetailType.Group



                if~isempty(varargin{2})
                    if~Simulink.ID.isValid(varargin{2})
                        obj.CustomData=Simulink.ID.getSID(varargin{2});
                    else
                        obj.CustomData=varargin{2};
                    end
                    obj.Data=strjoin(obj.CustomData,'|');
                end
            case ModelAdvisor.ResultDetailType.Custom
                customVal=varargin(2:end);

                if isempty(customVal)
                    error(message('ModelAdvisor:engine:MAEmptyCustomData'));
                end

                if 0~=mod(size(customVal,2),2)
                    error(message('ModelAdvisor:engine:MAErrorNameValuePair'));
                end



                structVal.metaData=customVal(1:2:end);
                structVal.data=customVal(2:2:end);


                for count=1:size(structVal.data,2)

                    if~ischar(structVal.metaData{count})
                        error(message('ModelAdvisor:engine:MAStringName'));
                    end

                    npData=structVal.data{count};




                    if ischar(npData)
                        npData={npData};
                    end

                    namePairData=cell(1,numel(npData));

                    for dCount=1:numel(npData)
                        namePairData{dCount}=qualifyData(npData(dCount));
                    end

                    structVal.data{count}=namePairData;

                end

                obj.CustomData=structVal;

            otherwise
                error(message('ModelAdvisor:engine:MAUnknownRDType'));
            end
        end

        function data=getData(obj)

            switch(obj.Type)
            case{ModelAdvisor.ResultDetailType.SID,...
                ModelAdvisor.ResultDetailType.Signal,...
                ModelAdvisor.ResultDetailType.String,...
                ModelAdvisor.ResultDetailType.Constraint,...
                ModelAdvisor.ResultDetailType.RootLevelStateflowData,...
                ModelAdvisor.ResultDetailType.SimulinkVariableUsage,...
                ModelAdvisor.ResultDetailType.Group}
                data=obj.Data;
            case ModelAdvisor.ResultDetailType.ConfigurationParameter
                data=obj.Model;
            case ModelAdvisor.ResultDetailType.BlockParameter
                data=obj.Block;
            case ModelAdvisor.ResultDetailType.Mfile
                data=obj.FileName;
            case ModelAdvisor.ResultDetailType.Custom
                data=obj.CustomData;
            otherwise
                data=[];
            end

        end

        function setSeverity(obj,value)
            switch lower(value)
            case 'warn'
                obj.Severity=0;
            case 'fail'
                obj.Severity=1;
            otherwise
                obj.Severity=value;
            end
        end

        function set.Type(obj,value)
            if isa(value,'ModelAdvisor.ResultDetailType')
                obj.Type=value;
            else
                error(message('Simulink:tools:MAInvalidParam','ModelAdvisor.ResultDetailType'));
            end
        end

        function set.IsInformer(obj,value)
            if islogical(value)||isnumeric(value)
                obj.IsInformer=logical(value);
            else
                error(message('Simulink:tools:MAInvalidParam','logical'));
            end
        end

        function set.IsViolation(obj,value)
            if islogical(value)||isnumeric(value)
                obj.IsViolation=logical(value);
            else
                error(message('Simulink:tools:MAInvalidParam','logical'));
            end
        end
    end

    methods(Hidden)

        function output=toStruct(this)
            list={'Data','IsViolation','IsInformer','Description','Title','Information','Status','RecAction','Tags','Severity','TaskID','CheckID','ID','CustomData',...
            'Expression','Model','Parameter','Block','FileName','Line','Column'};
            output=struct;
            for i=1:numel(list)
                output.(list{i})=this.(list{i});
            end
            switch this.Type
            case ModelAdvisor.ResultDetailType.Signal
                output.Data='';
            case ModelAdvisor.ResultDetailType.Constraint
                output.CustomData=output.Data;
                output.Data='Constraint Object';
            end

            output.ID=char(output.ID);
            output.IsViolation=int32(output.IsViolation);
            output.IsInformer=int32(output.IsInformer);
            output.Type=int32(this.Type);
        end
    end

end

function obj=qualifyData(data)



    obj=[];

    if iscell(data)
        data=data{1};
    end
    if isa(data,'Advisor.Text')
        obj.Data=data;
        obj.Type=ModelAdvisor.ResultDetailType.String;
    elseif Simulink.ID.isValid(data)


        obj.Data=data;
        obj.Type=ModelAdvisor.ResultDetailType.SID;

    elseif isa(data,'Stateflow.Data')

        if isa(idToHandle(sfroot,sf('ParentOf',data.Id)),'Stateflow.Machine')
            obj.Model=Simulink.ID.getSID(data.Machine);
            obj.Data=data.Name;
            obj.Type=ModelAdvisor.ResultDetailType.RootLevelStateflowData;
        else

            obj.Data=Simulink.ID.getSID(data);
            obj.Type=ModelAdvisor.ResultDetailType.SID;
        end
    elseif ischar(data)
        obj.Data=data;
        obj.Type=ModelAdvisor.ResultDetailType.String;
    elseif isa(data,'Simulink.VariableUsage')
        obj.Type=ModelAdvisor.ResultDetailType.SimulinkVariableUsage;
        obj=loc_handle_slVarUsage(obj,data);
    else

        try
            obj.Data=Simulink.ID.getSID(data);
        catch
            error(message('ModelAdvisor:engine:MAUnknownType'));
        end

        obj.Type=ModelAdvisor.ResultDetailType.SID;

    end
end



function obj=loc_handle_slVarUsage(obj,data)
    obj.Data=data.Name;
    obj.SlVarSource=data.Source;
    if isstruct(data)&&~isfield(data,'SourceType')
        obj.SlVarSourceType='unknown source';
    else
        obj.SlVarSourceType=data.SourceType;
    end
end