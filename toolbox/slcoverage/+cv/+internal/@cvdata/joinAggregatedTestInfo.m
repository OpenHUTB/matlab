function nai=joinAggregatedTestInfo(lhsCvd,rhsCvd)










    try
        nai=[];
        cvdArray=[lhsCvd,rhsCvd];

        if~any([cvdArray.traceOn])

            return;
        end

        for i=1:numel(cvdArray)
            cai=cvdArray(i).aggregatedTestInfo;
            if isempty(cai)
                cai=cv.internal.cvdata.createAggregatedTestInfo(cvdArray(i));
            end
            nai=[nai,cai];%#ok<AGROW>
        end
    catch MEx
        rethrow(MEx);
    end
end



