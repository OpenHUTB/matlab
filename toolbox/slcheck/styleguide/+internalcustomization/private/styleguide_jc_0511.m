function styleguide_jc_0511()




    rec=ModelAdvisor.Check('mathworks.maab.jc_0511');
    rec.Title=DAStudio.message('ModelAdvisor:styleguide:jc0511Title');
    rec.setCallbackFcn(@jc_0511_StyleOneCallback,'None','StyleOne');
    rec.TitleTips=DAStudio.message('ModelAdvisor:styleguide:jc0511Tip');
    rec.Value=true;
    rec.setLicense({styleguide_license,'Stateflow'});
    rec.CSHParameters.MapKey='ma.mw.jmaab';
    rec.CSHParameters.TopicID='jc0511Title';
    rec.SupportExclusion=true;
    rec.SupportLibrary=true;
    mdladvRoot=ModelAdvisor.Root;
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end

function ResultDescription=jc_0511_StyleOneCallback(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    mdladvObj.setCheckResultStatus(false);

    ft=ModelAdvisor.FormatTemplate('TableTemplate');



    msgStr=[DAStudio.message('ModelAdvisor:styleguide:MathWorksAutomotiveAdvisoryBoardChecks'),': jc_0511'];
    ft.setCheckText(DAStudio.message('ModelAdvisor:styleguide:jc0511CheckText'));
    ft.setSubBar(0);
    ft.setSubResultStatus('warn');
    ft.setColTitles({DAStudio.message('ModelAdvisor:styleguide:jc0511ColTitle1'),DAStudio.message('ModelAdvisor:styleguide:jc0511ColTitle2')});
    ResultDescription={};tableInfo={};
    m=get_param(system,'Object');
    if~isempty(m)
        chartArray=m.find('-isa','Stateflow.Chart');
    end

    for ii=1:length(chartArray)
        chartObj=chartArray(ii);
        funcList=chartObj.find('-isa','Stateflow.Function');
        for jj=1:length(funcList)
            gFunc=funcList(jj);

            outputs=gFunc.find('-isa','Stateflow.Data','Scope','Output');
            if~isempty(outputs)

                transitions=gFunc.find('-isa','Stateflow.Transition');


                assignCnt=zeros(1,length(outputs));

                badTrans=[];

                srcSnippet={};


                for i=1:length(transitions)
                    [isAssigning,src]=iCountAssignmentsInTrans(transitions(i),outputs);
                    if(sum(isAssigning)>0)
                        badTrans(end+1)=transitions(i).Id;%#ok<AGROW>
                        srcSnippet=[srcSnippet,{src}];%#ok<AGROW>
                        assignCnt=assignCnt+isAssigning;
                    end
                end



                multipleAssigns=assignCnt>1;
                if(sum(multipleAssigns)>0)
                    for i=1:length(outputs)
                        if(multipleAssigns(i))
                            errMsg=iConstructErrMsg(i,badTrans,srcSnippet,gFunc,mdladvObj);
                            if~isempty(errMsg)
                                tableInfo{end+1}=errMsg;%#ok<AGROW>
                            end
                        end
                    end
                end
            end
        end
    end
    if isempty(tableInfo)
        mdladvObj.setCheckResultStatus(true);
        ft.setSubResultStatus('pass');
        if(isempty(chartArray))
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:NoChartsFound'));
        else
            ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:jc0511PassMsg'));
        end
    else
        for i=2:length(tableInfo)
            tableInfo{1}=[tableInfo{1};tableInfo{i}];
        end
        ft.setSubResultStatus('warn');
        ft.setSubResultStatusText(DAStudio.message('ModelAdvisor:styleguide:jc0511FailMsg'));
        ft.setTableInfo(tableInfo{1});
        ft.setRecAction(DAStudio.message('ModelAdvisor:styleguide:jc0511RecAction'));
    end
    ResultDescription{1}=ft;
end

function[assignChk,srcSnippet]=iCountAssignmentsInTrans(trans,outputs)




    assignChk=false(1,length(outputs));

    srcSnippet=cell(1,length(outputs));


    asts=Advisor.Utils.Stateflow.getAbstractSyntaxTree(trans);
    if isempty(asts)
        return;
    end
    sections=asts.sections;
    for i=1:length(sections)


        roots=sections{i}.roots;
        for j=1:length(roots)

            if Advisor.Utils.Stateflow.isActionLanguageC(trans)
                [assignChk,src]=iVisitSectionC(roots{j},outputs,assignChk);
            elseif Advisor.Utils.Stateflow.isActionLanguageM(trans)
                [assignChk,src]=iVisitSectionM(roots{j},outputs,assignChk);
            end


            for k=1:length(outputs)
                srcSnippet{k}=[srcSnippet{k},src{k}];
            end
        end
    end
end

function[assignChk,srcSnippet]=iVisitSectionC(ast,outputs,assignChk)



    srcSnippet=cell(1,length(outputs));

    if(~isempty(ast))

        if(isa(ast,'Stateflow.Ast.AssignExpression'))
            lhs=ast.lhs;
            for i=1:length(outputs)
                id=getAstID(lhs);
                if(id==outputs(i).Id)
                    assignChk(i)=true;
                    srcSnippet{i}=[srcSnippet{i};[ast.treeStart,ast.treeEnd]];
                end
            end
        end


        children=ast.children;
        for i=1:length(children)
            [assignChk,src]=iVisitSectionC(children{i},outputs,assignChk);
            for j=1:length(outputs)
                srcSnippet{j}=[srcSnippet{j},src{j}];
            end
        end

    end

end

function[assignChk,srcSnippet]=iVisitSectionM(ast,outputs,assignChk)

    srcSnippet=cell(1,length(outputs));

    if~isempty(ast)
        if isa(ast,'Stateflow.Ast.PreProcessed')
            mtreeObject=mtree(ast.sourceSnippet);
            assignmentTrees=mtreeObject.mtfind('Kind','EQUALS');
            for index=assignmentTrees.indices
                thisAssignment=assignmentTrees.select(index);
                id=getTreeNodeId(thisAssignment.Left);
                for i=1:length(outputs)
                    if strcmp(id,outputs(i).Name)==1
                        assignChk(i)=true;
                        leftIndex=ast.treeStart+thisAssignment.lefttreepos-1;
                        rightIndex=ast.treeStart+thisAssignment.righttreepos-1;
                        srcSnippet{i}=[srcSnippet{i};[leftIndex,rightIndex]];
                    end
                end
            end
        end
    end

end

function id=getAstID(ast)
    if isa(ast,'Stateflow.Ast.Array')||isa(ast,'Stateflow.Ast.StructMember')
        id=getAstID(ast.children{1});
    else
        id=ast.id;
    end
end

function id=getTreeNodeId(treeNode)
    switch treeNode.kind
    case 'ID',id=treeNode.string;
    case 'SUBSCR',id=getTreeNodeId(treeNode.Left);
    case 'DOT',id=getTreeNodeId(treeNode.Left);
    otherwise,id='<unknown>';
    end
end

function info=iConstructErrMsg(op,badTrans,snip,gFunc,mdladvObj)
    info={};
    for i=1:length(badTrans)
        src=snip{i}{op};


        if(~isempty(src))
            transObj=gFunc.find('-isa','Stateflow.Transition','Id',badTrans(i));
            linkStr=ModelAdvisor.Text(transObj.Path);
            objID=Simulink.ID.getSID(transObj);
            objID=mdladvObj.filterResultWithExclusion(objID);
            if isempty(objID)
                continue;
            end
            outputTag=Advisor.Utils.Stateflow.highlightSFLabelByIndex(transObj.LabelString,src);
            linkStr.setHyperlink(['matlab: Simulink.ID.hilite(''',objID,''')']);
            info=[info;{outputTag,linkStr}];%#ok<AGROW>
        end
    end
end

