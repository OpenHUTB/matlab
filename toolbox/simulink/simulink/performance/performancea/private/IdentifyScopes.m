function[ResultDescription,ResultDetails]=IdentifyScopes(system)









    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.IdentifyScopes');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);





    scopeBlks=find_system(system,...
    'IncludeCommented','on',...
    'LookUnderMasks','all',...
    'MatchFilter',@Simulink.match.allVariants,...
    'AllBlocks','on',...
    'BlockType','Scope');


    ioTypeViewer=strcmpi('viewer',get_param(scopeBlks,'IOType'));
    numScopes=length(scopeBlks);
    reduceUpdates=true(numScopes,1);
    isScopeVisible=false(numScopes,1);
    isOpenAtSimStart=false(numScopes,1);
    for indx=1:numScopes
        s=get_param(scopeBlks{indx},'ScopeConfiguration');
        reduceUpdates(indx)=s.ReduceUpdates;
        isScopeVisible(indx)=s.Visible;
        isOpenAtSimStart(indx)=s.OpenAtSimulationStart;
    end
    notReduceUpdatesOrOpenAtSim=any(~reduceUpdates)||any(isOpenAtSimStart);
    if any(isScopeVisible)||notReduceUpdatesOrOpenAtSim
        Pass=false;
    end


    if~Pass

        if notReduceUpdatesOrOpenAtSim
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesAdviceReduceUpdatesOrOpenAtSim'));
        else
            result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesAdvice'));
        end
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);

        commentAllScopes=getString(message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesCommentAll'));
        commentAll_text=ModelAdvisor.Text(['<a href="matlab: paprivate scopeCallback commentall ',model,'">'...
        ,commentAllScopes,'</a>']);
        result_paragraph.addItem(commentAll_text);


        commentToggle=getString(message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesComment'));
        openToggle=getString(message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesOpen'));
        if~isempty(scopeBlks)
            table=cell(length(scopeBlks),3);
            for i=1:length(scopeBlks);
                block=scopeBlks{i};
                table{i,1}=block;
                if ioTypeViewer(i)
                    blockName=['<a href="matlab: sigandscopemgr Create ',model,'">',block,'</a>'];
                else
                    blockName=mdladvObj.getHiliteHyperlink(table{i,1});
                end
                hlink=ModelAdvisor.Text(blockName);
                linked=~strcmp(get_param(block,'LinkStatus'),'none');
                if(linked)
                    text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:LinkedBlocks'),{'bold'});
                    table{i,1}=ModelAdvisor.Text([blockName,'   --> ',text.emitHTML]);
                else
                    table{i,1}=hlink;
                end
                if ioTypeViewer(i)
                    table{i,2}=ModelAdvisor.Text('');
                else
                    table{i,2}=ModelAdvisor.Text(['<a href="matlab: paprivate scopeCallback comment ',Simulink.ID.getSID(block),'">'...
                    ,commentToggle,'</a>']);
                end
                table{i,3}=ModelAdvisor.Text(['<a href="matlab: paprivate scopeCallback open ',Simulink.ID.getSID(block),'">'...
                ,openToggle,'</a>']);
            end
            tName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesTableName');
            resultTable=utilDrawReportTable(table,tName,{},{});
            result_paragraph.addItem(resultTable.emitHTML);
        end

        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:IdentifyScopesPassed',model));
        result_paragraph.addItem(result_text);

    end


    ResultDetails{end+1}='';
    ResultDescription{end+1}=result_paragraph;


    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);



        utilRunFix(mdladvObj,currentCheck,Pass);
    end


    if(Pass)
        baseLineAfter.time=baseLineBefore.time;
        baseLineAfter.check.passed='y';
    else
        baseLineAfter=utilGetBaselineAfter(mdladvObj,model,currentCheck);
        baseLineAfter.check.passed='n';
    end

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);

end


