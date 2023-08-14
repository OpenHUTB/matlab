



function result=styleguide_jmaab_0742_conditionsPerLine(input,numConditions)
    result=true;
    if isempty(input)||numConditions<2
        return;
    end

    if iscell(input)
        input=input{1};
    end

    allStrs=strsplit(input,newline,'CollapseDelimiters',true);

    for idx=1:length(allStrs)
        str=cell2mat(allStrs(idx));
        str(regexp(str,'[\[\]\(\)\s]'))=[];
        arr=strsplit(str,{'&&','||'},'CollapseDelimiters',true);
        arr=arr(~cellfun('isempty',arr));
        if(length(arr)>numConditions)
            result=false;
            return;
        end
    end
    return;
end