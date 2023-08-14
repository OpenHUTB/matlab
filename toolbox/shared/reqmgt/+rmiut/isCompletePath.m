function yesno=isCompletePath(fPath)




    fPath=convertStringsToChars(fPath);

    if~isempty(regexp(fPath,'^https?:','once'))

        yesno=true;

    else

        yesno=length(fPath)>=2&&...
        (fPath(2)==':'||fPath(1)=='/'||fPath(1)=='\'||fPath(1)==filesep);
    end
end
