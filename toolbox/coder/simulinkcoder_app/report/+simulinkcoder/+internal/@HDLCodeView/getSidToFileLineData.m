function data=getSidToFileLineData(obj,sid,traceInfo,isStateFlowObj)



    data=[];
    idxs=arrayfun(@(x)strcmpi(x.sid,sid)==1,traceInfo);
    sidInfo=traceInfo(idxs);

    if isempty(sidInfo)
        if isStateFlowObj
            h=Simulink.ID.getHandle(sid);
            if isprop(h,'Name')
                blkName=h.Name;
            else
                blkName=class(h);
            end
        else
            blkName=get_param(sid,'name');
        end
        data.error=message('hdlcoder:report:noTraceInfoAvailable',blkName).getString;
        return;
    end
    locs=sidInfo.location;
    if isempty(locs)
        data.error=message('hdlcoder:report:noTraceInfoAvailable',sidInfo.rtwname).getString;
        return;
    end


    data=struct('file',cell(1,length(locs)),'line',cell(1,length(locs)));
    for i=1:length(locs)
        loc=locs(i);
        fullFile=loc.file;
        slashIndexes=strfind(fullFile,filesep);
        if~isempty(slashIndexes)
            fileName=extractAfter(fullFile,slashIndexes(end));
        end
        data(i).file=fileName;
        data(i).line=loc.line;
    end
end


