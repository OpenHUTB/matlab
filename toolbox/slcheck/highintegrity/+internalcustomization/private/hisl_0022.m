function hisl_0022




    rec=getNewCheckObject('mathworks.hism.hisl_0022',false,@hCheckAlgo,'PostCompile');

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams(1);
    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end

function violations=hCheckAlgo(system)

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    checkExternalMLFiles=inputParams{1}.Value;
    fl_index=2;
    lum_index=3;

    violations=checkAlgoSL(system,fl_index,lum_index);

    violations=[violations;checkAlgoML(system,fl_index,lum_index,checkExternalMLFiles);...
    checkAlgoSF(system,fl_index,lum_index)];

end

function violations=checkAlgoSL(system,fl_index,lum_index)
    violations=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;




    blockTypesRegExp='\<Assignment\>|\<LookupNDDirect\>|\<MultiPortSwitch\>|\<Selector\>|^Lookup_n$|^Interpolation_n-D$';
    blocksOfInterest=find_system(system,...
    'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',inputParams{fl_index}.Value,...
    'LookUnderMasks',inputParams{lum_index}.Value,...
    'RegExp','on',...
    'BlockType',blockTypesRegExp);

    blocksOfInterest=mdladvObj.filterResultWithExclusion(blocksOfInterest);

    for i=1:length(blocksOfInterest)
        [indexPortsDataType,dataPortDimensions]=getIndexAndDataPortProps(system,blocksOfInterest{i});
        [isvalid,issue]=isIndexPortsValid(system,indexPortsDataType,dataPortDimensions,blocksOfInterest{i});
        if~isvalid
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',blocksOfInterest{i});
            vObj.RecAction=DAStudio.message(['ModelAdvisor:hism:hisl_0022_rec_action',num2str(issue)]);
            violations=[violations;vObj];%#ok<AGROW>
        end
    end

end

function violations=checkAlgoML(system,fl_index,lum_index,checkExternalMLFiles)
    violations=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;


    blocksOfInterest=Advisor.Utils.getAllMATLABFunctionBlocks(system,inputParams{fl_index}.Value,inputParams{lum_index}.Value);
    blocksOfInterest=mdladvObj.filterResultWithExclusion(blocksOfInterest);

    if checkExternalMLFiles
        allMLObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();
        extMLFiles=allMLObjs(cellfun(@(x)isa(x,'struct'),allMLObjs));
        blocksOfInterest=[blocksOfInterest;extMLFiles];
    end

    for i=1:length(blocksOfInterest)
        violations=[violations;isIndexVarsValid(system,blocksOfInterest{i})];%#ok<AGROW>
    end
end

function violations=isIndexVarsValid(system,block)
    violations=[];
    rp=[];


    if isa(block,'struct')
        parent=Advisor.Utils.Eml.getEMLParentOfReferencedFile(block);
        if~isempty(parent)
            rp=Advisor.Utils.Eml.getEmlReport(parent);
        end
    else
        rp=Advisor.Utils.Eml.getEmlReport(block);
    end

    if isempty(rp)
        return;
    end

    rpi=rp.inference;
    if isa(block,'struct')
        mt=mtree(block.FileName,'-com','-cell','-file','-comments');
    else
        mt=mtree(block.Script,'-com','-cell','-comments');
    end
    opNodes=mt.mtfind('Kind','SUBSCR');
    indices=opNodes.indices;
    for i=1:length(indices)
        node=opNodes.select(indices(i));

        data_node=node.Left;



        if strcmp(data_node.kind,'DOT')&&strcmp(data_node.Left.strings{1},'coder')
            continue;
        end



        idx_indices=[];
        idx_node=node.Right;
        while~isempty(idx_node)
            if strcmp(idx_node.kind,'SUBSCR')
                idx_indices(end+1)=idx_node.Left.indices;%#ok<AGROW>
            else
                idx_indices(end+1)=idx_node.indices;%#ok<AGROW>
            end
            idx_node=idx_node.Next;
        end

        [~,dataDims]=Advisor.Utils.Eml.getDataTypeFromMnode(data_node,rpi);
        idxNodeDataTypes=arrayfun(@(x)Advisor.Utils.Eml.getDataTypeFromMnode(mt.select(x),rpi),idx_indices,'UniformOutput',false);
        for j=1:numel(idxNodeDataTypes)
            if strcmpi(idxNodeDataTypes{j},'unknown')
                node=mt.select(idx_indices(j));



                if strcmpi(node.kind,'INT')||strcmpi(node.kind,'DOUBLE')...
                    ||strcmpi(node.kind,'COLON')
                    idxNodeDataTypes{j}='int32';
                end
            end
        end
        [isvalid,issue]=isIndexPortsValid(system,idxNodeDataTypes,dataDims,block);
        if~isvalid
            violations=[violations;getViolationInfoFromNode(block,node,DAStudio.message(['ModelAdvisor:hism:hisl_0022_rec_action',num2str(issue)]))];%#ok<AGROW>
        end
    end
