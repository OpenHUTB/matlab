function checkParameters(varargin)



















































    SrcBlock='Virtual Assembly';
    ParamValues=varargin{1};
    ParamList=varargin{2};
    LookupTblValues=varargin{3};
    LookupTblList=varargin{4};


    if~isempty(ParamList)

        ParamNames=ParamList(:,1);
        NumParams=length(ParamNames);


        for i=1:NumParams
            CheckType(SrcBlock,ParamNames{i},ParamValues{i});
        end
        for i=1:NumParams
            CheckSize(SrcBlock,ParamNames{i},ParamValues{i},ParamList{i,2})
        end
        for i=1:NumParams
            CheckRange(SrcBlock,ParamNames{i},ParamValues{i},ParamList{i,3})
        end
    end


    if~isempty(LookupTblList)
        NumTbls=size(LookupTblList,1);
        for i=1:NumTbls
            BptName=LookupTblList{i,1}(1:2:end-1);
            BptCheck=LookupTblList{i,1}(2:2:end);
            TblName=LookupTblList{i,2};
            TblCheck=LookupTblList{i,3};
            BptValue=LookupTblValues{i,1};
            TblValue=LookupTblValues{i,2};
            CheckLookupTbl(SrcBlock,BptName,BptValue,BptCheck,TblName,TblValue,TblCheck)
        end
    end
end

function CheckType(SrcBlock,ParamName,Value)
    if isempty(Value)
        error(message('autoblks_reference:autoerrVirtualCheckParams:invalidEmpty',SrcBlock,ParamName));
    elseif~all(isnumeric(Value(:)))
        error(message('autoblks_reference:autoerrVirtualCheckParams:invalidNumeric',SrcBlock,ParamName));
    elseif~all(isfinite(Value(:)))
        error(message('autoblks_reference:autoerrVirtualCheckParams:invalidFinite',SrcBlock,ParamName));
    elseif~all(isreal(Value(:)))
        error(message('autoblks_reference:autoerrVirtualCheckParams:invalidReal',SrcBlock,ParamName));
    elseif~all(isfloat(Value(:)))
        error(message('autoblks_reference:autoerrVirtualCheckParams:invalidFloat',SrcBlock,ParamName));
    end
end

function CheckSize(SrcBlock,ParamName,Value,Dims)
    if numel(Dims)<=2
        [m,n]=size(Value);
        if~isempty(Dims)&&(isfinite(Dims(1))&&m~=Dims(1)||isfinite(Dims(2))&&n~=Dims(2))
            error(message('autoblks_reference:autoerrVirtualCheckParams:invalidDims',SrcBlock,ParamName,Dims(1),Dims(2)));
        end
    else
        if numel(Dims)~=numel(size(Value))
            error(message('autoblks_reference:autoerrVirtualCheckParams:invalidNdDims',SrcBlock,ParamName,numel(Dims),Dims(1),Dims(2),Dims(3)));
        else
            for i=1:numel(Dims)
                if size(Value,i)~=Dims(i)
                    error(message('autoblks_reference:autoerrVirtualCheckParams:invalidNdSingleDims',SrcBlock,ParamName,numel(Dims),i,Dims(i)));
                end
            end
        end
    end

end

function CheckRange(SrcBlock,ParamName,Value,Checks)
    if~isempty(Checks)
        [rows,cols]=size(Checks);
        if cols~=2&&~isempty(Checks)
            error(message('autoblks_reference:autoerrVirtualCheckParams:invalidRangeCellSize',SrcBlock,ParamName));
        end
        for j=1:rows
            chk=Checks{j,1};
            BoundValue=Checks{j,2};
            if strcmp(chk,'unit')
                BoundName='';
            else
                BoundName=num2str(BoundValue);
            end
            switch chk
            case 'gt'
                if any(Value(:)<=BoundValue)
                    error(message('autoblks_reference:autoerrVirtualCheckParams:invalidParametergt',SrcBlock,ParamName,BoundName));
                end
            case 'gte'
                if any(Value(:)<BoundValue)
                    error(message('autoblks_reference:autoerrVirtualCheckParams:invalidParametergte',SrcBlock,ParamName,BoundName));
                end
            case 'eq'
                if any(Value(:)~=BoundValue)
                    error(message('autoblks_reference:autoerrVirtualCheckParams:invalidParametereq',SrcBlock,ParamName,BoundName));
                end
            case 'neq'
                if any(Value(:)==BoundValue)
                    error(message('autoblks_reference:autoerrVirtualCheckParams:invalidParameterneq',SrcBlock,ParamName,BoundName));
                end
            case 'lt'
                if any(Value(:)>=BoundValue)
                    error(message('autoblks_reference:autoerrVirtualCheckParams:invalidParameterlt',SrcBlock,ParamName,BoundName));
                end
            case 'lte'
                if any(Value(:)>BoundValue)
                    error(message('autoblks_reference:autoerrVirtualCheckParams:invalidParameterlte',SrcBlock,ParamName,BoundName));
                end
            case 'st'
                if Value~=-1&&Value<=0
                    error(message('autoblks_reference:autoerrVirtualCheckParams:invalidSampleTime',SrcBlock,ParamName));
                end
            case 'unit'
                try
                    [~]=autoblksunitconv(1,Value,BoundValue);
                catch ME
                    error(message('autoblks_reference:autoerrVirtualCheckParams:invalidUnits',SrcBlock,ParamName,ME.message));
                end
            case 'int'
                if any(mod(Value,1))
                    if length(Value)>1
                        error(message('autoblks_reference:autoerrVirtualCheckParams:invalidTypeIntArray',SrcBlock,ParamName));
                    else
                        error(message('autoblks_reference:autoerrVirtualCheckParams:invalidTypeInt',SrcBlock,ParamName));
                    end
                end

            otherwise
                error(message('autoblks_reference:autoerrVirtualCheckParams:invalidParameter',SrcBlock,ParamName));
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
            error(message('autoblks_reference:autoerrVirtualCheckParams:invalidBreakpointSize',SrcBlock,BptName{i}));
        end
        if any(diff(BptValue{i})<=0)
            error(message('autoblks_reference:autoerrVirtualCheckParams:invalidBreakpointValues',SrcBlock,BptName{i}));
        end
    end


    TblSize=size(TblValue);
    TblDims=length(TblSize(TblSize>1));
    if TblDims~=NumDims
        error(message('autoblks_reference:autoerrVirtualCheckParams:invalidLookupDims',SrcBlock,TblName,NumDims));
    end

    if NumDims==1
        if length(TblValue)~=length(BptValue{1})
            error(message('autoblks_reference:autoerrVirtualCheckParams:invalid1DLookupSizeMatch',SrcBlock,TblName,BptName{1}));
        end
    else
        for i=1:length(BptName)
            if TblSize(i)~=length(BptValue{i})
                error(message('autoblks_reference:autoerrVirtualCheckParams:invalidLookupSizeMatch',SrcBlock,i,TblName,BptName{i}));
            end
        end
    end

end















