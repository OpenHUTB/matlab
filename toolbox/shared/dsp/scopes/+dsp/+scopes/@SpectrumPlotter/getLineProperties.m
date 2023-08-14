function props=getLineProperties(this,lineNum)








    if isempty(this.LinePropertiesCache)
        props=getFactoryLineProperties(this,lineNum);
    elseif isempty(this.Lines)||(lineNum>numel(this.Lines))

        if lineNum<=numel(this.LinePropertiesCache)
            props=this.LinePropertiesCache{lineNum};
        else
            props=getFactoryLineProperties(this,lineNum);
        end
    else
        propNames=this.LinePropertyNames;
        propsCell=get(this.Lines(lineNum),propNames);
        props=cell2struct(propsCell,propNames,2);
    end
end
