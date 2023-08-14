function[ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,...
    message,cause,ResultDescription,ResultDetails,fullErrorStack)







    if nargin<6
        fullErrorStack='';
    end

    if nargin<5
        ResultDetails={};
    end

    if nargin<4
        ResultDescription={};
    end

    if nargin<3
        cause=[];
    end




    Failed=ModelAdvisor.Text(DAStudio.message('HDLShared:hdldialog:MSGFailed'),{'Fail'});

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;


    text=ModelAdvisor.Text([Failed.emitHTML,message]);
    ResultDescription{end+1}=[text.emitHTML,lb];
    ResultDetails{end+1}='';


    if~isempty(cause)
        causeText=[DAStudio.message('HDLShared:hdldialog:CauseStr'),lb,lb];
        causeText=[causeText,cause{1}.message];

        text=ModelAdvisor.Text(causeText);
        ResultDescription{end+1}=[text.emitHTML,lb];
        ResultDetails{end+1}='';
    end



    if~isempty(fullErrorStack)
        [ResultDescription,ResultDetails]=utilDisplayResult(fullErrorStack,...
        ResultDescription,ResultDetails,true);
    end

    mdladvObj.setCheckResultStatus(false);

end


