function hisl_0016




    rec=getNewCheckObject('mathworks.hism.hisl_0016',false,@hCheckAlgo,'PostCompile');

    rec.setReportStyle('ModelAdvisor.Report.SmartStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.SmartStyle'});

    rec.PreCallbackHandle=@Advisor.MATLABFileDependencyService.initialize;
    rec.PostCallbackHandle=@Advisor.MATLABFileDependencyService.reset;

    inputParamList=Advisor.Utils.Eml.getEMLStandardInputParams(1);

    rec.setInputParametersLayoutGrid([2,4]);
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
        FailingObjs=[violationsSL;violationsSF;violationsML];
    else
        FailingObjs=violationsSL;
    end

end


function violationsSL=hCheckAlgoSL(system,fl_val,lum_val)
    violationsSL=[];
    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);





    commonArgs={'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,...
    'FollowLinks',fl_val,...
    'LookUnderMasks',lum_val};

    relBlocks=find_system(system,commonArgs{:},'BlockType','RelationalOperator');
    CCBlocks=find_system(system,commonArgs{:},'BlockType','SubSystem','MaskType','Compare To Constant');
    CZBlocks=find_system(system,commonArgs{:},'BlockType','SubSystem','MaskType','Compare To Zero');
    DCBlocks=find_system(system,commonArgs{:},'BlockType','SubSystem','MaskType','Detect Change');
    SignBlocks=find_system(system,commonArgs{:},'BlockType','Signum');
    relBlocks=[relBlocks;CCBlocks;CZBlocks;DCBlocks;SignBlocks];
    relBlocks=mdlAdvObj.filterResultWithExclusion(relBlocks);
    relBlocks=Advisor.Utils.filterBuiltInBlocks(relBlocks);

    for i=1:length(relBlocks)
        portTypes=get_param(relBlocks{i},'CompiledPortDataTypes');
        if isempty(portTypes)
            continue;
        end
        inputType=portTypes.Inport;
        inputType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,inputType);

        if any(ismember(inputType,{'double','single'}))
            if strcmp(get_param(relBlocks{i},'BlockType'),'RelationalOperator')
                isIpTypeCorrect=~any(strcmp(get_param(relBlocks{i},'Operator'),{'==','~='}));
            elseif strcmp(get_param(relBlocks{i},'BlockType'),'SubSystem')&&any(strcmp(get_param(relBlocks{i},'MaskType'),{'Compare To Constant','Compare To Zero'}))
                isIpTypeCorrect=~(any(strcmp(get_param(relBlocks{i},'relop'),{'==','~='})));
            else
                isIpTypeCorrect=false;
            end
        else
            isIpTypeCorrect=true;
        end

        if~isIpTypeCorrect
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',relBlocks{i});
            tempFailObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0016_rec_action');
            tempFailObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0016_warn_blk');
            violationsSL=[violationsSL;tempFailObj];
        end

    end



    ifBlocks=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',fl_val,'LookUnderMasks',lum_val,'BlockType','If');
    ifBlocks=mdlAdvObj.filterResultWithExclusion(ifBlocks);

    for i=1:numel(ifBlocks)
        if checkIfBlock(ifBlocks{i})
            tempFailObj1=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj1,'SID',ifBlocks{i});
            tempFailObj1.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0016_rec_action2');
            tempFailObj1.Description=DAStudio.message('ModelAdvisor:hism:hisl_0016_description2');
            tempFailObj1.Status=DAStudio.message('ModelAdvisor:hism:hisl_0016_warn2');
            violationsSL=[violationsSL;tempFailObj1];
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


    for cnt=1:length(mlfObjs)
        rp='';
        if~isempty(mlfObjs{cnt})

            if isa(mlfObjs{cnt},'struct')
                mt=mtree(mlfObjs{cnt}.FileName,'-cell','-file');


                parentObj=Advisor.Utils.Eml.getEMLParentOfReferencedFile(mlfObjs{cnt});
                if~isempty(parentObj)
                    rp=Advisor.Utils.Eml.getEmlReport(parentObj);
                end
            else
                mt=mtree(mlfObjs{cnt}.Script,'-cell');
                rp=Advisor.Utils.Eml.getEmlReport(mlfObjs{cnt});
            end

            if isempty(rp)
                continue;
            end

            rpi=rp.inference;

            [bValid,tree_error]=Advisor.Utils.isValidMtree(mt);
            if~bValid
                vObj1=ModelAdvisor.ResultDetail;
                if isa(mlfObjs{cnt},'struct')
                    ModelAdvisor.ResultDetail.setData(vObj1,'FileName',mlfObjs{cnt}.FileName,'Expression',tree_error.message);
                else
                    ModelAdvisor.ResultDetail.setData(vObj1,'SID',mlfObjs{cnt},'Expression',tree_error.message);
                end
                vObj1.RecAction=DAStudio.message('ModelAdvisor:hism:common_matlab_parse_error_rec_action');
                vObj1.Status=DAStudio.message('ModelAdvisor:hism:himl_warn_syntax');
                violationsML=[violationsML;vObj1];
                continue;
            end


            opNodes=mt.mtfind('Kind',{'EQ','NE'});

            fOpNodes=mt.mtfind('Kind',{'CALL'},'Left.String',{'eq','ne'});
            indices=[opNodes.indices,fOpNodes.indices];

            for i=1:length(indices)
                node=mt.select(indices(i));


                if strcmp(node.kind,'CALL')
                    lNode=node.Right;
                    rNode=node.Right.Next;
                else
                    lNode=node.Left;
                    rNode=node.Right;
                end

                lDataType=Advisor.Utils.Eml.getDataTypeFromMnode(lNode,rpi);
                rDataType=Advisor.Utils.Eml.getDataTypeFromMnode(rNode,rpi);



                if strcmp(lDataType,'unknown')||strcmp(rDataType,'unknown')
                    continue;
                end


                if strcmp(lDataType,'double')||strcmp(rDataType,'double')||strcmp(lDataType,'single')||strcmp(rDataType,'single')
                    vObj=getViolationInfoFromNode(mlfObjs{cnt},node,DAStudio.message('ModelAdvisor:hism:hisl_0016_rec_action'));
                    violationsML=[violationsML;vObj];%#ok<*AGROW>
                end
            end
        end
    end

