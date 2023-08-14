function snapshots=mapSnapshots(rptFile,baseDir)







    if nargin<2
        baseDir='';
    end

    snapshots=containers.Map('KeyType','char','ValueType','char');
    fid=fopen(rptFile);
    content='';
    while 1
        line=fgetl(fid);
        if~ischar(line),break,end
        content=[content,char(10),line];%#ok<AGROW>
    end
    fclose(fid);


    matchNames=regexp(content,'<b>Snapshot for ([^<]+)\.&nbsp;</b>','tokens');
    matchPictures=regexp(content,'<img src="(\./[^"]+)"','tokens');

    if size(matchNames)==size(matchPictures)
        for i=1:length(matchNames)
            name=oslc.unescapeHtml(matchNames{i}{1});
            picture=matchPictures{i}{1};
            if~isempty(baseDir)
                picture=strrep(picture,'./snapshots_html_files',baseDir);
            end
            snapshots(name)=picture;
        end
    else
        error(message('Slvnv:reqmgt:doorssync:FailedToParseContents',rptFile));
    end
end
