function cacheContents(sid,html)




    cacheDir=rmi.Informer.cache('cacheDir');


    baseDir=rmi.Informer.cache('baseDir');
    if strcmp(baseDir,'../')




        html=matlabToConnector(html);





        if~isempty(regexpi(html,'\ssrc=','once'))
            html=appendFileProtocol(html);
        end
    else
        if~strcmp(baseDir,'..')



            if~rmipref('ReportNavUseMatlab')


                html=stripMatlabLinks(html);
            end
        end
        html=localizeImageLinks(html,cacheDir);
    end

    fName=strrep(sid,':','__');
    fPath=fullfile(cacheDir,[fName,'.htm']);
    fid=fopen(fPath,'w','n','utf-8');
    html=wrapWithEncoding(html);
    fwrite(fid,html,'char*1');
    fclose(fid);
end

function html=wrapWithEncoding(html)
    html=['<html><head><meta charset="UTF-8"></head><body>',char(10)...
    ,html,'</body></html>',char(10)];
end

function html=stripMatlabLinks(html)



    baseDir=rmi.Informer.cache('baseDir');

    docLinkPos=regexp(html,'<a href="matlab:rmi.navigate\(''[^'']+'',''[^'']+'','''',''[^'']+''\)');
    if~isempty(docLinkPos)
        prefixLength=length('<a href="');
        for i=length(docLinkPos):-1:1
            pos=docLinkPos(i)+prefixLength;
            quotes=strfind(html(pos:end),'"');
            if isempty(quotes)
                continue;
            end
            endOfRef=pos+quotes(1)-1;
            docData=regexp(html(pos:endOfRef),'matlab:rmi.navigate\(''([^'']+)'',''([^'']+)'','''',''([^'']+)''\)','tokens');
            if~isempty(docData)
                docType=docData{1}{1};
                linkType=rmi.linktype_mgr('resolveByRegName',docType);
                if isempty(linkType)||~linkType.IsFile
                    continue;
                end
                docName=docData{1}{2};
                docRef=docData{1}{3};
                fullPath=rmisl.locateFile(docName,docRef);
                if isempty(fullPath)||~exist(fullPath,'file')
                    continue;
                else
                    [~,fname,fext]=fileparts(fullPath);





                    exportableName=strrep(fname,' ','__');
                    localFilePath=[baseDir,'/',exportableName,fext];
                    html=[html(1:pos-1),localFilePath,html(endOfRef:end)];
                end
            end
        end
    end

    html=regexprep(html,'<a href="matlab:[^"]+">([^<]+)</a>','<font color="blue">$1</font>');
    html=regexprep(html,'<a href="http://(localhost|127\.0\.0\.1):\d+/matlab/feval[^"]+">([^<]+)</a>','<font color="blue">$1</font>');
end

function html=matlabToConnector(html)


    navCmdData=regexp(html,'<a href="matlab:(rmi.navigate\(''[^)]+\);)','tokens');
    if isempty(navCmdData)
        return;
    end
    for i=length(navCmdData):-1:1
        matchedCmd=navCmdData{i}{1};
        replaceFor=['matlab:',matchedCmd];
        pos=strfind(html,replaceFor);
        replaceWith=rmiut.cmdToUrl(matchedCmd);
        html=[html(1:pos-1),replaceWith,html(pos+length(replaceFor):end)];
    end
end

function html=localizeImageLinks(html,localDir)


    parentDir=fileparts(localDir);

    baseDir=rmi.Informer.cache('baseDir');
    if baseDir(1)=='.'
        parentDir=['file:///',parentDir];
    end





    pathLength=length(parentDir);
    localPathIdx=strfind(html,parentDir);
    for i=length(localPathIdx):-1:1
        pathStart=localPathIdx(i);
        html=[html(1:pathStart-1),baseDir,html(pathStart+pathLength:end)];
    end

    if ispc
        parentDirForwardSlash=strrep(parentDir,'\','/');
        localPathIdx=strfind(html,parentDirForwardSlash);
        for i=length(localPathIdx):-1:1
            pathStart=localPathIdx(i);
            html=[html(1:pathStart-1),baseDir,html(pathStart+pathLength:end)];
        end
    end
end

function html=appendFileProtocol(html)
    imgSrcPositions=regexpi(html,'\ssrc=');
    patternLength=length(' src="');
    for i=length(imgSrcPositions):-1:1
        pos=imgSrcPositions(i);
        if html(pos+patternLength+4)==':'
            continue;
        else
            html=[html(1:pos+patternLength-1),'file://',html(pos+patternLength:end)];
        end
    end
end


