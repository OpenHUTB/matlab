function result=actionModelSettings(taskobj)





    mdladvObj=taskobj.MAObj;
    system=mdladvObj.System;

    [~]=mdladvObj.CheckCellArray{mdladvObj.ActiveCheckID};

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    mdl_o=get_param(bdroot(system),'Object');

    t1_numRow=0;












    paramCell={'SystemTargetFile','AlgebraicLoopMsg','InlineParams',...
    'BlockReduction','ConditionallyExecuteInputs','ProdHWDeviceType'};
    displayCell={'System Target File','Algebraic Loop','Inline parameters',...
    'Block reduction','Conditional input branch execution','Device type'};
    expectCell={{'grt.tlc','ert.tlc'},{'error'},{'on'},{'off'},{'off'},{'ASIC/FPGA->ASIC/FPGA','ASIC/FPGA'}};

    text='';
    try
        for i=1:length(paramCell)
            param=paramCell{i};
            paramValue=get_param(bdroot(system),param);
            expectValue=expectCell{i};
            if~any(strcmp(paramValue,expectValue))

                set_param(bdroot(system),param,expectValue{1});


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
            end
        end

        if t1_numRow>0

            t3=drawReportTable(t1_colElements,t1_numRow);
            text=[lb,t3.emitHTML];
        end

    catch me

        result=publishFailedMessage(mdladvObj,me.message);

        return;
    end

    Passed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGPassed'),{'Pass'});
    result=[Passed.emitHTML,text];

end

function t3=drawReportTable(t1_colElements,t1_numRow)

    t3=ModelAdvisor.Table(t1_numRow,4);
    txt=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:HDLWAReportTableTitle'));
    t3.setHeading(txt.emitHTML);
    t3.setHeadingAlign('center');
    t3.setColHeading(1,DAStudio.message('HDLShared:hdldialog:MSGBlock'));
    t3.setColHeading(2,DAStudio.message('HDLShared:hdldialog:MSGSettings'));
    t3.setColHeading(3,DAStudio.message('HDLShared:hdldialog:MSGPrevious'));
    t3.setColHeading(4,DAStudio.message('HDLShared:hdldialog:MSGCurrent'));

    for irow=1:t1_numRow
        t3.setEntry(irow,1,t1_colElements{irow}{1});
        t3.setEntry(irow,2,t1_colElements{irow}{2});
        t3.setEntry(irow,3,t1_colElements{irow}{3});
        t3.setEntry(irow,4,t1_colElements{irow}{4});
    end
end
