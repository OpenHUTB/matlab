function[rtpList,rtpIndices]=nesl_daertplist(mdlRtpMap,paramInfo)




































    [rtpList,rtpWidths,rtpIndices]=nesl_rtpsort(paramInfo);

    lValidateMdlRtps(mdlRtpMap,rtpList,rtpWidths,rtpIndices,'logical');
    lValidateMdlRtps(mdlRtpMap,rtpList,rtpWidths,rtpIndices,'int32');
    lValidateMdlRtps(mdlRtpMap,rtpList,rtpWidths,rtpIndices,'uint32');
    lValidateMdlRtps(mdlRtpMap,rtpList,rtpWidths,rtpIndices,'double');
end



function lValidateMdlRtps(mdlRtpMap,rtpList,rtpWidths,rtpIndices,type)

    switch type
    case 'logical'
        idx=rtpIndices.logicals;
    case 'int32'
        idx=rtpIndices.integers;
    case 'uint32'
        idx=rtpIndices.indices;
    case 'double'
        idx=rtpIndices.reals;
    otherwise
        pm_assert('Unrecognized RTP type')
    end

    if isempty(idx)
        return
    end


    idx=idx+1;

    ids=rtpList(idx);
    widths=rtpWidths(idx);


    for i=1:numel(ids)
        id=ids{i};
        wt=widths(i);


        pm_assert(mdlRtpMap.isKey(id),...
        'DAE request non-runtime model parameter');
        v=mdlRtpMap(id);
        if isa(v,'Simulink.Parameter')
            v=v.Value;
        end

        pm_assert(numel(v)==wt,'Size of model RTP does not match DAE request');
        if~isa(v,type)
            pm_error('physmod:simscape:engine:sli:nesl_autogenmask:UnexpectedDataType',...
            id,class(v),type);
        end
    end
end

