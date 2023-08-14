function hisl_0073




    rec=getNewCheckObject('mathworks.hism.hisl_0073',false,@hCheckAlgo,'PostCompile');

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
    violationsSL_Warn=[];violationsSL_Pass=[];


    shiftOpBlocks=[
    find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',fl_val,'LookUnderMasks',lum_val,'BlockType','ArithShift');...
    find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',fl_val,'LookUnderMasks',lum_val,'BlockType','SubSystem','MaskType','Bit Shift')...
    ];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    shiftOpBlocks=mdladvObj.filterResultWithExclusion(shiftOpBlocks);

    for i=1:length(shiftOpBlocks)
        compiledPortDataTypes=get_param(shiftOpBlocks{i},'CompiledPortDataTypes');
        if isempty(compiledPortDataTypes)
            continue;
        end
        ipDataTypes=compiledPortDataTypes.Inport;
        baseType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,ipDataTypes{1});
        nt=numerictype(baseType{1});
        dataBitWidth=nt.WordLength;

        if strcmp('ArithShift',get_param(shiftOpBlocks{i},'Blocktype'))
            if strcmp('Dialog',get_param(shiftOpBlocks{i},'BitShiftNumberSource'))
                tempbitShiftVar=get_param(shiftOpBlocks{i},'BitShiftNumber');
                if isnan(abs(str2double(tempbitShiftVar)))
                    bitShiftVar=evalinGlobalScope(system,tempbitShiftVar);
                    if isnumeric(bitShiftVar)
                        bitShiftNumber=bitShiftVar;
                    else
                        bitShiftNumber=bitShiftVar.Value;
                    end
                else
                    bitShiftNumber=abs(str2double(tempbitShiftVar));
                end
            else
                vObj1=ModelAdvisor.ResultDetail;
                vObj1.IsViolation=false;
                vObj1.Description=DAStudio.message('ModelAdvisor:hism:hisl_0073_tip1');
                ModelAdvisor.ResultDetail.setData(vObj1,'SID',shiftOpBlocks{i},'Expression',' ');
                vObj1.Status=DAStudio.message('ModelAdvisor:hism:hisl_0073_warn1');
                vObj1.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0073_rec_action1');
                violationsSL_Pass=[violationsSL_Pass;vObj1];
                continue
            end
        else
            tempbitShiftVar=get_param(shiftOpBlocks{i},'MaskValues');
            if isnan(abs(str2double(tempbitShiftVar{2})))
                bitShiftVar=evalinGlobalScope(system,tempbitShiftVar{2});
                if isnumeric(bitShiftVar)
                    bitShiftNumber=bitShiftVar;
                else
                    bitShiftNumber=bitShiftVar.Value;
                end
            else


                bitShiftNumber=abs(str2double(tempbitShiftVar{2}));
            end
        end

        if bitShiftNumber>=dataBitWidth
            vObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(vObj,'SID',shiftOpBlocks{i},'Expression',' ');
            vObj.Status=DAStudio.message('ModelAdvisor:hism:hisl_0073_warn');
            violationsSL_Warn=[violationsSL_Warn;vObj];%#ok<*AGROW>
        end
    end
    violationsSL=[violationsSL_Warn;violationsSL_Pass];
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
                    violationsSF=[violationsSF;iVerifyShiftC(system,roots{k},obj)];
                elseif Advisor.Utils.Stateflow.isActionLanguageM(chartObj)
                    violationsSF=[violationsSF;iVerifyShiftM(system,roots{k},obj,resolvedSymbolIds)];
                end
            end
        end
    end
end




