function ParamStruct=autoblkscheckparams(varargin)

    Block=varargin{1};
    SrcBlock=get_param(Block,'Name');
    if ischar(varargin{2})
        ParamList=varargin{3};
        LookupTblIndex=4;
    else
        ParamList=varargin{2};
        LookupTblIndex=3;
    end

    if nargin>=LookupTblIndex
        LookupTblList=varargin{LookupTblIndex};
    else
        LookupTblList=[];
    end



    if nargin>=5
        WsVars=varargin{5};
        EvaluateParamNames={WsVars.Name};
    else
        WsVars=[];
    end




    if isempty(WsVars)
        MaskObject=get_param(Block,'MaskObject');
        Enabled={MaskObject.Parameters.Enabled};


        EvaluateParamNames={MaskObject.Parameters(strcmp(Enabled,'on')).Name};
        WsVars=MaskObject.getWorkspaceVariables;
    end

    [~,IParamList]=intersect({WsVars.Name},EvaluateParamNames,'stable');
    WsVars=WsVars(IParamList);
    for i=1:length(WsVars)
        if isa(WsVars(i).Value,'mpt.Parameter')||isa(WsVars(i).Value,'Simulink.Parameter')
            WsVars(i).Value=WsVars(i).Value.Value;
        end
    end
    WsValues={WsVars.Value};
    WsNames={WsVars.Name};


    if~isempty(ParamList)

        [~,IParamList]=intersect(ParamList(:,1),{MaskObject.Parameters.Name},'stable');
        if length(IParamList)~=size(ParamList,1)
            for i=1:size(ParamList,1)
                if~any(strcmp({MaskObject.Parameters.Name},ParamList{i,1}))
                    error(message('autoblks_shared:autoerrCheckParams:invalidExist',SrcBlock,ParamList{i,1}))
                end
            end
        end


        [~,IParamList]=intersect(ParamList(:,1),EvaluateParamNames,'stable');
        ParamList=ParamList(IParamList,:);
        ParamNames=ParamList(:,1);
        [~,~,IValues]=intersect(ParamNames,WsNames,'stable');
        ParamValues=WsValues(IValues);
        NumParams=length(ParamValues);


        isUnit=false(size(ParamNames));
        for i=1:NumParams
            if~isempty(ParamList{i,3})
                if any(strcmp(ParamList{i,3}(:,1),'unit'))
                    isUnit(i)=true;
                end
            end
        end


        for i=1:NumParams
            if~isUnit(i)
                CheckType(SrcBlock,ParamNames{i},ParamValues{i});
            end
        end
        for i=1:NumParams
            if~isUnit(i)
                CheckSize(SrcBlock,ParamNames{i},ParamValues{i},ParamList{i,2})
            end
        end
        for i=1:NumParams
            CheckRange(SrcBlock,ParamNames{i},ParamValues{i},ParamList{i,3},WsVars)
        end
    else
        NumParams=0;
        ParamNames={};
        ParamValues={};
    end

    if~isempty(LookupTblList)

        [~,ITblList]=intersect(LookupTblList(:,2),EvaluateParamNames,'stable');
        LookupTblList=LookupTblList(ITblList,:);
        NumTbls=size(LookupTblList,1);
        for i=1:NumTbls
            BptName=LookupTblList{i,1}(1:2:end-1);
            BptCheck=LookupTblList{i,1}(2:2:end);
            TblName=LookupTblList{i,2};
            TblCheck=LookupTblList{i,3};
            [~,~,IValues]=intersect(BptName,WsNames,'stable');
            BptValue=WsValues(IValues);
            [~,~,IValues]=intersect(TblName,WsNames,'stable');
            TblValue=WsValues{IValues};
            CheckLookupTbl(SrcBlock,BptName,BptValue,BptCheck,TblName,TblValue,TblCheck)


            NumBpts=length(BptName);
            NewNumParams=NumParams+NumBpts+1;
            ParamNames((NumParams+1):(NewNumParams))=[BptName,TblName];
            ParamValues((NumParams+1):(NewNumParams))=[BptValue,TblValue];
            NumParams=NewNumParams;
        end
    end


    if nargout>=1
        if~isempty(ParamValues)
            for i=1:NumParams
                ParamStruct.(ParamNames{i})=ParamValues{i};
            end
        else
            ParamStruct=[];
        end
    end
end

function CheckType(SrcBlock,ParamName,Value)
    if isempty(Value)
        error(message('autoblks_shared:autoerrCheckParams:invalidEmpty',SrcBlock,ParamName));
    elseif~all(isnumeric(Value(:)))
        error(message('autoblks_shared:autoerrCheckParams:invalidNumeric',SrcBlock,ParamName));
    elseif~all(isfinite(Value(:)))
        error(message('autoblks_shared:autoerrCheckParams:invalidFinite',SrcBlock,ParamName));
    elseif~all(isreal(Value(:)))
        error(message('autoblks_shared:autoerrCheckParams:invalidReal',SrcBlock,ParamName));
    elseif~all(isfloat(Value(:)))
        error(message('autoblks_shared:autoerrCheckParams:invalidFloat',SrcBlock,ParamName));
    end
end

