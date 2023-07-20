

function status=hasCxxSources(sourceFiles)
    status=false;
    for fidx=1:numel(sourceFiles)
        [~,~,fext]=fileparts(string(sourceFiles(fidx)));
        if ismember(lower(fext),{'.cxx','.cpp','.c++'})||fext==".C"
            status=true;
            return
        end
    end
end

