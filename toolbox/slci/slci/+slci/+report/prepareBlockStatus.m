



function statusList=prepareBlockStatus(blockObjectList,datamgr,reportConfig)

    blockSliceReader=datamgr.getBlockSliceReader;
    numBlocks=numel(blockObjectList);


    if slcifeature('SLCIJustification')==1
        statusList(numBlocks)=struct('SOURCEOBJ',[],'STATUS',[],...
        'SLICELIST',[],'JUSTIFICATION',[]);
    else
        statusList(numBlocks)=struct('SOURCEOBJ',[],'STATUS',[],...
        'SLICELIST',[]);
    end


    for k=1:numBlocks

        bObject=blockObjectList{k};

        statusList(k).SOURCEOBJ.CONTENT=bObject.getCallback(datamgr);

        statusList(k).STATUS.CONTENT=...
        reportConfig.getStatusMessage(bObject.getStatus());
        statusList(k).STATUS.ATTRIBUTES=bObject.getStatus();









        blockSubstatus=bObject.getSubstatus();

        if strcmp(blockSubstatus,'VIRTUAL')||...
            strcmp(blockSubstatus,'INLINED')||...
            strcmp(blockSubstatus,'UNSUPPORTED')||...
            strcmp(blockSubstatus,'ROOTINPORT')

            statusList(k).SLICELIST.SUBSTATUS.ATTRIBUTES=blockSubstatus;
            statusList(k).SLICELIST.SUBSTATUS.CONTENT=...
            reportConfig.getReasonMessage(blockSubstatus);
            if isempty(statusList(k).SLICELIST.SUBSTATUS.CONTENT)
                statusList(k).SLICELIST.SUBSTATUS.CONTENT='-';
            end

            if isa(bObject,'slci.results.BlockObject')
                statusList(k).SLICELIST.MESSAGE.CONTENT=...
                [' (',bObject.getDispBlockType(),') '];
            else
                statusList(k).SLICELIST.MESSAGE.CONTENT='';
            end

        elseif strcmp(blockSubstatus,'OPTIMIZED')

            statusList(k).SLICELIST.SUBSTATUS.ATTRIBUTES=blockSubstatus;
            statusList(k).SLICELIST.SUBSTATUS.CONTENT=...
            reportConfig.getReasonMessage(blockSubstatus);
            if isempty(statusList(k).SLICELIST.SUBSTATUS.CONTENT)
                statusList(k).SLICELIST.SUBSTATUS.CONTENT='-';
            end


        elseif~isempty(bObject.getSliceNames())


            if strcmp(bObject.getStatus(),'VERIFIED')

                statusList(k).SLICELIST.MESSAGE.CONTENT='-';
            else
                failedSlices={};
                sliceInfo=bObject.getSliceNames();
                for p=1:numel(sliceInfo)
                    sliceName=sliceInfo{p};
                    sliceStatus=bObject.getStatusForSlice(sliceName);
                    if~strcmp(sliceStatus,'VERIFIED')
                        failedSlices{end+1}=sliceName;%#ok
                    end
                end


                sliceList=struct('STATUS',{},'SUBSTATUS',{},...
                'MESSAGE',{},'SOURCEOBJ',{});
                for p=1:numel(failedSlices)
                    sliceName=failedSlices{p};
                    sliceStatus=bObject.getStatusForSlice(sliceName);
                    sliceSubstatus=bObject.getSubstatusForSlice(sliceName);
                    sliceList(p).STATUS.CONTENT=...
                    reportConfig.getStatusMessage(sliceStatus);
                    sliceList(p).STATUS.ATTRIBUTES=sliceStatus;
                    sliceSubstatusReason=reportConfig.getReasonMessage(...
                    sliceSubstatus);
                    if~isempty(sliceSubstatusReason)
                        sliceList(p).SUBSTATUS.CONTENT=[...
                        ' (',sliceSubstatusReason,') '];
                    end

                    sliceList(p).MESSAGE.CONTENT=' for ';


                    sliceObject=blockSliceReader.getObject(sliceName);
                    sliceList(p).SOURCEOBJ.CONTENT=sliceObject.getCallback(datamgr);
                end
                statusList(k).SLICELIST=sliceList;
            end

        else



            statusList(k).SLICELIST.MESSAGE.CONTENT='-';
        end
        if slcifeature('SLCIJustification')==1
            statusList(k).JUSTIFICATION.CONTENT='-';
        end
    end



end
