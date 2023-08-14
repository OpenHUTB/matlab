function Result=DetectIntMATLABFcnBlocksFix(taskobj)





    mdladvObj=taskobj.MAObj;
    system=getfullname(mdladvObj.System);
    model=bdroot(system);
    result_paragraph=ModelAdvisor.Paragraph;
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.DetectIntMATLABFcnBlocks');


    mdladvObj.setActionEnable(false);
    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Wait');


    me=mdladvObj.MAExplorer;
    dlg=me.getDialog;
    if isa(dlg,'DAStudio.Dialog')
        dlg.refresh;
    end


    [~]=PushOldSettings(model);


    baseline=utilGetBaselineBefore(mdladvObj,model,currentCheck);
    baseline.check.validationPassed='na';
    baseline.check.name=DAStudio.message('SimulinkPerformanceAdvisor:advisor:DetectIntMATLABFcnBlocksTitle');

    try
        baseline=utilGenerateBaselineIfNeeded(baseline,mdladvObj,model,currentCheck);
    catch ME

        text=DAStudio.message('SimulinkPerformanceAdvisor:advisor:OldBaselineFailed');
        Result=publishActionFailedMessage(ME,text);
        baseline.check.fixed='n';
        utilUpdateBaseline(mdladvObj,currentCheck,baseline,baseline);
        currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');
        return;
    end





    mlFcnBlks=find_system(model,'MatchFilter',@Simulink.match.internal.filterOutInactiveVariantSubsystemChoices,'LookUnderMasks','all','FollowLinks','off','BlockType','MATLABFcn');


    fcnProtoType=get_param(mlFcnBlks,'MatLABFcn');


    noFiles=length(fcnProtoType);

    noReplacedBlk=0;

    code=cell(noFiles,1);
    inputVars=cell(noFiles,1);
    sampleTime=cell(noFiles,1);
    outPutDimensions=cell(noFiles,1);
    emlNotSupported=cell(noFiles,1);

    for index=1:noFiles


        MyTree=mtree(fcnProtoType{index});
        vars=MyTree.stringvals;
        inputVars{index}=vars(MyTree.iskind('ID'));


        var=unique(inputVars{index});

        uIdx=strcmp(var,'u')==1;
        var(uIdx)=[];



        maskP={};
        parent=get_param(mlFcnBlks{index},'Parent');

        while true
            if strcmp(get_param(parent,'Type'),'block')
                maskOn=get_param(parent,'Mask');
                if strcmp(maskOn,'on')
                    maskP=get_param(parent,'MaskNames');
                    break;
                end
                parent=get_param(parent,'Parent');
            else
                break;
            end
        end


        fcnM=strcat(fcnProtoType{index},'.m');
        fcnP=strcat(fcnProtoType{index},'.p');

        if~isempty(maskP)

            var=intersect(maskP,var);
        else

            if(~isempty(which(fcnM))||~isempty(which(fcnP)))

                var(1)=[];
            else

                nVars=length(var);
                removedIdx=true(1,nVars);
                for idx=1:nVars
                    tempVar=var{idx};
                    if existsInGlobalScope(model,tempVar)
                        removedIdx(idx)=false;
                    end
                end
                var(removedIdx)=[];
            end
        end

        inputVars{index}=var;


        if isempty(strfind(fcnProtoType{index},'('))

            if isempty(which(fcnProtoType{index}))

                code{index}=strcat('y = ',fcnProtoType{index});
            else

                isFcn=(~isempty(which(fcnM))||~isempty(which(fcnP)));
                if(isFcn)

                    code{index}=strcat('y = ',fcnProtoType{index},'(u)');
                else

                    code{index}=strcat('y = ',fcnProtoType{index});
                end
            end
        else

            code{index}=strcat('y = ',fcnProtoType{index});
        end

        if get_param(mlFcnBlks{index},'Output1D')
            code{index}=strcat(code{index},';','y = transpose(y); ');
        end



        fileName='testreplace_temp.m';
        fullFileName=fullfile(mdladvObj.getWorkDir,'testreplace_temp.m');

        codeWrite=strcat('function y = testreplace_temp(u)','\n',code{index});
        codeWrite=sprintf(codeWrite);
        fid=fopen(fullFileName,'wt');
        fwrite(fid,codeWrite);
        fclose(fid);

        originalDir=pwd;


        addpath(originalDir);

        cd(mdladvObj.getWorkDir);

        [pUnsupportedEML,n]=utilScreenerProblem(fileName);



        if n==0
            set_param(mlFcnBlks{index},'Tag','emlOk');
            noReplacedBlk=noReplacedBlk+1;
            sampleTime{noReplacedBlk}=get_param(mlFcnBlks{index},'SampleTime');
            outPutDimensions{noReplacedBlk}=get_param(mlFcnBlks{index},'OutputDimensions');
            emlNotSupported{index}='emlOk';
        else
            emlNotSupported{index}=pUnsupportedEML;
        end

        delete('testreplace_temp.m');
        cd(originalDir);

    end



    if(~bdIsLoaded('simulink'))
        load_system('simulink');
        loadExtra=true;
    else
        loadExtra=false;
    end

    replacedBlks=replace_block(model,'Tag','emlOk','simulink/User-Defined Functions/MATLAB Function','noprompt');

    if(loadExtra)
        close_system('simulink');
    end

    m=find(slroot,'-isa','Stateflow.Machine','Name',model);%#ok<GTARG>


    for i=1:length(replacedBlks)
        emlBlk=m.find('-isa','Stateflow.EMChart','Path',replacedBlks{i});
        index=strmatch(emlBlk.Path,mlFcnBlks,'EXACT');
        emlBlk.Script=code{index};
        emlBlk.SampleTime=sampleTime{i};



        chartId=sf('Private','block2chart',emlBlk.Path);

        var=inputVars{index};
        for j=1:length(var)
            d=Stateflow.Data(idToHandle(sfroot,chartId));
            d.Name=var{j};
            d.Scope='Parameter';
        end


        if~isempty(var)
            set_param(emlBlk.Path,'MaskVariables',cell2mat(var));
        end
    end




    modelChanged=true;

    ch1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:BlockPath');
    ch2=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Result');

    if~isempty(replacedBlks)

        tableFix=cell(length(replacedBlks),2);
        for i=1:length(replacedBlks);
            blockNames=mdladvObj.getHiliteHyperlink(replacedBlks{i});
            hlink=ModelAdvisor.Text(blockNames);
            tableFix{i,1}=hlink;
            tableFix{i,2}=utilGetStatusImgLink(1);
        end

        nameFix=DAStudio.message('SimulinkPerformanceAdvisor:advisor:FoundInterpretMATLABAdviceFixed');

        resultTableFix=utilDrawReportTable(tableFix,nameFix,{},{ch1,ch2});
        baseline.check.fixed='y';

    else

        modelChanged=false;
        baseline.check.fixed='n';
    end

    if length(replacedBlks)<length(mlFcnBlks)
        tableNoFix=cell(length(replacedBlks),3);

        j=0;
        for i=1:length(mlFcnBlks)
            if~strcmp(emlNotSupported{i},'emlOk')

                blockNames=mdladvObj.getHiliteHyperlink(mlFcnBlks{i});

                hlink=ModelAdvisor.Text(blockNames);
                j=j+1;
                tableNoFix{j,1}=hlink;
                tableNoFix{j,2}=utilGetStatusImgLink(-1);
                tableNoFix{j,3}=ModelAdvisor.Text(emlNotSupported{i},{'bold','fail'});
            end
        end

        ch3=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UnSupportedFcns');
        nameNoFix=DAStudio.message('SimulinkPerformanceAdvisor:advisor:InterpretMATLABNotReplaced');
        resultTableNoFix=utilDrawReportTable(tableNoFix(1:j,:),nameNoFix,{},{ch1,ch2,ch3});

    end


    if modelChanged
        baselineOk=true;
        try

            [~,newBaseline,needUndo,validated,compare_result]=utilCheckActionResult(mdladvObj,currentCheck,baseline);
        catch ME

            baseText1=DAStudio.message('SimulinkPerformanceAdvisor:advisor:NewBaselineFailed');
            baseText2=publishActionFailedMessage(ME,baseText1);
            result_paragraph.addItem(baseText2);
            baselineOk=false;
        end
    else

        needUndo=false;
        validated=false;
        compare_result.Time=false;
        compare_result.Accuracy=false;
        newBaseline=baseline;
    end



    if~modelChanged
        result_paragraph.addItem(ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NOInterpretMATLABReplaced'),{'bold','fail'}));
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    else
        if baselineOk
            [validateTime,validateAccuracy]=utilCheckValidation(mdladvObj,currentCheck);
            if(validateTime||validateAccuracy)
                tableName=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ValidationTableName');
                summaryTable=utilCreateActionSummaryTable(tableName,needUndo,newBaseline,baseline,validated,compare_result);
                result_paragraph.addItem(summaryTable.emitHTML);
                result_paragraph.addItem(ModelAdvisor.LineBreak);
            end
        else
            needUndo=true;
        end
    end

    if needUndo

        heading=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:SuccessActionsTaken'));
        heading={heading};

        if baselineOk
            Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:PerformanceNotImproved'),{'bold','fail'});

            newBaseline.time=baseline.time;
        else
            Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NewBaseActionReverted'),{'bold','fail'});
            newBaseline=baseline;
        end

        text=UndoFix(model,currentCheck,Failed);
        table=cell(1,1);
        table{1,1}=text;
        undoTable=utilDrawReportTable(table(1,1),'','',heading);
    end

    if needUndo
        result_paragraph.addItem(undoTable.emitHTML);
        result_paragraph.addItem(ModelAdvisor.LineBreak);
    else
        if~isempty(replacedBlks)
            result_paragraph.addItem(resultTableFix.emitHTML);
            result_paragraph.addItem(ModelAdvisor.LineBreak);
        end

        if length(replacedBlks)<length(mlFcnBlks)
            result_paragraph.addItem(resultTableNoFix.emitHTML);
            result_paragraph.addItem(ModelAdvisor.LineBreak);
        end

    end

    Result=result_paragraph;



    currentCheck.ResultData.after=newBaseline;

    currentCheck.Action.Description=DAStudio.message('SimulinkPerformanceAdvisor:advisor:ActionDesc');


    rmpath(originalDir);


end


function oldSettings=PushOldSettings(model)
    oldSettings=DefaultPushOldSettings(model);
end


function Result=UndoFix(model,currentCheck,msg)

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    text=ModelAdvisor.Text([msg.emitHTML,lb,DAStudio.message('SimulinkPerformanceAdvisor:advisor:Undo')]);

    Result=DefaultUndo(model,currentCheck,text);

end



