function[ResultDescription,ResultDetails]=CheckDiscDriveContSignal(system)





    ResultDescription={};
    ResultDetails={};
    mdladvObj=Simulink.ModelAdvisor.getModelAdvisor(system);
    model=bdroot(system);
    hScope=get_param(system,'Handle');
    hModel=get_param(model,'Handle');

    currentCheck=mdladvObj.getCheckObj('com.mathworks.Simulink.PerformanceAdvisor.CheckDiscDriveContSignal');


    Passed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Passed'),{'bold','pass'});




    result_paragraph=ModelAdvisor.Paragraph;


    baseLineBefore=utilGetOverallBaseline(mdladvObj);

    baseLineAfter=utilCreateEmptyBaseline(DAStudio.message('SimulinkPerformanceAdvisor:advisor:CheckDiscDriveContSignal'));

    utilUpdateBaseline(mdladvObj,currentCheck,baseLineBefore,baseLineAfter);



    if(hScope==hModel)
        try

            eval([model,'([],[],[], ''compile'')']);
            troublespots=feval(model,'get','discDerivSig');
            istrouble=true(size(troublespots));
            eval([model,'([],[],[], ''term'')']);

            for i=1:length(istrouble)
                if isempty(mdladvObj.filterResultWithExclusion(troublespots(i).block))
                    istrouble(i)=false;
                end
            end
            troublespots=troublespots(istrouble);

        catch ME
            [ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,ME.message,ME.cause);
            return
        end

        if(~isempty(troublespots))
            Pass=false;
        else
            Pass=true;
        end

    else
        Pass=true;
        mdladvObj.setCheckResultStatus(true);
    end



    if~Pass


        result_text=ModelAdvisor.Text(DAStudio.message('Simulink:tools:MAMsgNonContSigDerivPort'));
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
        result_text=ModelAdvisor.Text(['<table border="1" cellpadding="2">',DAStudio.message('Simulink:tools:MAMsgContSrcLocationHeader')]);
        result_paragraph.addItem(result_text);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);


        for i=1:length(troublespots)
            mangledname=modeladvisorprivate('HTMLjsencode',troublespots(i).block,'encode');
            mangledname=[mangledname{:}];
            dispname=regexprep(troublespots(i).block,newline,' ');
            text=DAStudio.message('Simulink:tools:MAMsgContSrcLocation',mangledname,dispname,troublespots(i).port,troublespots(i).idx,troublespots(i).width);
            result_text=ModelAdvisor.Text(text);
            result_paragraph.addItem(result_text);
        end

        text=['</table>',newline,DAStudio.message('Simulink:tools:MAMsgNonContSigDerivPortSuggest')];
        result_text=ModelAdvisor.Text(text);
        result_paragraph.addItem(result_text);
    else

        result_paragraph.addItem(Passed);
        result_paragraph.addItem([ModelAdvisor.LineBreak,ModelAdvisor.LineBreak]);
    end


    ResultDescription{end+1}=result_paragraph;
    ResultDetails{end+1}='';



    mdladvObj.setCheckResultStatus(Pass);

    if~Pass

        mdladvObj.setCheckErrorSeverity(0);



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