function CheckSize(SrcBlock,ParamName,Value,Dims)
    if numel(Dims)<=2
        [m,n]=size(Value);
        if~isempty(Dims)&&(isfinite(Dims(1))&&m~=Dims(1)||isfinite(Dims(2))&&n~=Dims(2))
            error(message('autoblks_shared:autoerrCheckParams:invalidDims',SrcBlock,ParamName,Dims(1),Dims(2)));
        end
    else
        if numel(Dims)~=numel(size(Value))
            error(message('autoblks_shared:autoerrCheckParams:invalidNdDims',SrcBlock,ParamName,numel(Dims),Dims(1),Dims(2),Dims(3)));
        else
            for i=1:numel(Dims)
                if size(Value,i)~=Dims(i)
                    error(message('autoblks_shared:autoerrCheckParams:invalidNdSingleDims',SrcBlock,ParamName,numel(Dims),i,Dims(i)));
                end
            end
        end
    end

end

function CheckRange(SrcBlock,ParamName,Value,Checks,WsVars)
    if~isempty(Checks)
        [rows,cols]=size(Checks);
        if cols~=2&&~isempty(Checks)
            error(message('autoblks_shared:autoerrCheckParams:invalidRangeCellSize',SrcBlock,ParamName));
        end
        for j=1:rows
            chk=Checks{j,1};
            BoundValue=Checks{j,2};
            if strcmp(chk,'unit')
                BoundName='';
            elseif ischar(BoundValue)
                BoundName=BoundValue;
                BoundValue=WsVars(strcmp({WsVars.Name},BoundName)).Value;
            else
                BoundName=num2str(BoundValue);
            end
            switch chk
            case 'gt'
                if any(Value(:)<=BoundValue)
                    error(message('autoblks_shared:autoerrCheckParams:invalidParametergt',SrcBlock,ParamName,BoundName));
                end
            case 'gte'
                if any(Value(:)<BoundValue)
                    error(message('autoblks_shared:autoerrCheckParams:invalidParametergte',SrcBlock,ParamName,BoundName));
                end
            case 'eq'
                if any(Value(:)~=BoundValue)
                    error(message('autoblks_shared:autoerrCheckParams:invalidParametereq',SrcBlock,ParamName,BoundName));
                end
            case 'neq'
                if any(Value(:)==BoundValue)
                    error(message('autoblks_shared:autoerrCheckParams:invalidParameterneq',SrcBlock,ParamName,BoundName));
                end
            case 'lt'
                if any(Value(:)>=BoundValue)
                    error(message('autoblks_shared:autoerrCheckParams:invalidParameterlt',SrcBlock,ParamName,BoundName));
                end
            case 'lte'
                if any(Value(:)>BoundValue)
                    error(message('autoblks_shared:autoerrCheckParams:invalidParameterlte',SrcBlock,ParamName,BoundName));
                end
            case 'st'
                if Value~=-1&&Value<=0
                    error(message('autoblks_shared:autoerrCheckParams:invalidSampleTime',SrcBlock,ParamName));
                end
            case 'unit'
                try
                    [~]=autoblksunitconv(1,Value,BoundValue);
                catch ME
                    error(message('autoblks_shared:autoerrCheckParams:invalidUnits',SrcBlock,ParamName,ME.message));
                end
            case 'int'
                if any(mod(Value,1))
                    if length(Value)>1
                        error(message('autoblks_shared:autoerrCheckParams:invalidTypeIntArray',SrcBlock,ParamName));
                    else
                        error(message('autoblks_shared:autoerrCheckParams:invalidTypeInt',SrcBlock,ParamName));
                    end
                end

            otherwise
                error(message('autoblks_shared:autoerrCheckParams:invalidParameter',SrcBlock,ParamName));
            end
        end
    end

end

function CheckLookupTbl(SrcBlock,BptName,BptValue,BptCheck,TblName,TblValue,TblCheck)

    for j=1:length(BptValue)
        CheckType(SrcBlock,BptName{j},BptValue{j});
        CheckRange(SrcBlock,BptName{j},BptValue{j},BptCheck{j})
    end
    CheckType(SrcBlock,TblName,TblValue);
    CheckRange(SrcBlock,TblName,TblValue,TblCheck);


    NumDims=length(BptName);
    for i=1:NumDims
        BptSize=size(BptValue{i});
        if length(BptSize)>=3||BptSize(1)>1&&BptSize(2)>1||length(BptValue{i})<2
            error(message('autoblks_shared:autoerrCheckParams:invalidBreakpointSize',SrcBlock,BptName{i}));
        end
        if any(diff(BptValue{i})<=0)
            error(message('autoblks_shared:autoerrCheckParams:invalidBreakpointValues',SrcBlock,BptName{i}));
        end
    end


    TblSize=size(TblValue);
    TblDims=length(TblSize(TblSize>1));
    if TblDims~=NumDims
        error(message('autoblks_shared:autoerrCheckParams:invalidLookupDims',SrcBlock,TblName,NumDims));
    end

    if NumDims==1
        if length(TblValue)~=length(BptValue{1})
            error(message('autoblks_shared:autoerrCheckParams:invalid1DLookupSizeMatch',SrcBlock,TblName,BptName{1}));
        end
    else
        for i=1:length(BptName)
            if TblSize(i)~=length(BptValue{i})
                error(message('autoblks_shared:autoerrCheckParams:invalidLookupSizeMatch',SrcBlock,i,TblName,BptName{i}));
            end
        end
    end

end