end

function violations=checkAlgoSF(system,fl_index,lum_index)
    violations=[];
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    blocksOfInterest=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{fl_index}.Value,inputParams{lum_index}.Value,{'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'},true);
    blocksOfInterest=mdladvObj.filterResultWithExclusion(blocksOfInterest);

    for i=1:length(blocksOfInterest)
        chartObj=blocksOfInterest{i}.Chart;


        tokns=regexp(blocksOfInterest{i}.LabelString,'(\w+\([^\)]*\)|\w+\[[^\]]*\])','tokens');

        for j=1:length(tokns)



            ids=regexp(tokns{j}{1},'[a-zA-Z]\w*','match');


            if isempty(ids)
                continue;
            end


            dataNode=chartObj.find('-isa','Stateflow.Data','Name',ids{1});

            if isempty(dataNode)
                continue;
            elseif numel(dataNode)>1
                dataNode=dataNode(1);
            end
            dtDims=str2double(strsplit(regexprep(dataNode.CompiledSize,'\[|\]',''),','));



            idxNodes=cellfun(@(x)sfGetAppropriateDataObj(x,blocksOfInterest{i}),ids(2:end),'UniformOutput',false);
            idxNodes=idxNodes(~cellfun(@isempty,idxNodes));
            idxNodes=[idxNodes{:}];
            if~iscell(idxNodes)
                idxNodes=num2cell(idxNodes);
            end
            idxNodesType=cellfun(@(x)get(x,'CompiledType'),idxNodes,'UniformOutput',false);

            [isvalid,issue]=isIndexPortsValid(system,idxNodesType,dtDims,chartObj);
            if~isvalid
                vObj=ModelAdvisor.ResultDetail;
                ModelAdvisor.ResultDetail.setData(vObj,'SID',blocksOfInterest{i},'Expression',tokns{j}{1});
                vObj.RecAction=DAStudio.message(['ModelAdvisor:hism:hisl_0022_rec_action',num2str(issue)]);
                violations=[violations;vObj];%#ok<AGROW>
            end
        end

    end

end

function[indexPortsDataType,dataPortDimensions]=getIndexAndDataPortProps(system,block)
    indexPortsDataType='';
    dataPortDimensions=[];
    blockType=get_param(block,'BlockType');
    portHandles=get_param(block,'PortHandles');
    switch blockType
    case 'Assignment'
        if~strcmp(get_param(block,'OutputInitialize'),'Specify size for each dimension in table')
            idxPortIndex=3;
        elseif contains(get_param(block,'IndexOptions'),'(port)')
            idxPortIndex=2;
        else
            return;
        end
        indexPortsDataType=get_param(portHandles.Inport(idxPortIndex:end),'CompiledPortDataType');
        dataPortDimensions=get_param(portHandles.Inport(1),'CompiledPortDimensions');
        dataPortDimensions=dataPortDimensions(2:end);
    case 'MultiPortSwitch'
        indexPortsDataType=get_param(portHandles.Inport(1),'CompiledPortDataType');





        dataPortDimensions=get_param(portHandles.Inport(2:end),'CompiledPortDimensions');
        if~iscell(dataPortDimensions)
            dataPortDimensions=dataPortDimensions(2);
        else
            dataPortDimensions=numel(dataPortDimensions);
        end
    case 'Selector'
        if~contains(get_param(block,'IndexOptions'),'(port)')
            return;
        end
        indexPortsDataType=get_param(portHandles.Inport(2:end),'CompiledPortDataType');
        dataPortDimensions=get_param(portHandles.Inport(1),'CompiledPortDimensions');
        dataPortDimensions=dataPortDimensions(2:end);
    case 'LookupNDDirect'
        if strcmp(get_param(block,'TableIsInput'),'on')

            indexPortsDataType=get_param(portHandles.Inport(1:end-1),'CompiledPortDataType');
            dataPortDimensions=get_param(portHandles.Inport(end),'CompiledPortDimensions');
            dataPortDimensions=dataPortDimensions(2:end);
        else

            indexPortsDataType=get_param(portHandles.Inport(:),'CompiledPortDataType');
            dataPortDimensions=[];
        end
    case 'Interpolation_n-D'
        dataPortDimensions=[];
        if strcmp(get_param(block,'TableSource'),'Dialog')
            indexPortsDataType=get_param(portHandles.Inport(1:2:end),'CompiledPortDataType');
        else
            indexPortsDataType=get_param(portHandles.Inport(1:2:end-1),'CompiledPortDataType');
        end
    end
    indexPortsDataType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,indexPortsDataType);
