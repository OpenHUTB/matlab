












function out=getBlockParamInfoFromMask(blkHandle,extractInfoFromParentSS)

    out={};


    if extractInfoFromParentSS
        parentMaskSS=getNearestParentMaskSS(blkHandle);
        if isempty(parentMaskSS)
            return;
        end
        blkParams=getBlockParamValues(blkHandle);
        out=extractMaskInfoFromParents(parentMaskSS,blkParams);



    elseif slci.internal.isMasked(blkHandle)



        blkParams=getBlockParamNames(blkHandle);
        out=extractMaskInfoFromBlock(blkHandle,blkParams);
    end
end

function out=getNearestParentMaskSS(blkHandle)

    out=[];

    blockObject=get_param(blkHandle,'Object');



    if slci.internal.isUnderMaskSS(blkHandle)
        out=slci.internal.getMaskBlock(blockObject.Parent);
    else
        return;
    end
end

function out=getBlockParamNames(blkHandle)

    out={};
    try

        blkParams=get_param(blkHandle,'DialogParameters');
        if isstruct(blkParams)
            out=fieldnames(blkParams);
        end
    catch

        out={};
    end
end

function out=getBlockParamValues(blkHandle)

    out={};

    if slci.internal.isMasked(blkHandle)
        blkParamNames=getBlockParamNames(blkHandle);
    else



        if strcmp(get_param(blkHandle,'BlockType'),'ModelReference')


            blkParamNames={'InstanceParameters'};
        else
            rtpList={};
            blkRTPObj=get_param(blkHandle,'RuntimeObject');
            if~isempty(blkRTPObj)
                nRTP=blkRTPObj.NumRuntimePrms;
                for i=1:nRTP
                    RTP=blkRTPObj.RuntimePrm(i);
                    if~isempty(RTP)
                        rtpList{end+1}=RTP.Name;
                    end
                end
            end
            blkParamNames=rtpList;
        end
        if strcmp(get_param(blkHandle,'BlockType'),'S-Function')


            out=blkParamNames;
            return;
        end
        if strcmp(get_param(blkHandle,'BlockType'),'Lookup_n-D')




            blkParamNames{end+1}='LookupTableObject';
        end
    end

    for i=1:numel(blkParamNames)


        try
            blkParamValue=get_param(blkHandle,blkParamNames{i});
            if~isempty(blkParamValue)
                if isstruct(blkParamValue)

                    if strcmp(get_param(blkHandle,'BlockType'),'ModelReference')...
                        &&strcmp(blkParamNames{i},'InstanceParameters')
                        for k=1:numel(blkParamValue)
                            if isvarname(blkParamValue(k).Value)

                                out{end+1}=blkParamValue(k).Value;
                            end
                        end
                    end
                elseif isvarname(blkParamValue)
                    out{end+1}=blkParamValue;

                end
            else
                out{end+1}=blkParamNames{i};
            end
        catch
            out{end+1}=blkParamNames{i};
        end
    end
end

function out=extractMaskInfoFromBlock(maskBlockHdl,blkParams)



    names={};
    values={};
    out={names,values};
    if isempty(blkParams)
        return;
    end

    if~isempty(maskBlockHdl)

        maskParamMap=getMaskParamMap(maskBlockHdl);

        if isempty(maskParamMap)
            return;
        end

        for i=1:numel(blkParams)
            nameToFind=blkParams{i};
            if maskParamMap.isKey(nameToFind)
                names{end+1}=nameToFind;%#ok
                values{end+1}=maskParamMap(nameToFind);%#ok
            end
        end

        out={names,values};
    end
end

function out=extractMaskInfoFromParents(parentHdl,blkParams)
    out=extractMaskInfoFromBlock(parentHdl,blkParams);




    names=out{1};
    toDelete=cellfun(@(v)contains(v,names),blkParams);
    blkParams(toDelete)=[];

    if isempty(blkParams)
        return;
    end


    parentMaskSS=getNearestParentMaskSS(parentHdl);
    if isempty(parentMaskSS)
        return;
    end


    extractedInfo=extractMaskInfoFromParents(parentMaskSS,blkParams);
    if~isempty(extractedInfo)
        out={horzcat(out{1},extractedInfo{1}),horzcat(out{2},extractedInfo{2})};
    end
end

function out=getMaskParamMap(blkHandle)


    maskNames=get_param(blkHandle,'MaskNames');
    maskValues=get_param(blkHandle,'MaskValues');

    if isempty(maskNames)
        out=containers.Map;
        return;
    end

    out=containers.Map(maskNames,maskValues);
end
