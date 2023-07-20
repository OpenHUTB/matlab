function hisf_0065

    rec=getNewCheckObject('mathworks.hism.hisf_0065',false,@hCheckAlgo,'PostCompile');
    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});

    inputParamList{1}=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[1,2];
    inputParamList{end}.Value='on';
    inputParamList{end+1}=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    inputParamList{end}.RowSpan=[1,1];
    inputParamList{end}.ColSpan=[3,4];
    inputParamList{end}.Value='all';

    rec.setInputParametersLayoutGrid([1,4]);
    rec.setInputParameters(inputParamList);

    rec.setLicense({HighIntegrity_License,'Stateflow'});

    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{do178b_group,iec61508_group});

end




function violations=hCheckAlgo(system)
    violations=[];

    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    inputParams=mdladvObj.getInputParameters;

    allSfObjs=Advisor.Utils.Stateflow.sfFindSys(system,inputParams{1}.Value,inputParams{2}.Value,{'-isa','Stateflow.State','-or','-isa','Stateflow.Transition'},true);
    allSfObjs=mdladvObj.filterResultWithExclusion(allSfObjs);

    for i=1:numel(allSfObjs)
        obj=allSfObjs{i};
        chartObj=obj.chart;
        asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(obj);
        if isempty(asts)
            continue;
        end


        sections=asts.sections;
        for j=1:length(sections)
            roots=sections{j}.roots;
            for k=1:length(roots)
                if Advisor.Utils.Stateflow.isActionLanguageC(chartObj)
                    violations=[violations;iVerifyShiftC(system,roots{k},obj)];%#ok<AGROW>                
                end
            end
        end
    end
end




function violations=iVerifyShiftC(system,ast,sfObj)
    violations=[];

    if isa(ast,'Stateflow.Ast.EqualAssignment')&&IsArithOp(ast.rhs)

        Flag=false;
        nanFlag=false;
        op_l_dataType=Advisor.Utils.Stateflow.getAstDataType...
        (system,ast.rhs.lhs,sfObj.chart);
        op_r_dataType=Advisor.Utils.Stateflow.getAstDataType...
        (system,ast.rhs.rhs,sfObj.chart);

        l_datawidth=Advisor.Utils.Stateflow.getDataBitwidth...
        (Advisor.Utils.Stateflow.getAstDataType(system,ast.lhs,sfObj.chart));
        r_datawidth=Advisor.Utils.Stateflow.getDataBitwidth...
        (Advisor.Utils.Stateflow.getAstDataType(system,ast.rhs,sfObj.chart));


        if contains(op_l_dataType,'fix')||...
            contains(op_l_dataType,'flt')||...
            contains(op_r_dataType,'fix')||...
            contains(op_r_dataType,'flt')||...
            l_datawidth~=r_datawidth
            Flag=true;

        elseif strcmp(op_r_dataType,'unknown')||...
            strcmp(op_l_dataType,'unknown')
            nanFlag=true;
        end

        if nanFlag
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',ast.treeStart,'TextEnd',ast.treeEnd);
            tempFailObj.IsViolation=false;
            tempFailObj.Status=DAStudio.message('ModelAdvisor:hism:hisf_0065_unknown_status');
            tempFailObj.RecAction=DAStudio.message('ModelAdvisor:hism:hisf_0065_unknown_rec_action');
            tempFailObj.Description='IGNORE';
            violations=[violations;tempFailObj];
        end

        if Flag
            tempFailObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempFailObj,'SID',sfObj,'Expression',ast.sourceSnippet,'TextStart',ast.treeStart,'TextEnd',ast.treeEnd);
            violations=[violations;tempFailObj];
        end
    end
end




function booleanResult=IsArithOp(ast)

    switch class(ast)
    case{'Stateflow.Ast.Plus','Stateflow.Ast.Minus','Stateflow.Ast.Times','Stateflow.Ast.Divide','Stateflow.Ast.ShiftRight','Stateflow.Ast.ShiftLeft'}
        booleanResult=true;
    otherwise
        booleanResult=false;
    end
end