function violations=iVerifyShiftC(system,ast,sfObj)
    violations=[];
    if(isa(ast,'Stateflow.Ast.ShiftRight')||isa(ast,'Stateflow.Ast.ShiftLeft'))

        l_DataWidth=Advisor.Utils.Stateflow.getDataBitwidth(Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,sfObj.chart));



        if isa(ast.rhs,'Stateflow.Ast.IntegerNum')||isa(ast.rhs,'Stateflow.Ast.FloatNum')
            r_ShiftVal=ast.rhs.value;
        elseif isa(ast.rhs,'Stateflow.Ast.Identifier')
            r_ShiftValTemp=Advisor.Utils.safeEvalinGlobalScope(bdroot(system),ast.rhs.sourceSnippet);
            if~isempty(r_ShiftValTemp)
                if isa(r_ShiftValTemp,'Simulink.Signal')
                    tempFailObj1=ModelAdvisor.ResultDetail;
                    tempFailObj1.IsViolation=false;
                    tempFailObj1.Description=DAStudio.message('ModelAdvisor:hism:hisl_0073_tip1');
                    ModelAdvisor.ResultDetail.setData(tempFailObj1,'SID',sfObj,'Expression',ast.sourceSnippet);
                    tempFailObj1.Status=DAStudio.message('ModelAdvisor:hism:hisl_0073_warn1');
                    tempFailObj1.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0073_rec_action1');
                    violations=[violations;tempFailObj1];
                    r_ShiftVal=NaN;
                else
                    if isnumeric(r_ShiftValTemp)
                        r_ShiftVal=r_ShiftValTemp;
                    else
                        r_ShiftVal=r_ShiftValTemp.Value;
                    end
                end
            else
                tempFailObj1=ModelAdvisor.ResultDetail;
                tempFailObj1.IsViolation=false;
                tempFailObj1.Description=DAStudio.message('ModelAdvisor:hism:hisl_0073_tip1');
                ModelAdvisor.ResultDetail.setData(tempFailObj1,'SID',sfObj,'Expression',ast.sourceSnippet);
                tempFailObj1.Status=DAStudio.message('ModelAdvisor:hism:hisl_0073_warn1');
                tempFailObj1.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0073_rec_action1');
                violations=[violations;tempFailObj1];
                r_ShiftVal=NaN;
            end
        else
            r_ShiftVal=NaN;
        end

        if(isnan(l_DataWidth)||isnan(r_ShiftVal))
            return;
        end

        if(r_ShiftVal>=l_DataWidth)
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet);
            violations=[violations;tempFailObj];
        end
    end


    children=ast.children;
    for i=1:length(children)
        violations=[violations;iVerifyShiftC(system,children{i},sfObj)];
    end
end




function violations=iVerifyShiftM(system,ast,sfObj,resolvedSymbolIds)
    violations=[];
    violations_Warn=[];violations_Pass=[];

    codeFragment=ast.sourceSnippet;

    mtreeObject=Advisor.Utils.Stateflow.createMtreeObject(codeFragment,resolvedSymbolIds);

    comparisonNodes=mtreeObject.mtfind('Fun',{'bitsll','bitsrl','bitshift','bitsra'});
    for index=comparisonNodes.indices
        thisNode=comparisonNodes.select(index);

        inputBitwidth=Advisor.Utils.Stateflow.getDataBitwidth(Advisor.Utils.Stateflow.getDataTypeFromTreeNode(system,thisNode.Parent.Right,resolvedSymbolIds));

        if strcmp(thisNode.Parent.Right.Next.kind,'INT')||strcmp(thisNode.Parent.Right.Next.kind,'DOUBLE')
            shiftVal=str2num(thisNode.Parent.Right.Next.string);%#ok<ST2NM>
        elseif strcmp(thisNode.Parent.Right.Next.kind,'ID')
            shiftValTemp=Advisor.Utils.safeEvalinGlobalScope(bdroot(system),thisNode.Parent.Right.Next.string);
            if~isempty(shiftValTemp)
                if isa(shiftValTemp,'Simulink.Signal')
                    violated_text=ast.sourceSnippet(thisNode.leftposition:thisNode.Parent.rightposition);
                    tempFailObj1=ModelAdvisor.ResultDetail;
                    tempFailObj1.IsViolation=false;
                    tempFailObj1.Description=DAStudio.message('ModelAdvisor:hism:hisl_0073_tip1');
                    ModelAdvisor.ResultDetail.setData(tempFailObj1,'SID',sfObj,'Expression',violated_text);
                    tempFailObj1.Status=DAStudio.message('ModelAdvisor:hism:hisl_0073_warn1');
                    tempFailObj1.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0073_rec_action1');
                    violations_Pass=[violations_Pass;tempFailObj1];
                    shiftVal=NaN;
                else
                    if isnumeric(shiftValTemp)
                        shiftVal=shiftValTemp;
                    else
                        shiftVal=shiftValTemp.Value;
                    end
                end
            else
                violated_text=ast.sourceSnippet(thisNode.leftposition:thisNode.Parent.rightposition);
                tempFailObj1=ModelAdvisor.ResultDetail;
                tempFailObj1.IsViolation=false;
                tempFailObj1.Description=DAStudio.message('ModelAdvisor:hism:hisl_0073_tip1');
                ModelAdvisor.ResultDetail.setData(tempFailObj1,'SID',sfObj,'Expression',violated_text);
                tempFailObj1.Status=DAStudio.message('ModelAdvisor:hism:hisl_0073_warn1');
                tempFailObj1.RecAction=DAStudio.message('ModelAdvisor:hism:hisl_0073_rec_action1');
                violations_Pass=[violations_Pass;tempFailObj1];
                shiftVal=NaN;
            end
        else
            shiftVal=NaN;
        end


        if isnan(inputBitwidth)||isnan(shiftVal)
            continue;
        end

        if shiftVal>=inputBitwidth
            violated_text=ast.sourceSnippet(thisNode.leftposition:thisNode.Parent.rightposition);
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',violated_text);
            violations_Warn=[violations_Warn;tempFailObj];
        end
    end
    violations=[violations_Warn;violations_Pass];
end


