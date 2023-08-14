function[ResultDescription,ResultDetails]=checkModelSettings(system)



    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);

    mdladvObj.setCheckResultStatus(true);
    mdladvObj.setCheckErrorSeverity(1);


    mdladvObj.setActionEnable(false);

    ResultDescription={};
    ResultDetails={};


    Warning=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGWarn'),{'Warn'});
    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    mdl_o=get_param(bdroot(system),'Object');

    t1_numRow=0;












    paramCell={'SystemTargetFile','AlgebraicLoopMsg',...
    'BlockReduction','ConditionallyExecuteInputs','ProdHWDeviceType'};
    displayCell={'System Target File','Algebraic Loop',...
    'Block reduction','Conditional input branch execution','Device type'};
    expectCell={{'grt.tlc','ert.tlc'},{'error'},{'off'},{'off'},{'ASIC/FPGA->ASIC/FPGA','ASIC/FPGA'}};
    severityCell={'error','warning','warning','warning','warning'};

    if hdlcoderui.isSimulinkCoderInstalled


        if slfeature('InlinePrmsAsCodeGenOnlyOption')
            paramCell{end+1}='DefaultParameterBehavior';
            displayCell{end+1}='Default parameter behavior';
            expectCell{end+1}={'Inlined'};
        else
            paramCell{end+1}='InlineParams';
            displayCell{end+1}='Inline parameters';
            expectCell{end+1}={'on'};
        end
        severityCell{end+1}='warning';
    end

    try
        for i=1:length(paramCell)
            param=paramCell{i};
            paramValue=get_param(bdroot(system),param);
            expectValue=expectCell{i};
            severity=severityCell{i};
            if~any(strcmp(paramValue,expectValue))
                t1_numRow=t1_numRow+1;
                t1_colElements{t1_numRow}{1}=mdl_o.Name;%#ok<AGROW>
                text=ModelAdvisor.Text(displayCell{i});
                encodedModelName=modeladvisorprivate('HTMLjsencode',bdroot(system),'encode');
                encodedModelName=[encodedModelName{:}];
                text.setHyperlink(['matlab: modeladvisorprivate openCSAndHighlight ',[encodedModelName,' ''',param,''' ']]);
                t1_colElements{t1_numRow}{2}=text;%#ok<AGROW>
                t1_colElements{t1_numRow}{3}=paramValue;%#ok<AGROW>
                recommendValue=expectValue{1};
                t1_colElements{t1_numRow}{4}=recommendValue;%#ok<AGROW>
                t1_colElements{t1_numRow}{5}=severity;%#ok<AGROW>
            end
        end

        if t1_numRow>0


            [t3,allWarning]=drawReportTable(t1_colElements,t1_numRow);

            if allWarning
                passFail=Warning;
            else
                passFail=Failed;
            end
            text=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:HDLWAModelSettingsIncorrect'));
            text=[passFail.emitHTML,text.emitHTML,lb,lb,lb,t3.emitHTML,lb];





            if allWarning
                mdladvObj.setCheckErrorSeverity(0);
            end
            mdladvObj.setCheckResultStatus(false);
            mdladvObj.setActionEnable(true);
        else
            text=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:HDLWARunCodeAdvisor'));
            text=[Passed.emitHTML,text.emitHTML];
        end

    catch ME

        [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
        ME.message,ME.cause,{},{},ME.getReport);

        return;
    end

    ResultDescription{end+1}=text;
    ResultDetails{end+1}='';

end

function[t3,allWarning]=drawReportTable(t1_colElements,t1_numRow)

    t3=ModelAdvisor.Table(t1_numRow,5);
    txt=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:HDLWAReportTableTitle'));
    t3.setHeading(txt.emitHTML);
    t3.setHeadingAlign('center');
    t3.setColHeading(1,DAStudio.message('HDLShared:hdldialog:MSGBlock'));
    t3.setColHeading(2,DAStudio.message('HDLShared:hdldialog:MSGSettings'));
    t3.setColHeading(3,DAStudio.message('HDLShared:hdldialog:MSGCurrent'));
    t3.setColHeading(4,DAStudio.message('HDLShared:hdldialog:MSGRecommended'));
    t3.setColHeading(5,'Severity');

    allWarning=true;

    for irow=1:t1_numRow
        t3.setEntry(irow,1,t1_colElements{irow}{1});
        t3.setEntry(irow,2,t1_colElements{irow}{2});
        t3.setEntry(irow,3,t1_colElements{irow}{3});
        t3.setEntry(irow,4,t1_colElements{irow}{4});
        t3.setEntry(irow,5,t1_colElements{irow}{5});

        if allWarning&&~strcmp(t1_colElements{irow}{5},'warning')
            allWarning=false;
        end
    end
end


