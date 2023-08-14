function hisl_0019




    rec=getNewCheckObject('mathworks.hism.hisl_0019',false,@hCheckAlgo,'PostCompile');

    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams(1);
    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});
end


function FailingObjs=hCheckAlgo(system)
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;
    checkExternalMLFiles=inputParams{1}.Value;
    fl_val=inputParams{2}.Value;
    lum_val=inputParams{3}.Value;
    violationsSL=hCheckAlgoSL(system,fl_val,lum_val);


    if(Advisor.Utils.license('test','stateflow'))
        violationsSF=hCheckAlgoSF(system,fl_val,lum_val);
        violationsML=hCheckAlgoML(system,fl_val,lum_val,checkExternalMLFiles);
        FailingObjs=[violationsSL;violationsSF';violationsML];
    else
        FailingObjs=violationsSL;
    end

end

function violationsSL=hCheckAlgoSL(system,fl_val,lum_val)
    violationsSL=[];


    commonArgs={'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',fl_val,...
    'RegExp','on',...
    'LookUnderMasks',lum_val};

    bitOpBlocks=[...
    find_system(system,commonArgs{:},'BlockType','S-Function','MaskType','Bitwise Operator');...
    find_system(system,commonArgs{:},'BlockType','SubSystem','MaskType','\<Bit Clear\>|\<Bit Set\>|\<Extract Bits\>|\<Bit Shift\>');...
    find_system(system,commonArgs{:},'BlockType','ArithShift');...
    ];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    bitOpBlocks=mdladvObj.filterResultWithExclusion(bitOpBlocks);

    for i=1:length(bitOpBlocks)
        compiledPortDataTypes=get_param(bitOpBlocks{i},'CompiledPortDataTypes');
        if isempty(compiledPortDataTypes)
            continue;
        end
        ipDataTypes=compiledPortDataTypes.Inport;


        baseType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,ipDataTypes{1});


        if any(strcmp(baseType,{'int8','int16','int32','int64','double','single'}))||contains(baseType,'fixdt(1')||startsWith(baseType,'sfix')
            vObj=ModelAdvisor.ResultDetail;
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0019_warn_sl');
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0019_rec_action_sl');
            ModelAdvisor.ResultDetail.setData(vObj,'SID',bitOpBlocks{i});
            violationsSL=[violationsSL;vObj];
        end
    end
end

