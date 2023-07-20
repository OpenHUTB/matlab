function[options,res]=setOptions(obj,newOptions)




    [options,res]=getOptions(obj);

    fn=fieldnames(newOptions);
    resetReportLink=false;
    for idx=1:numel(fn)
        cfn=fn{idx};
        options.(cfn)=newOptions.(cfn);
        if~isequal(cfn,'showReport')
            resetReportLink=true;
        end
    end
    if resetReportLink
        resetLastReportLinks(obj);
    end
    options.applyToModel(obj.modelToSyncOptions);
end