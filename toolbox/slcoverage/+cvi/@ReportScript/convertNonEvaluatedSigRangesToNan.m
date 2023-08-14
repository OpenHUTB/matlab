
function[min,max]=convertNonEvaluatedSigRangesToNan(min,max)
    if~isempty(min)
        for idx=1:numel(min)
            if min(idx)==inf&&max(idx)==-inf
                min(idx)=NaN;
                max(idx)=NaN;
            end
        end
    end
