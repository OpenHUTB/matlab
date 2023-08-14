function genMessageCatalog()











    msgCatalog=containers.Map();
    msgHolesMap=containers.Map();
    maxNumOfHoles=0;

    msgPath=fullfile(matlabroot,'resources','stm','en');
    xmlFiles=dir(fullfile(msgPath,'*.xml'));
    for fileK=1:length(xmlFiles)
        xmlFile=fullfile(msgPath,xmlFiles(fileK).name);
        [~,fileId,~]=fileparts(xmlFile);
        xmlDoc=xmlread(xmlFile);
        allEntries=xmlDoc.getElementsByTagName('entry');
        for msgK=0:allEntries.getLength-1
            entry=allEntries.item(msgK);
            entryId=entry.getAttribute('key');

            childNode=entry.getFirstChild;
            entryValue=char(childNode.getWholeText());

            holeIdx=-1*zeros(1,10);

            pattern=regexpPattern("{\d+}");
            extractedVals=extract(string(entryValue),pattern);
            tmp=arrayfun(@(s)str2double(s.extractBetween(2,s.strlength-1)),...
            extractedVals);
            nHoles=length(tmp);
            if(~isempty(tmp))
                holeIdx(1:nHoles)=tmp;
            end
            holeIdx=sort(holeIdx,'descend');
            tmp=unique(holeIdx(1:nHoles));
            nHoles=length(tmp);
            if(nHoles>maxNumOfHoles)
                maxNumOfHoles=nHoles;
            end
            msgId=sprintf('stm:%s:%s',fileId,char(entryId));
            if(strcmp(msgId,'stm:general:TooManyRunOnTargetElements'))
                continue;
            end
            msgHolesMap(msgId)=nHoles;
        end
    end

    tokenList={'$$$$#1','$$$$#2','$$$$#3','$$$$#4','$$$$#5','$$$$#6'};
    assert(maxNumOfHoles<=length(tokenList));

    keys=msgHolesMap.keys();
    for k=1:length(keys)
        msgId=keys{k};
        nHoles=msgHolesMap(msgId);

        if(nHoles==0)
            msg=getString(message(msgId));
        elseif(nHoles==1)
            msg=getString(message(msgId,tokenList{1}));
        elseif(nHoles==2)
            msg=getString(message(msgId,tokenList{1},tokenList{2}));
        elseif(nHoles==3)
            msg=getString(message(msgId,tokenList{1},tokenList{2},tokenList{3}));
        elseif(nHoles==4)
            msg=getString(message(msgId,tokenList{1},tokenList{2},tokenList{3},...
            tokenList{4}));
        elseif(nHoles==5)
            msg=getString(message(msgId,tokenList{1},tokenList{2},tokenList{3},...
            tokenList{4},tokenList{5}));
        elseif(nHoles==6)
            msg=getString(message(msgId,tokenList{1},tokenList{2},tokenList{3},...
            tokenList{4},tokenList{5},tokenList{6}));
        end
        msgCatalog(msgId)=msg;
    end

    poolInfo=stm.internal.MRT.mrtpool.getWorkerInfo();
    matlabVer=ver('matlab');%#ok<NASGU>
    save(poolInfo.hostMsgCatalog,'msgCatalog','msgHolesMap','tokenList','matlabVer');
end

