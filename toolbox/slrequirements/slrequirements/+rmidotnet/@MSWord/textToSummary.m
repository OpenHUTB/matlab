function summary=textToSummary(text)
    if isempty(text)
        summary='';
        return;
    end




    summary=text;


    crOrTab=find(summary==9|summary==10|summary==13);
    if~isempty(crOrTab)
        summary(crOrTab(1):end)=[];
    end






    if length(summary)>50
        summary=[summary(1:32),'...'];
    end
end
