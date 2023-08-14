function ds=constructDatasetFromMetaData(this)




    ds={};
    for idx=1:numel(this.ParsedValues)
        sig=this.constructSignalFromMetaData(idx);
        ds{end+1}=sig;%#ok
    end
end
