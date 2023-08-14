function[asString,asCell]=getKeywords(dataObj)




    asCell=dataObj.keywords;
    if isempty(asCell)
        asString='';
    else
        allKeywords=sprintf('%s,',asCell{:});
        asString=allKeywords(1:end-1);
    end
end
