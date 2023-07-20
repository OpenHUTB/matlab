function[vl,vi,vj,vr]=nesl_setrtpvalues(parameterInfo,ids,vals)






    rtpMap=containers.Map(ids,vals);


    [rtpList,rtpIndices]=nesl_daertplist(rtpMap,parameterInfo);


    vl=lRtpValues(rtpMap,rtpList(rtpIndices.logicals+1));
    vi=lRtpValues(rtpMap,rtpList(rtpIndices.integers+1));
    vj=lRtpValues(rtpMap,rtpList(rtpIndices.indices+1));
    vr=lRtpValues(rtpMap,rtpList(rtpIndices.reals+1));
end



function values=lRtpValues(rtpMap,ids)

    values=[];
    for i=1:numel(ids)
        v=rtpMap(ids{i});
        if isa(v,'Simulink.Parameter')
            v=v.Value;
        end
        values=[values;v(:)];%#ok
    end
end
