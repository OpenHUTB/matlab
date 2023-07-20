function actual_name=mapToActualName(topModelName,alias_name)

    mapping_text=[topModelName,'_mapping.txt'];
    bdir=RTW.getBuildDir(topModelName);
    mapfilefullpath=fullfile(bdir.BuildDirectory,mapping_text);
    if(isfile(mapfilefullpath))
        fd=fopen(mapfilefullpath);
        pattern=['ActualName\s=\s(?<Actual>\w+),\sAliasName\s=\s(?<Alias>\',alias_name,')'];
        mappingData=fread(fd,'*char')';
        match=regexp(mappingData,pattern,'names');
        if(isempty(match))
            actual_name=alias_name;
        else
            actual_name=match.Actual;
        end
        fclose(fd);
    else
        actual_name=alias_name;
    end

end