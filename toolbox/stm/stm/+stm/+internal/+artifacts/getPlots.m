function hFigArr=getPlots(resultID,indx,source)

    s=get(groot,'Default');
    oc=onCleanup(@()set(groot,'Default',s));
    set(groot,'DefaultFigureVisible','off');
    byteStreams=stm.internal.getArtifacts(resultID,indx,source);

    cnt=length(byteStreams);
    hFigArr=gobjects(cnt,1);

    for idx=1:cnt
        if isa(byteStreams{idx},'matlab.ui.Figure')
            hFigArr(idx)=byteStreams{idx};
        end
    end
end

