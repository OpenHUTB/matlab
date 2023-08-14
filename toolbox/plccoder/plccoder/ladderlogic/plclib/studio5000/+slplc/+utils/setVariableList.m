function setVariableList(pouBlock,varList,varargin)



    if numel(varargin)==1&&strcmpi(varargin{1},'VariableSS')

        dataBlock=slplc.utils.getInternalBlockPath(pouBlock,'VariableSS');
    else

        varList=validateVarList(pouBlock,varList);
        if strcmp(slplc.utils.getParam(pouBlock,'PLCBlockType'),'FunctionBlock')
            varList=sortVarList(varList,'FunctionBlock');
        else
            varList=sortVarList(varList);
        end
        dataBlock=slplc.utils.getInternalBlockPath(pouBlock,'Logic');
    end

    locSetVariableList(dataBlock,varList);
end

function locSetVariableList(dataBlock,varList)
    plcBlockData.VariableList=varList;
    set_param(dataBlock,'UserDataPersistent','on')
    set_param(dataBlock,'UserData',plcBlockData);
end


function varList=validateVarList(pouBlock,varList)
    if isempty(varList)
        varList=[];
        return
    end

    noPortIndex=num2str(numel(varList));
    aoiAtomicDataTypes={...
    'BOOL','SINT','DINT','INT','REAL',...
    'boolean','int8','int16','int32','single'};
    aoiAssertionMsg='AOI block input and output variables must be a scalar (size is 1) and atomic data types (BOOL, SINT, DINT, INT, and REAL).';

    for varCount=1:numel(varList)
        varInfo=varList(varCount);
        assert(isvarname(varInfo.Name),...
        'slplc:invalidVarName',...
        'Invalid variable name %s in POU block %s.',...
        varInfo.Name,pouBlock);

        if strcmpi(varInfo.Scope,'Local')
            varInfo.PortType='Hidden';
            varInfo.PortIndex=noPortIndex;
        elseif strcmpi(varInfo.Scope,'InOut')
            varInfo.InitialValue='0';
        elseif strcmpi(varInfo.Scope,'External')
            varInfo.PortType='Hidden';
            varInfo.PortIndex=noPortIndex;
            varInfo.DataType=slplc.utils.getDefaultDataType();
            varInfo.Size='-1';
            varInfo.InitialValue='0';
            varInfo.IsFBInstance=false;
        elseif strcmpi(varInfo.Scope,'Global')&&strcmpi(varInfo.PortType,'Hidden')
            varInfo.PortIndex=noPortIndex;
        end

        legalScopePortPairs={...
        'Local, Hidden',...
        'Input, Inport',...
        'Input, Hidden',...
        'Output, Outport',...
        'Output, Hidden',...
        'InOut, Inport',...
        'InOut, Inport/Outport',...
        'External, Hidden',...
        'Global, Inport',...
        'Global, Outport',...
        'Global, Hidden',...
        };

        scopePortPair=[varInfo.Scope,', ',varInfo.PortType];
        if~ismember(scopePortPair,legalScopePortPairs)
            error('slplc:invalidScope',...
            'Port type %s is invalid for %s variable %s in POU block %s.',...
            varInfo.PortType,varInfo.Scope,varInfo.Name,pouBlock);
        end


        pouType=slplc.utils.getParam(pouBlock,'PLCBlockType');
        if strcmpi(pouType,'LDFunctionBlock')
            if strcmpi(varInfo.Scope,'External')
                error('slplc:externalAOIDataScopeNotAllowed',...
                'Data Scope %s is not allowed for AOI block that is specified for variable %s in %s.',...
                varInfo.Scope,varInfo.Name,pouBlock);
            end
            if ismember(varInfo.Scope,{'Input','Output'})
                if~ismember(varInfo.DataType,aoiAtomicDataTypes)
                    error('slplc:invalidAOIDataScope',...
                    'Data Scope %s is invalid for variable %s with %s data type in AOI block %s. %s',...
                    varInfo.Scope,varInfo.Name,varInfo.DataType,pouBlock,aoiAssertionMsg);
                end
                if~strcmp(varInfo.Size,'1')
                    error('slplc:invalidAOIDataSize',...
                    'Data scope %s is invalid for variable %s with %s data size in AOI block %s. %s',...
                    varInfo.Scope,varInfo.Name,varInfo.Size,pouBlock,aoiAssertionMsg);
                end
            end
        end

        varList(varCount)=varInfo;
    end

