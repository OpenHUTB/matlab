function[formatTemplate1,formatTemplate2]=utilCreateAdvisorError(me,altMessage,listTitle,...
    listBody,recomendationKey,simscapeModel,useModelName)


    formatTemplate1=ModelAdvisor.FormatTemplate('ListTemplate');

    setSubResultStatus(formatTemplate1,'Fail');


    if~isempty(altMessage)
        errorText=altMessage;
    else
        errorText=me.message();
    end

    setSubResultStatusText(formatTemplate1,ModelAdvisor.Text(errorText));

    setSubBar(formatTemplate1,0);



    if~isempty(recomendationKey)
        formatTemplate2=ModelAdvisor.FormatTemplate('ListTemplate');

        if~isempty(listTitle)
            setSubResultStatusText(formatTemplate2,ModelAdvisor.Text(listTitle));
        end

        if~isempty(listBody)
            setListObj(formatTemplate2,listBody);
        end



        if useModelName
            setRecAction(formatTemplate2,...
            ModelAdvisor.Text(message(strcat('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:',...
            recomendationKey),simscapeModel).getString));
        else
            setRecAction(formatTemplate2,...
            ModelAdvisor.Text(message(strcat('hdlcoder:hdlssc:ssccodegenworkflow_SwitchedLinearWorkflow:',...
            recomendationKey)).getString));
        end
        setSubBar(formatTemplate2,0);
    else
        formatTemplate2=[];
    end


end
