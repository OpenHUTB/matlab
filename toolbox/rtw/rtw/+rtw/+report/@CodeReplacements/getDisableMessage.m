function out=getDisableMessage(obj)
    model=obj.ModelName;
    if~isempty(obj.SourceSubsystem)
        model=strtok(obj.SourceSubsystem,':/');
    end
    out=DAStudio.message('RTW:report:CodeReplacementReportDisabled',model);
end
