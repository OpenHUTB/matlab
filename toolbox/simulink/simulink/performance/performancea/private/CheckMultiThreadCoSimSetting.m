function[ResultDescription,ResultDetails]=CheckMultiThreadCoSimSetting(sys)



    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(sys);
    model=bdroot(sys);
    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckMultiThreadCoSimSetting');


    Pass=true;


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});

    Warned=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Warning'),{'bold','warn'});


    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTitle'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);




    if(strcmpi(get_param(model,'StopTime'),'inf'))
        msgId='perfAdvId:InfStopTime';
        msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:InfiniteStopTime');
        Exception=MException(msgId,msg);
        throwAsCaller(Exception);
    end


    multithreadcosim_old=get_param(model,'MultiThreadCoSim');
    if(strcmpi(multithreadcosim_old,'on'))
        multithreadcosim_new='off';
    elseif(strcmpi(multithreadcosim_old,'off'))
        multithreadcosim_new='on';
    end


    try

        if mdladvObj.UserCancel
            msgId='perfAdvId:UserCancel';
            msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UserCancelException');
            Exception=MException(msgId,msg);
            throwAsCaller(Exception);
        end

        if mdladvObj.GlobalTimeOut
            msgId='perfAdvId:GlobalTimeOut';
            msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:GlobalTimeOutException');
            Exception=MException(msgId,msg);
            throwAsCaller(Exception);
        end

        sim_mode_orig=get_param(model,'SimulationMode');
        set_param(model,'SimulationMode','normal');

        set_param(model,'MultiThreadCoSim','on');
        eval([model,'([],[],[], ''compile'')']);
        eval([model,'([],[],[], ''term'')']);
        tic;
        sim(model);
        on_time=toc;
        set_param(model,'SimulationMode',sim_mode_orig);
    catch ME

        set_param(model,'MultiThreadCoSim',multithreadcosim_old);
        set_param(model,'SimulationMode',sim_mode_orig);

        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setCheckErrorSeverity(1);
        mdladvObj.setActionEnable(false);

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
        return;
    end

    if(strcmpi(get_param(model,'IsInMultiThreadCoSim'),'off'))
        mdladvObj.setCheckResultStatus(true);
        result_text=ModelAdvisor.Text(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingCannotRunMTCS'));
        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_paragraph.addItem(result_text);
        ResultDetails{end+1}='';
        ResultDescription{end+1}=result_paragraph;
        return;
    end


    try

        if mdladvObj.UserCancel
            msgId='perfAdvId:UserCancel';
            msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:UserCancelException');
            Exception=MException(msgId,msg);
            throwAsCaller(Exception);
        end

        if mdladvObj.GlobalTimeOut
            msgId='perfAdvId:GlobalTimeOut';
            msg=DAStudio.message('SimulinkPerformanceAdvisor:advisor:GlobalTimeOutException');
            Exception=MException(msgId,msg);
            throwAsCaller(Exception);
        end

        sim_mode_orig=get_param(model,'SimulationMode');
        set_param(model,'SimulationMode','normal');

        set_param(model,'MultiThreadCoSim','off');
        eval([model,'([],[],[], ''compile'')']);
        eval([model,'([],[],[], ''term'')']);
        tic;
        sim(model);
        off_time=toc;
        set_param(model,'SimulationMode',sim_mode_orig);
    catch ME

        set_param(model,'MultiThreadCoSim',multithreadcosim_old);
        set_param(model,'SimulationMode',sim_mode_orig);

        mdladvObj.setCheckResultStatus(false);
        mdladvObj.setCheckErrorSeverity(1);
        mdladvObj.setActionEnable(false);

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
        return;
    end

    if(strcmpi(get_param(model,'IsInMultiThreadCoSim'),'on'))
        mdladvObj.setCheckResultStatus(true);
        result_text=ModelAdvisor.Text(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingCannotRunSTCS'));
        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_paragraph.addItem(result_text);
        ResultDetails{end+1}='';
        ResultDescription{end+1}=result_paragraph;
        return;
    end


    set_param(model,'MultiThreadCoSim',multithreadcosim_old);


    if(strcmpi(multithreadcosim_old,'on'))
        old_time=on_time;
        new_time=off_time;
    else
        old_time=off_time;
        new_time=on_time;
    end

    if new_time<old_time
        Pass=false;
        mdladvObj.UserData.multithreadcosim_new=multithreadcosim_new;
        mdladvObj.UserData.multithreadcosim_old=multithreadcosim_old;
    end


    times=[off_time,on_time];
    f=figure('visible','off');
    set(f,'color',[1,1,1]);
    bar(times);
    axis([0,3,0,1.25*max(times)]);
    xticks([1,2]);
    xticklabels({DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingFigureXTickLabel1'),...
    DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingFigureXTickLabel2')});
    ylabel(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingFigureYLabel'));
    title(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingFigureTitle'));
    grid off;
    file_name=fullfile(mdladvObj.getWorkDir,'multithreadcosim.png');
    scr_pos=get(f,'Position');
    new_pos=scr_pos/75;
    set(f,'PaperUnits','inches','PaperPosition',new_pos);
    print(f,'-dpng',file_name,'-r100');
    file_path=strcat(file_name);
    close(f);


    if(Pass)
        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingPass',multithreadcosim_old));
        result_paragraph.addItem(result_text);
    else
        result_paragraph.addItem(Warned);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingWarning',multithreadcosim_old));
        result_paragraph.addItem(result_text);
    end

    imgstr=strcat(' <img src =','" ','file:///',file_path,'"','/>');
    result_text=ModelAdvisor.Text(imgstr);
    result_paragraph.addItem([ModelAdvisor.LineBreak,result_text]);
    result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);

    table=cell(3,3);
    table{1,1}=ModelAdvisor.Text(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTableMeasurement1'));
    table{1,2}=sprintf('%.3f',off_time);
    table{1,3}=ModelAdvisor.Text(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTableUnit'));
    table{2,1}=ModelAdvisor.Text(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTableMeasurement2'));
    table{2,2}=sprintf('%.3f',on_time);
    table{2,3}=ModelAdvisor.Text(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTableUnit'));
    table{3,1}=ModelAdvisor.Text(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTableMeasurement3'));
    table{3,2}=sprintf('%.3f',off_time/on_time);
    table{3,3}=ModelAdvisor.Text('-');
    h1=DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTableH1');
    h2=DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTableH2');
    h3=DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingTableH3');
    heading={h1,h2,h3};
    resultTable=utilDrawReportTable(table,'',{},heading);
    result_paragraph.addItem(resultTable.emitHTML);

    star_msg_1=sprintf(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingStarNote1'));
    result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.Text(star_msg_1)]);
    star_msg_2=sprintf(DAStudio.message('FMUBlock:FMU:CheckMultiThreadCoSimSettingStarNote2'));
    result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.Text(star_msg_2)]);


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