end


function violationsSF=hCheckAlgoSF(system,fl_val,lum_val)
    violationsSF=[];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    allSfObjs=Advisor.Utils.Stateflow.sfFindSys(system,fl_val,lum_val,{'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'},true);
    allSfObjs=mdladvObj.filterResultWithExclusion(allSfObjs);

    for i=1:numel(allSfObjs)
        obj=allSfObjs{i};
        chartObj=obj.chart;
        [asts,resolvedSymbolIds]=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
        if isempty(asts)
            continue;
        end


        sections=asts.sections;
        for j=1:length(sections)
            roots=sections{j}.roots;
            for k=1:length(roots)
                if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                    violationsSF=[violationsSF;locVerifyC(system,roots{k},obj)];
                elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                    violationsSF=[violationsSF;locVerifyM(system,roots{k},obj,resolvedSymbolIds)];
                end
            end
        end
    end
end

function violations=locVerifyC(system,ast,sfObj)
    violations=[];


    if isa(ast,'Stateflow.Ast.IsEqual')||isa(ast,'Stateflow.Ast.IsNotEqual')||isa(ast,'Stateflow.Ast.NegEqual')
        [l_DataType,~]=Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,sfObj.chart);
        [r_DataType,~]=Advisor.Utils.Stateflow.getAstDataType(system,ast.rhs,sfObj.chart);



        if(strcmp(l_DataType,'unknown')||strcmp(r_DataType,'unknown'))
            return;
        end
        if any(strcmp(l_DataType,{'single','double'}))||any(strcmp(r_DataType,{'single','double'}))
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',ast.treeStart,'TextEnd',ast.treeEnd);
            violations=[violations;tempFailObj];
        end
    end


    children=ast.children;
    for i=1:length(children)
        violations=[violations;locVerifyC(system,children{i},sfObj)];
    end

end

function violations=locVerifyM(system,ast,sfObj,resolvedSymbolIds)

    violations=[];
    codeFragment=ast.sourceSnippet;

    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(...
    codeFragment,resolvedSymbolIds);

    comparisonNodes=mtreeObject.mtfind('Kind',{'EQ','NE'});

    for index=comparisonNodes.indices
        thisNode=comparisonNodes.select(index);

        [leftType,~]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Left,resolvedSymbolIds);
        [rightType,~]=Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Right,resolvedSymbolIds);

        if strcmp(leftType,'unknown')||strcmp(rightType,'unknown')
            return;
        end

        if strcmp(leftType,'single')||strcmp(leftType,'double')||strcmp(rightType,'single')||strcmp(rightType,'double')
            leftIndex=ast.treeStart+thisNode.lefttreepos-1;
            rightIndex=ast.treeStart+thisNode.righttreepos-1;
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',leftIndex,'TextEnd',rightIndex);
            violations=[violations;tempFailObj];
        end
    end
