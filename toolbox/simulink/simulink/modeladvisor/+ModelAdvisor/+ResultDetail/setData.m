








function resultDetailObj=setData(resultDetailObj,varargin)
    persistent model;
    if isempty(model)
        model=mf.zero.Model;
    end
    resultFactory=ModelAdvisor.ResultDetailFactory(model);
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
    if resultDetailObj.Type~=ObjType
        resultDetailObj.setType(ObjType);
    end
    p=inputParser;
    switch(resultDetailObj.Type)
    case ModelAdvisor.ResultDetailType.SID
        if~isempty(varargin{2})
            if ischar(varargin{2})&&Simulink.ID.isValid(varargin{2})

                resultDetailObj.Data=varargin{2};
            else
                if isa(varargin{2},'Simulink.VariableUsage')
                    resultDetailObj=ModelAdvisor.ResultDetail.loc_handle_slVarUsage(resultDetailObj,varargin{2});
                    resultDetailObj.setType(ModelAdvisor.ResultDetailType.SimulinkVariableUsage);
                elseif isa(varargin{2},'Stateflow.Data')&&...
                    isa(idToHandle(sfroot,sf('ParentOf',varargin{2}.Id)),'Stateflow.Machine')
                    dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.RootLevelStateflowData);
                    dataObj.ModelName=Simulink.ID.getSID(varargin{2}.Machine);
                    resultDetailObj.DetailedInfo=dataObj;
                    resultDetailObj.Data=varargin{2}.Name;
                    resultDetailObj.setType(ModelAdvisor.ResultDetailType.RootLevelStateflowData);
                else
                    resultDetailObj.Data=Simulink.ID.getSID(varargin{2});
                end
            end
            if iscell(resultDetailObj.Data)&&~isempty(resultDetailObj.Data)
                resultDetailObj.Data=resultDetailObj.Data{1};
            end
        end
        if nargin>4
            p.addParameter('Expression','');
            p.addParameter('TextStart','');
            p.addParameter('TextEnd','');
            p.parse(varargin{3:end});
            dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.Mfile);
            dataObj.Expression=p.Results.Expression;
            dataObj.TextHighlightStart=num2str(p.Results.TextStart);
            dataObj.TextHighlightEnd=num2str(p.Results.TextEnd);
            resultDetailObj.DetailedInfo=dataObj;
        end
    case ModelAdvisor.ResultDetailType.ConfigurationParameter
        p.KeepUnmatched=true;
        p.addParameter('Model','');
        p.addParameter('Parameter','');
        p.parse(varargin{:});
        dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.ConfigurationParameter);
        dataObj.ModelName=p.Results.Model;
        dataObj.Parameter=p.Results.Parameter;
        unMatchedFields=fields(p.Unmatched);
        for i=1:numel(unMatchedFields)
            resultDetailObj.CustomData.(unMatchedFields{i})=p.Unmatched.(unMatchedFields{i});
        end
        resultDetailObj.DetailedInfo=dataObj;
    case ModelAdvisor.ResultDetailType.BlockParameter

        p.KeepUnmatched=true;
        p.addParameter('Block','');
        p.addParameter('Parameter','');
        p.addParameter('CurrentValue','');
        p.addParameter('RecommendedValue','');
        p.parse(varargin{:});

        dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.BlockParameter);

        Blk=Simulink.ID.getSID(p.Results.Block);
        if iscell(dataObj.Block)
            dataObj.Block=dataObj.Blk{1};
        else
            dataObj.Block=Blk;
        end

        dataObj.Parameter=p.Results.Parameter;

        currentValuePtr=dataObj.currentValue;
        currentValuePtr.add(p.Results.CurrentValue);

        fixValuePtr=dataObj.fixValue;
        fixValuePtr.add(p.Results.RecommendedValue);

        resultDetailObj.DetailedInfo=dataObj;

    case ModelAdvisor.ResultDetailType.Mfile
        p.addParameter('FileName','');
        p.addParameter('Expression','');
        p.addParameter('TextStart','');
        p.addParameter('TextEnd','');
        p.parse(varargin{:});
        dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.Mfile);
        dataObj.FileName=p.Results.FileName;
        dataObj.Expression=p.Results.Expression;
        dataObj.TextHighlightStart=num2str(p.Results.TextStart);
        dataObj.TextHighlightEnd=num2str(p.Results.TextEnd);
        resultDetailObj.DetailedInfo=dataObj;
    case ModelAdvisor.ResultDetailType.Signal
        resultDetailObj.Data=varargin{2};
        sig=get_param(resultDetailObj.Data,'object');

        if isa(sig,'Simulink.Port')
            sig=get_param(sig.Line,'object');
        end
        dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.Signal);
        if ishandle(sig.SrcBlockHandle)
            dataObj.SrcSid=Simulink.ID.getSID(sig.SrcBlockHandle);
        end

        if ishandle(sig.DstBlockHandle)
            dataObj.DestSid=strjoin(arrayfun(@(x)Simulink.ID.getSID(x),sig.DstBlockHandle,'UniformOutput',0),',');
        end

        if ishandle(sig.SrcPortHandle)
            dataObj.SrcPortNum=get_param(sig.SrcPortHandle,'PortNumber');
        else
            dataObj.SrcPortNum=-1;
        end

        if ishandle(sig.DstPortHandle)
            dataObj.DestPortNum=get_param(sig.DstPortHandle(1),'PortNumber');
        else
            dataObj.DestPortNum=-1;
        end
        resultDetailObj.DetailedInfo=dataObj;
    case ModelAdvisor.ResultDetailType.String
        resultDetailObj.Data=varargin{2};
    case ModelAdvisor.ResultDetailType.Constraint
        resultDetailObj.CustomData=varargin{2};
    case ModelAdvisor.ResultDetailType.RootLevelStateflowData
        dataObj=resultFactory.createResultDetailType(ModelAdvisor.ResultDetailType.RootLevelStateflowData);
        dataObj.ModelName=Simulink.ID.getSID(varargin{2}.Machine);
        resultDetailObj.DetailedInfo=dataObj;
        resultDetailObj.Data=varargin{2}.Name;
    case ModelAdvisor.ResultDetailType.SimulinkVariableUsage
        resultDetailObj=ModelAdvisor.ResultDetail.loc_handle_slVarUsage(resultDetailObj,varargin{2});
    case ModelAdvisor.ResultDetailType.Group



        if~isempty(varargin{2})
            if~Simulink.ID.isValid(varargin{2})
                resultDetailObj.CustomData=Simulink.ID.getSID(varargin{2});
            else
                resultDetailObj.CustomData=varargin{2};
            end
            resultDetailObj.Data=strjoin(resultDetailObj.CustomData,'|');
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
                namePairData{dCount}=ModelAdvisor.ResultDetail.qualifyData(npData(dCount));
            end

            structVal.data{count}=namePairData;
        end
        resultDetailObj.CustomData=structVal;

    otherwise
        error(message('ModelAdvisor:engine:MAUnknownRDType'));
    end
end