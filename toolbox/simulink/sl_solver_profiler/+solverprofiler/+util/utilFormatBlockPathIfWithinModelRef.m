


function blockPath=utilFormatBlockPathIfWithinModelRef(paths)
    if iscell(paths)
        blockPath=strrep(paths{1},newline,' ');
        for i=2:length(paths)
            blockPath=[blockPath,'|',strrep(paths{i},newline,' ');];
        end
    else
        blockPath=strrep(paths,newline,' ');
    end

    if contains(blockPath,'/ SFunction ')
        blockPath=strrep(blockPath,'/ SFunction ','');
    else
        blockPath=strrep(blockPath,'/ SFunction','');
    end

end