function optionsArray=filterTlcOptions(h,optionsArray)






    idx=[];
    for i=1:numel(optionsArray)
        if isequal(optionsArray(i).name,'compilerOptionsStr')
            idx(end+1)=i;%#ok<AGROW>
        end
        if isequal(optionsArray(i).name,'linkerOptionsStr')
            idx(end+1)=i;%#ok<AGROW>
        end
    end
    optionsArray(idx)=[];
