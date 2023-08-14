function paramOptions=getParamOptions(obj,inputStr)









    objParameters=get_param(obj,'ObjectParameters');
    parameterNames=fieldnames(objParameters);
    str=split(inputStr,'@');

    arr_size=[];
    index=[];
    keywordList={'options','value'};

    if numel(str)==1
        index=strncmpi(parameterNames,char(str(1)),numel(char(str(1))));
    else
        if~(ismember(char(str(1)),keywordList))
            paramOptions=[];
            return
        end
        param=char(str(2));
        index=strncmpi(parameterNames,param,numel(param));
    end

    parameterNames=parameterNames(index);
    arr_size=numel(parameterNames);
    paramOptions=struct('name',cell(1,arr_size),'isleaf',cell(1,arr_size),'separator',cell(1,arr_size));

    paramOptions=filterParamOptions(str,parameterNames,keywordList,paramOptions,objParameters);
end

function ret=filterParamOptions(str,parameterNames,keywordList,paramOptions,objParameters)

    ret=paramOptions;

    if numel(str)~=1&&strcmp(keywordList{1},char(str(1)))
        i=1;
        for k=1:numel(parameterNames)
            if~isempty(objParameters.(parameterNames{k}).Enum)
                ret(i)=struct('name',parameterNames{k},'isleaf',true,'separator','@');
                i=i+1;
            end
        end
    else

        for i=1:numel(parameterNames)
            ret(i)=struct('name',parameterNames{i},'isleaf',true,'separator','@');
        end
    end


    if numel(str)==1

        if(isempty(char(str(1))))
            for j=1:numel(keywordList)
                ret(end+1)=struct('name',keywordList{j},'isleaf',false,'separator','@');
            end
        end

        for k=1:numel(keywordList)
            if(strncmpi(keywordList{k},char(str(1)),numel(char(str(1)))))
                ret(end+1)=struct('name',strcat(keywordList{k},'@'),'isleaf',true,'separator','@');
            end
        end
    end

end