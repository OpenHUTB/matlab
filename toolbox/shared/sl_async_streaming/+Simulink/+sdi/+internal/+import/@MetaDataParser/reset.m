function reset(this,sigNames,colIndices)



    this.ParsedValues=repmat(struct(),size(sigNames));


    if~isempty(sigNames)

        props=Simulink.sdi.internal.import.MetaDataParser.getMetaDataProperties();
        for idx=1:numel(props)
            this.ParsedValues(1).(props{idx})='';
        end


        for idx=1:numel(sigNames)
            this.ParsedValues(idx).Name=sigNames{idx};
            this.ParsedValues(idx).OrigColIdx=colIndices(idx);
            this.ParsedValues(idx).OverridePortIndex=false;
        end
    end
end