end


function[isValid,issue]=isIndexPortsValid(system,indexPortsDataType,dataPortDimensions,block)
    isValid=true;
    issue=[];

    if isempty(indexPortsDataType)
        return;
    end


    if~areValidDataTypes(bdroot(system),indexPortsDataType)
        isValid=false;
        issue=1;
        return;
    else
        if isempty(dataPortDimensions)
            isValid=true;
            return;
        end
        if length(dataPortDimensions)==1
            blkType='';
            if ischar(block)
                blkType=get_param(block,'BlockType');
            end


            [~,dtMax]=getMinMax(bdroot(system),indexPortsDataType{1},block);



            if strcmp(blkType,'MultiPortSwitch')&&strcmp(get_param(block,'DataPortForDefault'),'Additional data port')
                isValid=(dataPortDimensions-1<=dtMax);
            else
                isValid=(dataPortDimensions<=dtMax);
            end
            if~isValid
                issue=2;
            end
        else


            if~iscell(indexPortsDataType)
                indexPortsDataType={indexPortsDataType};
            end
            len=min(length(indexPortsDataType),length(dataPortDimensions));
            for i=1:len
                [dtMin,dtMax]=getMinMax(bdroot(system),indexPortsDataType{i},block);
                if~(dataPortDimensions(i)>=dtMin&&dataPortDimensions(i)<=dtMax)
                    isValid=false;
                    issue=2;
                    return;
                end
            end
        end

    end

end

function bResult=areValidDataTypes(system,dataTypes)
    if~iscell(dataTypes)
        dataTypes={dataTypes};
    end
    validDataTypes={'int8','int16','int32','uint8','uint16','uint32'};
    bResult=all(cellfun(@(x)Advisor.Utils.Simulink.isEnumOutDataTypeStr(system,x)||ismember(x,validDataTypes),dataTypes));
end

function[dmin,dmax]=getMinMax(system,dataType,block)
    if startsWith(dataType,'int')||startsWith(dataType,'uint')
        dmin=intmin(dataType);
        dmax=intmax(dataType);
    elseif strcmp(dataType,'double')||strcmp(dataType,'single')
        dmin=realmin(dataType);
        dmax=realmax(dataType);
    else


        dataType=strtrim(strrep(dataType,'Enum:',''));
        enumNames=evalinGlobalScope(system,['enumeration(''',dataType,''');']);


        if ischar(block)||isnumeric(block)
            blkObj=get_param(block,'Object');
        else
            blkObj=block;
        end



        if isprop(blkObj,'DataPortOrder')&&strcmp(blkObj.DataPortOrder,'Specify indices')
            dmin=0;
            dmax=numel(enumNames);
        else
            dmin=min(enumNames);
            dmax=max(enumNames);
        end
    end
end

function sfDataObj=sfGetAppropriateDataObj(varName,sfUsedInObj)

    pObj=sfUsedInObj;
    sfDataObj=pObj.find('-isa','Stateflow.Data','Name',varName);

    while isempty(sfDataObj)&&~isa(pObj,'Stateflow.Chart')
        pObj=pObj.getParent;
        sfDataObj=pObj.find('-depth',1,'-isa','Stateflow.Data','Name',varName);
    end
    if numel(sfDataObj)>1
        sfDataObj=num2cell(sfDataObj);
    end
end


