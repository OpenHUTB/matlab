function[source,proxies]=findSource(myGraph,srcName,srcType,isLoading)

    [~,sName,sExt]=fileparts(srcName);
    sourceName=[sName,sExt];

    sources=[];
    proxies={};

    for r=1:myGraph.roots.size
        root=myGraph.roots.at(r);
        if~isempty(srcType)&&~strcmp(root.getProperty('source'),srcType)

            continue;
        end
        filesepName=strrep(root.url,'\',filesep);
        [fDir,fName,fExt]=fileparts(filesepName);
        if ispc
            isMatch=strcmpi([fName,fExt],sourceName);
        else
            isMatch=strcmp([fName,fExt],sourceName);
        end
        if isMatch
            if~isempty(fDir)&&fDir(1)~='.'
                sources=[sources,root];%#ok<AGROW>
            else
                proxies=[proxies,{root.url}];%#ok<AGROW>
            end
        end
    end

    switch length(sources)
    case 1
        source=sources;
    case 0
        source=[];
    otherwise
        source=findBestMatch(sources,isLoading);
        if isempty(source)
            fprintf(1,'RMI: %s\n',getString(message('Slvnv:rmiml:RepositoryCantChoose',sourceName)));
        else
            fprintf(1,'RMI: %s\n',getString(message('Slvnv:rmiml:RepositoryUsingLatest',sourceName)));
        end
    end
end


function src=findBestMatch(roots,isLoading)
    best=1;
    value=whenLastLoaded(roots(best));
    for i=2:length(roots)
        current=whenLastLoaded(roots(i));

        if isLoading&&current<value
            value=current;
            best=i;
        elseif~isLoading&&current>value
            value=current;
            best=i;
        elseif current==value
            best=[best,i];%#ok<AGROW>
        end
    end
    if length(best)>1
        src=[];
    else
        src=roots(best);
    end
end


function timeNum=whenLastLoaded(root)
    timeStr=root.getProperty('lastLoaded');
    if isempty(timeStr)
        timeNum=0;
    else
        timeNum=str2double(timeStr);
    end
end



