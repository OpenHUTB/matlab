function normalized=normalizeFilenamesForCMake(filenames)









    if isempty(filenames)
        normalized=string.empty;
        return;
    end

    normalized=convertCharsToStrings(filenames);
    normalized=regexprep(normalized,'\$\((\w+)\)','\$\{$1\}');
    normalized=strrep(normalized,'\','/');
    normalized=strrep(normalized,' ','\ ');
    normalized=strrep(normalized,'(','\(');
    normalized=strrep(normalized,')','\)');
end


