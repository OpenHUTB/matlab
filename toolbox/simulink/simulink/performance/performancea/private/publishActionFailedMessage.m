function text=publishActionFailedMessage(ME,whatFailed)




    Failed=ModelAdvisor.Text(DAStudio.message('SimulinkPerformanceAdvisor:advisor:Failed'),{'bold','fail'});

    lb=ModelAdvisor.LineBreak;
    lb=lb.emitHTML;

    cause=ME.cause;
    message=ME.message;

    causeText='';
    if~isempty(cause)
        causeText=['Cause:',lb,lb];
        causeText=[lb,lb,causeText,cause{1}.message];
    end

    text=ModelAdvisor.Text([Failed.emitHTML,lb,whatFailed,lb,lb,message,causeText]);

end
