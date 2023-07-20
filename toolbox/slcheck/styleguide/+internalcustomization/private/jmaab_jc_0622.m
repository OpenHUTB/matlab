function jmaab_jc_0622





    checkID='jc_0622';
    checkGroup='jmaab';
    mdladvRoot=ModelAdvisor.Root;

    rec=ModelAdvisor.Check('mathworks.jmaab.jc_0622');

    rec.Title=DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_title']);
    rec.TitleTips=[DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_guideline']),newline,newline,DAStudio.message(['ModelAdvisor:jmaab:',checkID,'_tip'])];
    rec.CSHParameters.MapKey=['ma.mw.',checkGroup];
    rec.CSHParameters.TopicID=['mathworks.',checkGroup,'.',checkID];
    rec.SupportLibrary=true;
    rec.SupportExclusion=false;
    rec.SupportHighlighting=false;
    rec.Value=true;

    rec.setLicense({styleguide_license});


    paramFollowLinks=Advisor.Utils.createStandardInputParameters('find_system.FollowLinks');
    paramLookUnderMasks=Advisor.Utils.createStandardInputParameters('find_system.LookUnderMasks');
    paramLookUnderMasks.RowSpan=[1,1];
    paramLookUnderMasks.ColSpan=[3,4];
    rec.setInputParameters({paramFollowLinks,paramLookUnderMasks});



    rec.setCallbackFcn(@(system,checkObj)Advisor.Utils.genericCheckCallback(system,checkObj,'ModelAdvisor:jmaab:jc_0622',@checkAlgo),'None','DetailStyle');
    rec.setReportStyle('ModelAdvisor.Report.ExpressionStyle');
    rec.setSupportedReportStyles({'ModelAdvisor.Report.ExpressionStyle'});
    mdladvRoot.publish(rec,{sg_maab_group,sg_jmaab_group});
end


function FailingObjs=checkAlgo(system)
    FailingObjs=[];

    mdlAdvObj=Simulink.ModelAdvisor.getModelAdvisor(system);


    FollowLinks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.FollowLinks');
    LookUnderMasks=Advisor.Utils.getStandardInputParameters(mdlAdvObj,'find_system.LookUnderMasks');




    allFcns=find_system(system,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'FollowLinks',FollowLinks.Value,'LookUnderMasks',LookUnderMasks.Value,'BlockType','Fcn');
    allFcns=mdlAdvObj.filterResultWithExclusion(allFcns);
    allExprs=get_param(allFcns,'Expr');


    for idx=1:numel(allExprs)
        [status,text]=analyze(allExprs{idx});
        if~status
            tempObj=ModelAdvisor.ResultDetail;
            ModelAdvisor.ResultDetail.setData(tempObj,'SID',allFcns{idx},'Expression',text);
            FailingObjs=[FailingObjs,tempObj];%#ok<AGROW>
        end
    end

end


function[status,text,position]=analyze(expression)
    status=true;
    text=expression;
    position=[];


    expr=replace(expression,{'[',']'},{'(',')'});


    T=mtree(expr);
    [bValid,error]=Advisor.Utils.isValidMtree(T);
    if~bValid
        status=false;
        tmp1=ModelAdvisor.Text([text,' ']);
        tmp2=ModelAdvisor.Text(error.message,{'warn'});
        msg=ModelAdvisor.Paragraph;
        msg.addItem(tmp1);
        msg.addItem(tmp2);
        text=msg.emitHTML;
        return;
    end


    nodes=T.mtfind('Kind',{'MUL','DIV','PLUS','MINUS','EXP'});

    for i=indices(nodes)
        s=T.select(i);

        if~iskind(s.Parent,{kind(s),'PARENS','PRINT','CALL'})
            status=false;
            position=[position,s.position];%#ok<AGROW>
        end
    end
end

