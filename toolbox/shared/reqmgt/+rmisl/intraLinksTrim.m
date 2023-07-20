function reqs=intraLinksTrim(reqs,modelName)



    isSameModel=strcmp({reqs.doc},modelName);
    if any(isSameModel)
        pattern=['^',modelName,'/'];
        for i=find(isSameModel)
            reqs(i).doc='$ModelName$';
            reqs(i).description=regexprep(reqs(i).description,pattern,'/');
        end
    end
end

