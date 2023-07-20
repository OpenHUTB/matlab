function actionSummaryTable=utilCreateActionSummaryTable(tableName,needUndo,newBaseLine,oldBaseLine,~,compare_result)


    table=cell(3,3);

    tsOld=oldBaseLine.time.displayTime;
    tsNew=newBaseLine.time.displayTime;


    table{2,1}=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:WithinTol'));
    table{2,3}=utilGetStatusImgLink(compare_result.Accuracy);
    if compare_result.Accuracy==1
        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:WithinTol'),{'bold','pass'});
    elseif compare_result.Accuracy==-1
        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:BeyondTol'),{'bold','fail'});
    else
        text=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:NotValidated'),{'bold','warn'});
    end
    if(compare_result.Accuracy~=0)
        text=[text,utilGenerateSdiHTML(newBaseLine,oldBaseLine)];
    end
    table{2,2}=text;



    table{3,1}=ModelAdvisor.Text(tsOld);
    table{3,2}=ModelAdvisor.Text(tsNew);
    deltaT=((oldBaseLine.time.total-newBaseLine.time.total)/oldBaseLine.time.total)*100;

    if(deltaT>=0)
        table{3,3}=ModelAdvisor.Text([num2str(deltaT,'%6.2f'),'%'],{'bold','pass'});
    else
        table{3,3}=ModelAdvisor.Text([num2str(deltaT,'%6.2f'),'%'],{'bold','fail'});
    end

    if needUndo
        table{1,3}=utilGetStatusImgLink(-1);
    else
        table{1,3}=utilGetStatusImgLink(1);
    end

    actionSummaryTable=utilCreateSummaryTable(table,tableName);

