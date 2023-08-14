function resultJSON=modelAdvisorHighlight(operation,paraName,status)

    if strcmp(operation,'UPDATE')
        if strcmp(paraName,'exclusion')
            setpref('modeladvisor','ShowExclusionsOnGUI',status);
        elseif strcmp(paraName,'checkresult')
            setpref('modeladvisor','ShowInformer',status);
        end
    end

    exclusion=getpref('modeladvisor','ShowExclusionsOnGUI');
    checkresult=getpref('modeladvisor','ShowInformer');

    highlightStatus=struct('exclusion',exclusion,'checkresult',checkresult);

    result=struct('success',true,'message',jsonencode(struct('title','','content','')),'warning',false,'filepath','','value',jsonencode(highlightStatus));
    resultJSON=jsonencode(result);
end