end



function isFloatingPtEquality=checkIfBlock(ifBlock)

    isFloatingPtEquality=false;


    pHandles=get_param(ifBlock,'PortHandles');
    ipHandles=pHandles.Inport;
    ipPorts=length(ipHandles);





    dtFloating=false;
    for i=1:length(ipHandles)
        if strcmp(get_param(ipHandles(i),'CompiledPortDataType'),'double')||...
            strcmp(get_param(ipHandles(i),'CompiledPortDataType'),'single')
            dtFloating=true;
            break;
        end
    end

    if dtFloating

        ifExp=get_param(ifBlock,'IfExpression');
        isFloatingPtEqualityIfExp=checkExp(ifExp,ipPorts);


        elseifExp=get_param(ifBlock,'elseIfExpressions');
        elseifExpList=strsplit(elseifExp,',');
        isFloatingPtEqualityElseIfExp=false;
        for i=1:length(elseifExpList)
            isFloatingPtEqualityElseIfExp=checkExp(elseifExpList{i},ipPorts);
            if isFloatingPtEqualityElseIfExp
                break;
            end
        end
        isFloatingPtEquality=isFloatingPtEqualityElseIfExp||isFloatingPtEqualityIfExp;
    end
end

function isFloatingPtEquality=checkExp(Exp,ipPorts)
    if isempty(Exp)
        isFloatingPtEquality=false;
        return;
    end





    allOperators={'LT','GT','LE','GE','EQ','NE','AND','OR','NOT'};
    isFloatingPtEquality=false;
    operators={'EQ','NE','AND','OR','NOT'};

    T=mtree(strrep(Exp,' ',''));


    expressionHasNoOperators=true;

    for i=1:length(allOperators)
        opNodes=mtfind(T,'Kind',allOperators{i});
        if opNodes.count~=0
            expressionHasNoOperators=false;



            if any(strcmp(operators,allOperators{i}))


                isFloatingPtEquality=checkTree(opNodes,ipPorts,allOperators{i});

                if isFloatingPtEquality


                    break;
                end
            end
        end
    end

    if expressionHasNoOperators
        isFloatingPtEquality=true;
    end
end


function isFloatingPtEquality=checkTree(opNodes,ipPorts,operator)
    isFloatingPtEquality=false;


    numNodes=opNodes.count;
    nodeIndices=opNodes.indices;

    for N=1:numNodes
        opNode=opNodes.select(nodeIndices(N));

        if strcmp(operator,'NOT')
            if~isempty(opNode)
                while(strcmp(opNode.Arg.kind,'PARENS'))
                    opNode=opNode.Arg;
                end
                notArg=mtfind(opNode.Arg,'Kind','CALL');

                for k=1:length(notArg.Left.strings)
                    for j=1:ipPorts
                        if strcmp(notArg.Left.strings{k},['u',num2str(j)])
                            isFloatingPtEquality=true;
                            break;
                        end
                    end
                end
            end
            if isFloatingPtEquality
                break;
            end
        end

        if~isempty(opNode)
            LeftNode=opNode.Left;
            RightNode=opNode.Right;
            while LeftNode.count==1&&(strcmp(LeftNode.kind,'PARENS')||strcmp(LeftNode.kind,'UMINUS')...
                ||strcmp(LeftNode.kind,'UPLUS'))
                LeftNode=LeftNode.Arg;
            end
            while RightNode.count==1&&(strcmp(RightNode.kind,'PARENS')||strcmp(RightNode.kind,'UMINUS')...
                ||strcmp(RightNode.kind,'UPLUS'))
                RightNode=RightNode.Arg;
            end
            leftNode=mtfind(LeftNode,'Kind','CALL');
            rightNode=mtfind(RightNode,'Kind','CALL');
            if~isempty(leftNode)
                for k=1:length(leftNode.Left.strings)
                    for j=1:ipPorts
                        if strcmp(leftNode.Left.strings{k},['u',num2str(j)])
                            isFloatingPtEquality=true;
                            break;
                        end
                    end
                end
            end
            if~isFloatingPtEquality
                if~isempty(rightNode)
                    for k=1:length(rightNode.Left.strings)
                        for j=1:ipPorts
                            if strcmp(rightNode.Left.strings{k},['u',num2str(j)])
                                isFloatingPtEquality=true;
                                break;
                            end
                        end
                    end
                end
            end
        end

        if isFloatingPtEquality
            break;
        end
    end
end

