function[ResultDescription,ResultDetails]=publishResults(mdladvObj,checks,prefixStr)




    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;
    ResultDescription={};
    ResultDetails={};


    Warning=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGWarn'),{'Warn'});
    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});


    [LVParam,hasErrors,hasWarnings]=consolidateCheckErrors(checks);


    if hasErrors
        passFail=Failed;
        Result=false;
        resultStr=' failed.';
    elseif hasWarnings
        passFail=Warning;
        Result=false;
        resultStr=' passed with warning(s).';
    else
        passFail=Passed;
        Result=true;
        resultStr=' passed.';
    end


    text=ModelAdvisor.Text([passFail.emitHTML,prefixStr,resultStr]);
    text=[text.emitHTML,lb];
    if~Result
        repTable=drawReportTable(mdladvObj,LVParam);
        text=[text,lb,repTable.emitHTML,lb];
    end

    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';





    if hasErrors
        mdladvObj.setCheckErrorSeverity(1);
    elseif hasWarnings
        mdladvObj.setCheckErrorSeverity(0);
    end
    mdladvObj.setCheckResultStatus(Result);

end

function repTable=drawReportTable(mdladvObj,LVParam)
    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    numEntries=length(LVParam);
    repTable=ModelAdvisor.Table(numEntries+1,2);
    heading1=ModelAdvisor.Text('Simulink Block');
    heading1.setBold(true);
    heading2=ModelAdvisor.Text('Warnings/Errors');
    heading2.setBold(true);
    repTable.setEntry(1,1,heading1.emitHTML);
    repTable.setEntry(1,2,heading2.emitHTML);
    for i=1:numEntries
        currEntry=LVParam{i};
        blockList=[];
        for j=1:length(currEntry.Data)
            try
                blockList=[blockList,mdladvObj.getHiliteHyperlink(currEntry.Data{j})];%#ok<*AGROW>
            catch
                blockList=[blockList,currEntry.Data{j}];
            end
            if j~=length(currEntry.Data)
                blockList=[blockList,lb];
            end
        end

        if isempty(blockList)
            blockList=[blockList,lb];
        end
        repTable.setEntry(i+1,1,blockList);
        repTable.setEntry(i+1,2,currEntry.Name);
    end
end


