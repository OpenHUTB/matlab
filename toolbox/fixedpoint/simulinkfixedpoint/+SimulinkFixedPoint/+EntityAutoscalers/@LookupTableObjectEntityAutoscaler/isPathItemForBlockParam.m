function[isForBlockParameter,blockParameterName]=isPathItemForBlockParam(~,~,pathItem)





    isForBlockParameter=false;
    blockParameterName='';


    if strcmp(pathItem,'Table')||startsWith(pathItem,'Breakpoint')
        isForBlockParameter=true;
        blockParameterName=pathItem;
    end
end


