function storeAllLineProperties(this)






    propNames=this.LinePropertyNames;
    if~isempty(this.Lines)&&numel(this.Lines)==this.NumberOfChannels
        for lineNum=1:this.NumberOfChannels
            propsCell=get(this.Lines(lineNum),propNames);
            props=cell2struct(propsCell,propNames,2);
            cacheLineProperties(this,lineNum,props,true)
        end
    end
    if~isempty(this.MaxHoldTraceLines)&&numel(this.MaxHoldTraceLines)==this.NumberOfChannels
        for lineNum=1:this.NumberOfChannels
            propsCell=get(this.MaxHoldTraceLines(lineNum),propNames);
            props=cell2struct(propsCell,propNames,2);
            cacheMaxMinHoldLineProperties(this,lineNum,props,true,'Max');
        end
    end
    if~isempty(this.MinHoldTraceLines)&&numel(this.MinHoldTraceLines)==this.NumberOfChannels
        for lineNum=1:this.NumberOfChannels
            propsCell=get(this.MinHoldTraceLines(lineNum),propNames);
            props=cell2struct(propsCell,propNames,2);
            cacheMaxMinHoldLineProperties(this,lineNum,props,true,'Min');
        end
    end
end
