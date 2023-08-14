function checkAndNotify(harness)


    harnessCheckStage=Simulink.output.Stage(...
    DAStudio.message('Simulink:Harness:CheckHarnessStage'),...
    'ModelName',harness.name,...
    'UIMode',true);%#ok


    editor=Simulink.harness.internal.findHarnessEditor(harness.name);

    try
        [~,details]=Simulink.harness.check(harness.ownerFullPath,harness.name);

        msg=sprintf('%s %s %s %s \n %s %s',...
        DAStudio.message('Simulink:Harness:HarnessEquivalenceCheckContents'),...
        makePassFailMsg(details.contents),...
        DAStudio.message('Simulink:Harness:HarnessEquivalenceCheckOverall'),...
        makePassFailMsg(details.overall),...
        DAStudio.message('Simulink:Harness:HarnessEquivalenceCheckSummary'),...
        details.reason);

        editor.deliverInfoNotification('Simulink:Harness:check',...
        DAStudio.message('Simulink:Harness:HarnessEquivalenceCheckNotification',harness.name,harness.ownerFullPath,msg));

    catch causeME
        if strcmp(causeME.identifier,'Simulink:Harness:CheckHarnessFailedSystemChecksum')...
            ||strcmp(causeME.identifier,'Simulink:Harness:CheckHarnessFailedHarnessChecksum')
            causeME=Simulink.harness.internal.eraseMExceptionStack(causeME);
        end


        Simulink.harness.internal.error(causeME,true);


        msg=DAStudio.message('Simulink:Harness:CheckHarnessFailedNotification',...
        harness.name,harness.ownerFullPath);
        editor.deliverWarnNotification('Simulink:Harness:check',msg);
    end
end

function msg=color(msg,color)
    msg=['<span style="color:',color,';">',msg,'</span>'];
end

function msg=makePassFailMsg(pass)
    if pass
        msg=color(DAStudio.message('Simulink:Harness:HarnessEquivalenceCheckSame'),'Green');
    else
        msg=color(DAStudio.message('Simulink:Harness:HarnessEquivalenceCheckDifferent'),'FireBrick');
    end
end
