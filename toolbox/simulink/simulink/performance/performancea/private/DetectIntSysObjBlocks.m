function[ResultDescription,ResultDetails]=DetectIntSysObjBlocks(system)











    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.DetectIntSysObjBlocks');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntSysObjBlocksTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);




    mlSysObjBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','on','BlockType','MATLABSystem');






    mlSysBlk=struct('block',[],'file',[],'screenerPass',[],'simulateUsing',[]);


    for idx=1:length(mlSysObjBlks)
        mlSysBlk(idx).block=mlSysObjBlks{idx};
        mlSysBlk(idx).simulateUsing=get_param(mlSysObjBlks{idx},'SimulateUsing');
        mlSysObjFileTmp=get_param(mlSysObjBlks{idx},'System');
        mlSysBlk(idx).file=mlSysObjFileTmp;
        [~,screenerError]=utilScreenerProblem(mlSysObjFileTmp);
        if(Pass&&strcmp(mlSysBlk(idx).simulateUsing,'Interpreted execution'))
            Pass=false;
        end

        mlSysBlk(idx).screenerPass=~screenerError;
    end

    currentCheck.resultData.FixInfo=mlSysBlk;




    if~Pass

        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntSysObjBlocksAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        result_text=utilAddAppendInformation(mdladvObj,currentCheck);
        result_paragraph.addItem(result_text);



        table=cell(length(mlSysBlk),4);

        for idx=1:length(mlSysBlk)
            blockName=mdladvObj.getHiliteHyperlink(mlSysBlk(idx).block);
            hlink=ModelAdvisor.Text(blockName);
            table{idx,1}=hlink;

            table{idx,2}=ModelAdvisor.Text(mlSysBlk(idx).simulateUsing);

            detailsStr=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ScreenerLinkage',mlSysBlk(idx).file);
            if(mlSysBlk(idx).screenerPass)
                table{idx,4}=utilGetStatusImgLink(1,detailsStr);
                table{idx,3}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CodeGeneration'));
            else
                if(strcmp(mlSysBlk(idx).simulateUsing,'Interpreted execution'))
                    table{idx,3}='Interpreted execution';
                else
                    table{idx,3}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CodeGeneration'));
                end
                table{idx,4}=utilGetStatusImgLink(-1,detailsStr);
            end
        end
        ch1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:BlockPath');
        ch2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActualValue');
        ch3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:RecommendedValue');
        ch4=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Modifiable');
        resultTable=utilDrawReportTable(table,'',{},{ch1,ch2,ch3,ch4});
        result_paragraph.addItem(resultTable.emitHTML);

        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntSysObjBlocksAdvice'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:IntSysObjBlocksAdviceAppendPassed',model));
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


