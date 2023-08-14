function reqs=intraLinksResolve(reqs,source)







    if ischar(source)
        modelName=strtok(source,'/');
    else
        modelName=get_param(source,'Name');
    end

    if rmisl.isComponentHarness(modelName)


        [~,modelName]=fileparts(get_param(source,'FileName'));
    end

    isSameModel=strncmp({reqs.doc},'$ModelName$',length('$ModelName$'));
    if any(isSameModel)
        for i=find(isSameModel)
            reqs(i).doc=strrep(reqs(i).doc,'$ModelName$',modelName);
            reqs(i).description=regexprep(reqs(i).description,'^/',[modelName,'/']);
        end
    end
end