function violationsML=hCheckAlgoML(system,fl_val,lum_val,checkExternalMLFiles)
    violationsML=[];
    violationsML_Warn=[];violationsML_Pass=[];
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
            rp=Advisor.Utils.Eml.getEmlReport(mlfObjs{mlfCnt});
        else
            parent=Advisor.Utils.Eml.getEMLParentOfReferencedFile(mlfObjs{mlfCnt});
            if~isempty(parent)
                rp=Advisor.Utils.Eml.getEmlReport(parent);
            end
        end

        if isempty(rp)
            continue;
        end

        if isa(mlfObjs{mlfCnt},'struct')
            mt=mtree(mlfObjs{mlfCnt}.FileName,'-cell','-file');
        else
            mt=mtree(mlfObjs{mlfCnt}.Script,'-cell');
        end

        [bValid,tree_error]=Advisor.Utils.isValidMtree(mt);
        if~bValid
            vObj=ModelAdvisor.ResultDetail;
            if isa(mlfObjs{mlfCnt},'struct')
                ModelAdvisor.ResultDetail.setData(vObj,'FileName',mlfObjs{mlfCnt}.FileName,'Expression',tree_error.message);
            else
                ModelAdvisor.ResultDetail.setData(vObj,'SID',mlfObjs{mlfCnt},'Expression',tree_error.message);
            end
            vObj.RecAction=DAStudio.message('ModelAdvisor:hism:common_matlab_parse_error_rec_action');
            vObj.Status=DAStudio.message('ModelAdvisor:hism:himl_warn_syntax');
            violationsML=[violationsML;vObj];
            continue;
        end

        opNodes=mt.mtfind('Kind','CALL');
        indices=opNodes.indices;
        rpi=rp.inference;

        for cnt=1:numel(indices)
            node=opNodes.select(indices(cnt));
            callStr=stringvals(node.Left);
            switch(callStr{1})
            case{'bitsll','bitsrl','bitsra','bitshift'}
                dataType=Advisor.Utils.Eml.getDataTypeFromMnode(node.Right,rpi);
                nodeKind=node.Right.kind;

                if strcmpi(dataType,'unknown')&&(strcmpi(nodeKind,'INT')||strcmpi(nodeKind,'DOUBLE')||strcmpi(nodeKind,'CALL')||strcmpi(nodeKind,'ID')||strcmpi(nodeKind,'LB'))
                    dataType='double';
                end

                baseType=Advisor.Utils.Simulink.outDataTypeStr2baseType(system,dataType);
                nt=numerictype(baseType{1});
                dataBitWidth=nt.WordLength;

                if strcmp(node.Right.Next.kind,'INT')||strcmp(node.Right.Next.kind,'DOUBLE')
                    shiftVal=str2num(stringval(node.Right.Next));%#ok<ST2NM>
                elseif strcmp(node.Right.Next.kind,'ID')
                    shiftValTemp=Advisor.Utils.safeEvalinGlobalScope(bdroot(system),stringval(node.Right.Next));
                    if~isempty(shiftValTemp)
                        if isa(shiftValTemp,'Simulink.Signal')
                            vObj1=getViolationInfoFromNode(mlfObjs{mlfCnt},node,DAStudio.message('ModelAdvisor:hism:hisl_0073_rec_action1'));
                            vObj1.IsViolation=false;
                            vObj1.Status=DAStudio.message('ModelAdvisor:hism:hisl_0073_warn1');
                            vObj1.Description=DAStudio.message('ModelAdvisor:hism:hisl_0073_tip1');
                            violationsML_Pass=[violationsML_Pass;vObj1];
                            shiftVal=NaN;
                        else
                            if isnumeric(shiftValTemp)
                                shiftVal=shiftValTemp;
                            else
                                shiftVal=shiftValTemp.Value;
                            end
                        end
                    else
                        vObj1=getViolationInfoFromNode(mlfObjs{mlfCnt},node,DAStudio.message('ModelAdvisor:hism:hisl_0073_rec_action1'));
                        vObj1.IsViolation=false;
                        vObj1.Status=DAStudio.message('ModelAdvisor:hism:hisl_0073_warn1');
                        vObj1.Description=DAStudio.message('ModelAdvisor:hism:hisl_0073_tip1');
                        violationsML_Pass=[violationsML_Pass;vObj1];
                        shiftVal=NaN;
                    end
                else
                    shiftVal=NaN;
                end

                if isnan(shiftVal)
                    continue;
                end
                if shiftVal>=dataBitWidth
                    vObj=getViolationInfoFromNode(mlfObjs{mlfCnt},node,DAStudio.message('ModelAdvisor:hism:hisl_0073_rec_action'));
                    violationsML_Warn=[violationsML_Warn;vObj];
                end
            otherwise
                continue;
            end
        end
    end
    violationsML=[violationsML_Warn;violationsML_Pass];
end

