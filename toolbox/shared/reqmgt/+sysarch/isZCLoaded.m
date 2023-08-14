function isLoaded=isZCLoaded(zcModelNames)






    if ischar(zcModelNames)&&isvarname(zcModelNames)
        zcModelNames={zcModelNames};
    elseif iscell(zcModelNames)
        zcModelNames=cellstr(zcModelNames);
        valid=cellfun(@isvarname,zcModelNames);
        if any(~valid)

        end
    elseif(isstring(zcModelNames))
        zcModelNames=cellstr(zcModelNames);
    else

    end
    all_loaded=find_system('SearchDepth',0);
    isLoaded=slcellmember(zcModelNames,all_loaded);
end

