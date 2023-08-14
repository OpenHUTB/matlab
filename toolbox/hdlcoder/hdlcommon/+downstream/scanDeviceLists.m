function map=scanDeviceLists(toolName)



    persistent localMap;
    if(isempty(localMap))
        localMap=containers.Map('KeyType','char','ValueType','any');
    end

    if(localMap.isKey(toolName))
        map=localMap(toolName);
        return;
    end

    if(isempty(toolName))
        map=containers.Map('KeyType','char','ValueType','any');
        return;
    end
    fstr='';
    downstreamToolsDir=fullfile(matlabroot,'toolbox','hdlcoder','hdlcommon','+downstreamtools');
    dd=dir(fullfile(downstreamToolsDir,['*',toolName,'*']));
    for i=1:length(dd)
        d=dd(i);
        if(~d.isdir)
            continue;
        end
        fileName=fullfile(downstreamToolsDir,d.name,'device_list.xml');
        if exist(fileName,'file')~=2
            continue;
        end
        str=fileread(fileName);
        fstr=[fstr,str];
    end
    isQuartus=~isempty(strfind(toolName,'Quartus'));
    map=parseDeviceList1(fstr,isQuartus);
    localMap(toolName)=map;
end

function familyMap=parseDeviceList1(str,isQuartus)
    longlongStrech=300;
    longStrech=60;
    shortStrech=30;
    familyMap=containers.Map('KeyType','char','ValueType','any');
    str=regexprep(str,'>\s*<','><');
    curIdx=1;
    while(true)
        last=min(curIdx+longlongStrech,length(str));
        tempIdx=strscan(str(curIdx:last),curIdx,'<DeviceData>');
        if(isempty(tempIdx))
            break;
        end
        curIdx=tempIdx;
        while(true)
            last=min(curIdx+longStrech,length(str));
            tempIdx=strscan(str(curIdx:last),curIdx,'<Family id="');
            if(isempty(tempIdx))
                break;
            end
            curIdx=tempIdx;
            patten=' name="';
            curIdx=strscan(str(curIdx:curIdx+longStrech),curIdx,patten);
            fmidx=curIdx+length(patten);
            curIdx=strscan(str(curIdx:curIdx+longStrech),curIdx,'">');
            fmidx1=curIdx;
            fmName=str(fmidx:fmidx1-1);

            if(familyMap.isKey(fmName))
                deviceMap=familyMap(fmName);
            else
                deviceMap=containers.Map('KeyType','char','ValueType','any');
                familyMap(fmName)=deviceMap;
            end
            while(true)
                patten='<Device name="';
                last=min(curIdx+shortStrech,length(str));
                tempIdx=strscan(str(curIdx:last),curIdx,patten);
                if(isempty(tempIdx))
                    break;
                end
                dvidx=tempIdx+length(patten);
                curIdx=dvidx;
                curIdx=strscan(str(curIdx:curIdx+shortStrech),curIdx,'">');
                dvidx1=curIdx;
                dvName=str(dvidx:dvidx1-1);
                if(isQuartus)
                    dvOpt.pkNames={};
                    dvOpt.spNames={};
                else
                    dvOpt.pkNames=scanVect('<Package>','</Package>');
                    dvOpt.spNames=scanVect('<Speed>','</Speed>');
                end
                deviceMap(dvName)=dvOpt;
            end
        end
    end

    function vect=scanVect(patten1,patten2)
        vect={};
        while(true)
            last=min(curIdx+shortStrech,length(str));
            tempIdx=strscan(str(curIdx:last),curIdx,patten1);
            if(isempty(tempIdx))
                break;
            end
            curIdx=tempIdx;
            idx1=curIdx+length(patten1);
            last=min(curIdx+shortStrech,length(str));
            curIdx=strscan(str(curIdx:last),curIdx,patten2);
            idx2=curIdx;
            pkName=str(idx1:idx2-1);
            vect{end+1}=pkName;
        end
    end
end

function newIdx=strscan(str,curIdx,patten)
    newIdx=strfind(str,patten);
    if(length(newIdx)>1)
        newIdx=newIdx(1);
    end
    newIdx=newIdx+curIdx-1;
end