end

function varList=sortVarList(varList,varargin)
    if isempty(varList)
        varList=[];
        return
    end

    if isempty(varargin)

        [~,idx]=sort({varList.Name});
        varList=varList(idx);


        varList=varList(sortByOrder({varList.Scope},{'Input','InOut','Output','Local','External','Global'}));


        portIndexVec=cellfun(@str2double,{varList.PortIndex});
        [~,idx]=sort(portIndexVec);
        varList=varList(idx);



        overridedPortTypeCellArray=overrideInOutPortType({varList.PortType});
        varList=varList(sortByOrder(overridedPortTypeCellArray,{'Inport','Outport','Inport/Outport','Hidden'}));
    end


    [isInVar,varLocIdx]=ismember('EnableOut',{varList.Name});
    if isInVar
        enableOutVar=varList(varLocIdx);
        enableOutVar.PortIndex='1';
        varList(varLocIdx)=[];
        varList=[enableOutVar,varList];
    end

    [isInVar,varLocIdx]=ismember('EnableIn',{varList.Name});
    if isInVar
        enableInVar=varList(varLocIdx);
        enableInVar.PortIndex='1';
        varList(varLocIdx)=[];
        varList=[enableInVar,varList];
    end


    varList=updatePortIndex(varList);
end


function idx=sortByOrder(rawCellArray,priorityArray)
    prioritVec=1:numel(rawCellArray);
    for eleCount=1:numel(rawCellArray)
        [~,prioritVec(eleCount)]=ismember(rawCellArray{eleCount},priorityArray);
    end
    [~,idx]=sort(prioritVec);
end


function portTypeCellArray=overrideInOutPortType(portTypeCellArray)
    for varCount=1:numel(portTypeCellArray)
        if strcmpi(portTypeCellArray{varCount},'Inport/Outport')
            portTypeCellArray{varCount}='Inport';
        end
    end
end

function varList=updatePortIndex(varList)
    inportIndex=0;
    outportIndex=0;
    inoutIndex=[];
    noportIndex=numel(varList);

    outporNum=sum(ismember({varList.PortType},'Outport'));
    inportoutporNum=sum(ismember({varList.PortType},'Inport/Outport'));
    totalOutportNum=outporNum+inportoutporNum;

    for varCount=1:numel(varList)
        varName=varList(varCount).Name;
        varPortType=varList(varCount).PortType;

        if strcmpi(varName,'EnableIn')
            inportIndex=inportIndex+1;
        elseif strcmpi(varName,'EnableOut')
            outportIndex=outportIndex+1;
        else
            if strcmpi(varPortType,'inport')
                inportIndex=inportIndex+1;
                varPortIndex=num2str(inportIndex);
            elseif strcmpi(varPortType,'outport')
                outportIndex=getNextOutportIndex(outportIndex,inoutIndex);
                varPortIndex=num2str(outportIndex);
            elseif strcmpi(varPortType,'inport/outport')
                inportIndex=inportIndex+1;
                if inportIndex>totalOutportNum
                    error('slplc:invalidPortIndex',...
                    'Invalid Inport/Outport type port index setting(%d) for variable %s that should not be greater than number(%d) of total outports',...
                    inportIndex,varName,totalOutportNum)
                end
                inoutIndex(end+1)=inportIndex;%#ok<AGROW>
                varPortIndex=num2str(inportIndex);
            else
                varPortIndex=noportIndex;
            end
            varList(varCount).PortIndex=num2str(varPortIndex);
        end
    end

end

function outportIndex=getNextOutportIndex(outportIndex,inoutIndex)
    outportIndex=outportIndex+1;
    if ismember(outportIndex,inoutIndex)
        outportIndex=getNextOutportIndex(outportIndex,inoutIndex);
    end
end