function violationsML=hCheckAlgoML(system,fl_val,lum_val,checkExternalMLFiles)
    violationsML=[];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mlfObjs=Advisor.Utils.getAllMATLABFunctionBlocks(system,fl_val,lum_val);
    mlfObjs=mdladvObj.filterResultWithExclusion(mlfObjs);

    if checkExternalMLFiles
        allMLObjs=Advisor.MATLABFileDependencyService.getInstance.getRelevantEMLObjs();
        extMLFiles=allMLObjs(cellfun(@(x)isa(x,'struct'),allMLObjs));
        mlfObjs=[mlfObjs;extMLFiles];
    end
    for mlfCnt=1:numel(mlfObjs)
        rp=[];


        if~isa(mlfObjs{mlfCnt},'struct')
            path_to_bit_shift='hdlsllib/Logic and BitOperations/Bit Shift/bit_shift';
            current_blk_path=regexprep(mlfObjs{mlfCnt}.Path,'\n','');

            if strcmpi(path_to_bit_shift,current_blk_path)
                continue;
            end
        end

        if isa(mlfObjs{mlfCnt},'struct')
            parent=Advisor.Utils.Eml.getEMLParentOfReferencedFile(mlfObjs{mlfCnt});
            if~isempty(parent)
                rp=Advisor.Utils.Eml.getEmlReport(parent);
            end
        else
            rp=Advisor.Utils.Eml.getEmlReport(mlfObjs{mlfCnt});
        end

        if isempty(rp)
            continue;
        end

        if isa(mlfObjs{mlfCnt},'struct')
            mt=mtree(mlfObjs{mlfCnt}.FileName,'-cell','-file');
        else
            mt=mtree(mlfObjs{mlfCnt}.Script,'-cell');
        end

        opNodes=mt.mtfind('Kind','CALL');
        indices=opNodes.indices;
        rpi=rp.inference;

        for cnt=1:numel(indices)
            node=opNodes.select(indices(cnt));
            callStr=node.Left.tree2str;
            containsViolation=false;
            switch(callStr)
            case{'bitand','bitor','bitxor'}
                lDataType=Advisor.Utils.Eml.getDataTypeFromMnode(node.Right,rpi);
                rDataType=Advisor.Utils.Eml.getDataTypeFromMnode(node.Right.Next,rpi);
                lNodeKind=node.Right.kind;
                rNodeKind=node.Right.Next.kind;


                if strcmpi(lDataType,'unknown')&&(strcmpi(lNodeKind,'INT')||strcmpi(lNodeKind,'DOUBLE'))
                    lDataType='double';
                end
                if strcmpi(rDataType,'unknown')&&(strcmpi(rNodeKind,'INT')||strcmpi(rNodeKind,'DOUBLE'))
                    rDataType='double';
                end
                containsViolation=checkForViolation(node.Right.Next.Next,lDataType)||...
                checkForViolation(node.Right.Next.Next,rDataType);
            case{'bitget','bitshift'}
                dataType=Advisor.Utils.Eml.getDataTypeFromMnode(node.Right,rpi);
                nodeKind=node.Right.kind;

                if strcmpi(dataType,'unknown')&&(strcmpi(nodeKind,'INT')||strcmpi(nodeKind,'DOUBLE'))
                    dataType='double';
                end
                containsViolation=checkForViolation(node.Right.Next.Next,dataType);
            case{'bitsll','bitsrl','bitsra','swapbytes'}
                dataType=Advisor.Utils.Eml.getDataTypeFromMnode(node.Right,rpi);
                nodeKind=node.Right.kind;

                if strcmpi(dataType,'unknown')&&(strcmpi(nodeKind,'INT')||strcmpi(nodeKind,'DOUBLE'))
                    dataType='double';
                end
                if isaSignedDataType(dataType)
                    containsViolation=true;
                end
            case 'bitcmp'
                dataType=Advisor.Utils.Eml.getDataTypeFromMnode(node.Right,rpi);
                nodeKind=node.Right.kind;
                if strcmpi(dataType,'unknown')&&(strcmpi(nodeKind,'INT')||strcmpi(nodeKind,'DOUBLE'))
                    dataType='double';
                end
                containsViolation=checkForViolation(node.Right.Next,dataType);
            case 'bitset'
                dataType=Advisor.Utils.Eml.getDataTypeFromMnode(node.Right,rpi);
                nodeKind=node.Right.kind;
                if strcmpi(dataType,'unknown')&&(strcmpi(nodeKind,'INT')||strcmpi(nodeKind,'DOUBLE'))
                    dataType='double';

                elseif strcmpi(dataType,'unknown')&&strcmpi(node.Right.kind,'CALL')
                    if any(strcmpi(node.Right.Left.string,{'int8','int16','int32','int64','uint8','uint16','uint32','uint64'}))
                        dataType=node.Right.Left.string;
                    end
                end
                containsViolation=checkForViolationInBitset(node,dataType);
            otherwise
                continue;
            end

            if containsViolation
                vObj=getViolationInfoFromNode(mlfObjs{mlfCnt},node,DAStudio.message('ModelAdvisor:hism:hisl_0019_rec_action_ml_sf'));
                vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0019_warn_ml_sf');
                violationsML=[violationsML;vObj];
            end
        end
    end
end



function containsViolation=checkForViolation(node,dataType)
    containsViolation=false;

    if isempty(node)

        if strcmpi(dataType,'double')
            return;
        end

        if isaSignedDataType(dataType)
            containsViolation=true;
        end
    else
        if strcmpi(node.kind,'CHARVECTOR')
            assumedType=node.string;


            if~any(strcmpi(extractBetween(assumedType,2,length(assumedType)-1),{'uint8','uint16','uint32','uint64'}))
                containsViolation=true;
            end
        elseif isaSignedDataType(dataType)
            containsViolation=true;
        end
    end
end



function containsViolation=checkForViolationInBitset(node,dataType)
    assumedTypePresent=false;
    containsViolation=false;

    if~isempty(node.Right.Next.Next)&&strcmpi(node.Right.Next.Next.kind,'CHARVECTOR')
        assumedTypePresent=true;
        assumedType=node.Right.Next.Next.string;


        if~any(strcmpi(extractBetween(assumedType,2,length(assumedType)-1),{'uint8','uint16','uint32','uint64'}))
            containsViolation=true;
        end

    elseif~isempty(node.Right.Next.Next.Next)&&strcmpi(node.Right.Next.Next.Next.kind,'CHARVECTOR')
        assumedTypePresent=true;
        assumedType=node.Right.Next.Next.Next.string;


        if~any(strcmpi(extractBetween(assumedType,2,length(assumedType)-1),{'uint8','uint16','uint32','uint64'}))
            containsViolation=true;
        end
    end

    if~assumedTypePresent
        if strcmpi(dataType,'double')
            return;
        elseif isaSignedDataType(dataType)
            containsViolation=true;
        end
    end
