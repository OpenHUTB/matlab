

function[headers,sources]=getSourcesAndHeaders(fileList)
    headers=string([]);
    sources=string([]);
    for fidx=1:numel(fileList)
        f=fileList(fidx);
        if f.endsWith('.h')||f.endsWith('.hpp')
            headers(end+1)=f;%#ok<AGROW>
        else
            if f.endsWith('.c')||f.endsWith('.cpp')
                sources(end+1)=f;%#ok<AGROW>
            end
        end
    end
end

