function largestSimdWidth=getLargestSIMDWidth(intrinsicName,intrinsicBaseType,buildContext,modelName)
















    if isa(buildContext.ConfigData,'Simulink.ConfigSet')&&nargin<4
        modelName=bdroot(gcs);



    elseif nargin<4
        modelName=[];
    end

    simdWidths=dltargets.internal.getSIMDWidths(intrinsicName,intrinsicBaseType,buildContext,...
    modelName);
    if~isempty(simdWidths)
        largestSimdWidth=simdWidths(end);
    else
        largestSimdWidth=1;
    end

end
