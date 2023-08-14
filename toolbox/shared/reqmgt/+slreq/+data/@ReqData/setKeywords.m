function setKeywords(this,reqLinkObj,givenKeywords)








    if isa(reqLinkObj,'slreq.datamodel.Link')||isa(reqLinkObj,'slreq.datamodel.RequirementItem')
        mfObj=reqLinkObj;
    else
        mfObj=this.getModelObj(reqLinkObj);
    end


    if isempty(givenKeywords)
        keywords='';
    else
        if isstring(givenKeywords)
            keywords=givenKeywords;
        elseif iscell(givenKeywords)
            keywords=string(givenKeywords);
        elseif ischar(givenKeywords)
            keywords=strsplit(string(givenKeywords),',');
        else
            error('Invalid input for keywords. String, cell array of character vectors or comma-separated charactor vector is supported for specifying keywords.');
        end
    end


    mfObj.keywords.clear();

    if~isempty(keywords)

        for n=1:length(keywords)
            keyword=strtrim(keywords{n});
            mfObj.keywords.add(keyword);
        end
    end
end
