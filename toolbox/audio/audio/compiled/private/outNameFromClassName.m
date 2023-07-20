function outName=outNameFromClassName(className)







    idx=find(className=='.',1,'last');
    if~isempty(idx)
        outName=className(idx+1:end);

    else
        outName=className;
    end
end

