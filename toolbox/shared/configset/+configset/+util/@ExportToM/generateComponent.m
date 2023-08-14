function generateComponent(obj,cc)


    str=['% ',cc.Name];

    paramStr=obj.generateParameters(cc,'',true);

    if~isempty(paramStr)
        obj.buffer{end+1}=sprintf('%s\n%s',str,paramStr);
    end

