function[ResultDescription,ResultDetails]=publishFailedMessage(mdladvObj,message,cause,ResultDescription,ResultDetails)



    if nargin<5
        ResultDetails={};
    end

    if nargin<4
        ResultDescription={};
    end

    if nargin<3
        cause=[];
    end





    Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Failed'),{'bold','fail'});

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    causeText='';

    Cause=DAStudio.message('SimulinkPerformanceAdvisor:advisor:Cause');

    if~isempty(cause)
        causeText=[Cause,':',lb,lb];
        causeText=[causeText,cause{1}.message];
    end

    text=ModelAdvisor.Text([Failed.emitHTML,lb,lb,message,lb,lb,causeText]);

    ResultDescription{end+1}=[text.emitHTML,lb];
    ResultDetails{end+1}='';
    mdladvObj.setCheckResultStatus(false);
end
