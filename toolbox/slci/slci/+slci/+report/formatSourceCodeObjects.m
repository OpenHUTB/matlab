




function sourceList=formatSourceCodeObjects(sourceObjs)

    numSources=numel(sourceObjs);

    fileMap=containers.Map;
    numFiles=0;
    for k=1:numSources
        thisObj=sourceObjs{k};
        thisFile=thisObj.getFileName();
        thisLine=thisObj.getLineNumber();
        if isKey(fileMap,thisFile)
            lineNums=fileMap(thisFile);
            lineNums(end+1)=thisLine;%#ok
            fileMap(thisFile)=lineNums;
        else
            fileMap(thisFile)=thisLine;
            numFiles=numFiles+1;
        end
    end


    sourceList(numFiles)=struct('SOURCEOBJ',[]);
    fileNames=keys(fileMap);
    for k=1:numFiles
        thisFile=fileNames{k};
        lineNums=fileMap(thisFile);
        lineNums=sort(lineNums);
        lineStr=getConsecutiveLines(lineNums);
        sourceList(k).SOURCEOBJ.CONTENT=[thisFile,':',lineStr];
    end

end


function lineFormat=getConsecutiveLines(lineNums)

    nlines=numel(lineNums);

    if nlines==0
        lineFormat=[];
        return;
    end

    if nlines==1
        lineFormat=num2str(lineNums(1));
    else



        lineFormat=[];
        startLine=lineNums(1);
        for k=2:numel(lineNums)
            thisLine=lineNums(k);
            prevLine=lineNums(k-1);

            if thisLine~=prevLine+1
                if startLine==prevLine


                    lineStr=[num2str(prevLine),' , '];
                else


                    lineStr=[num2str(startLine),'-',num2str(prevLine),' , '];
                end
                lineFormat=[lineFormat,lineStr];%#ok

                startLine=thisLine;
            end
        end

        if startLine==lineNums(nlines)
            lineStr=num2str(startLine);
        else
            lineStr=[num2str(startLine),'-',num2str(lineNums(nlines))];
        end
        lineFormat=[lineFormat,lineStr];
    end
end
