function IM=utilInitalizeModeVector(EqnData)









    maxMode=0;


    if isfield(EqnData.DiffClumpInfo,'ReferencedModes')
        maxMode=max(maxMode,double(max(EqnData.DiffClumpInfo.ReferencedModes)));
    end
    if~isempty(EqnData.ClumpInfo)
        if~isempty(EqnData.ClumpInfo(1).OwnedStates)
            for i=1:numel(EqnData.ClumpInfo)
                if~isempty(EqnData.ClumpInfo(i).ReferencedModes)
                    maxMode=max(maxMode,double(max(EqnData.ClumpInfo(i).ReferencedModes)));
                end
            end
        end
    end
    if~isempty(EqnData.ModeIndices)

        maxMode=max(maxMode,double(max(EqnData.ModeIndices)));

    end

    if maxMode<1
        maxMode=1;
    end

    IM=zeros(maxMode,1);





    if~isempty(EqnData.DiffClumpInfo.MatrixModes)
        IM(EqnData.DiffClumpInfo.MatrixModes)=EqnData.DiffClumpInfo.MatrixInfo(end).ModeVec;
    end

    for i=1:numel(EqnData.ClumpInfo)
        if~isempty(EqnData.ClumpInfo(1).OwnedStates)
            if~isempty(EqnData.ClumpInfo(i).MatrixModes)
                IM(EqnData.ClumpInfo(i).ReferencedModes(EqnData.ClumpInfo(i).MatrixModes))=EqnData.ClumpInfo(i).MatrixInfo(end).ModeVec;
            end
        end
    end

    featIntModes=matlab.internal.feature("SSC2HDLIntegerModes");
    if(featIntModes)
        IM=int32(IM);
    else
        IM=logical(IM);
    end
end