end

function failingObjsSF=hCheckAlgoSF(system,fl_val,lum_val)
    failingObjsSF=[];

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    sfObjs=Advisor.Utils.Stateflow.sfFindSys(system,fl_val,lum_val,{'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'},true);
    sfObjs=mdlAdvObj.filterResultWithExclusion(sfObjs);

    for i=1:length(sfObjs)

        chartObj=sfObjs{i}.Chart;

        [asts,resolvedId]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(sfObjs{i});
        if isempty(asts)
            continue;
        end


        sections=asts.sections;
        for j=1:length(sections)
            roots=sections{j}.roots;
            for k=1:length(roots)
                if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                    failingObjsSF=[failingObjsSF,iVerifyBitwiseOps(system,sfObjs{i},roots{k})];%#ok<AGROW>
                else
                    failingObjsSF=[failingObjsSF,iVerifyBitwiseOpsM(system,sfObjs{i},roots{k},resolvedId)];%#ok<AGROW>
                end
            end
        end
    end
end

function violations=iVerifyBitwiseOps(system,sfObj,ast)

    violations=[];
    chartObj=sfObj.Chart;
    isViolation=false;
    if~chartObj.EnableBitOps
        return;
    end

    if isa(ast,'Stateflow.Ast.BitAnd')||isa(ast,'Stateflow.Ast.BitOr')||isa(ast,'Stateflow.Ast.BitXor')
        lDataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,chartObj);
        rDataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.rhs,chartObj);
        isViolation=isaSignedDataType(lDataType)||isaSignedDataType(rDataType);
    elseif isa(ast,'Stateflow.Ast.ShiftLeft')||isa(ast,'Stateflow.Ast.ShiftRight')
        lDataType=Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,chartObj);
        isViolation=isaSignedDataType(lDataType);
    elseif isa(ast,'Stateflow.Ast.Negate')
        dType=Advisor.Utils.Stateflow.getAstDataType(system,ast.children{1},chartObj);
        isViolation=isaSignedDataType(dType);
    end

    if isViolation
        tempFailObj=ModelAdvisor.ResultDetail;
        ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet);
        tempFailObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0019_warn_ml_sf');
        tempFailObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0019_rec_action_ml_sf');
        violations=tempFailObj;
    end

    children=ast.children;
    for i=1:length(children)
        violations=[violations,iVerifyBitwiseOps(system,sfObj,children{i})];%#ok<AGROW>
    end
end

function violationsSF=iVerifyBitwiseOpsM(system,sfObj,ast,resolvedSymbolIds)

    violationsSF=[];

    codeFragment=ast.sourceSnippet;

    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(codeFragment,resolvedSymbolIds);

    nodes=mtreeObject.mtfind('Fun',{'bitsll','bitsrl','bitsra','bitshift','bitand','bitor','bitxor','bitcmp','bitset','bitget','swapbytes'});
    for index=nodes.indices
        thisNode=nodes.select(index);
        containsViolation=false;
        switch(thisNode.string)
        case{'bitand','bitor','bitxor'}
            lDataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds);
            rDataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right.Next,resolvedSymbolIds);
            containsViolation=checkForViolation(thisNode.Parent.Right.Next.Next,lDataType)||...
            checkForViolation(thisNode.Parent.Right.Next.Next,rDataType);
        case{'bitshift','bitget'}
            dataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds);
            containsViolation=checkForViolation(thisNode.Parent.Right.Next.Next,dataType);
        case{'bitsll','bitsrl','bitsra','swapbytes'}
            dataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds);
            containsViolation=isaSignedDataType(dataType);
        case 'bitcmp'
            dataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds);
            containsViolation=checkForViolation(thisNode.Parent.Next,dataType);
        case 'bitset'
            dataType=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds);
            containsViolation=checkForViolationInBitset(thisNode.Parent,dataType);
        otherwise
            continue;
        end

        if containsViolation
            higlightedText=Advisor.Utils.Naming.formatFlaggedName(...
            codeFragment,false,...
            [thisNode.leftposition,thisNode.Parent.rightposition],'');
            MAText=ModelAdvisor.Text(higlightedText);
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',MAText.emitHTML);
            tempFailObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0019_warn_ml_sf');
            tempFailObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0019_rec_action_ml_sf');
            violationsSF=[violationsSF,tempFailObj];%#ok<AGROW>
        end
    end

end

function bResult=isaSignedDataType(datatype)
    bResult=any(strcmp(datatype,{'int8','int16','int32','int64','double','single'}))||startsWith(datatype,'fixdt(1')||startsWith(datatype,'sfix');
end
