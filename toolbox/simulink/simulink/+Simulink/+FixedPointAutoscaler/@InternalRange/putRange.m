function putRange(obj,range)




    assert(~isempty(range),'Expected non-empty range in Simulink.FixedPointAutoscaler.InternalRange.putRange');
    result=findResultFromArrayOrCreate(obj.runObj,{'Object',obj.blockObject,'ElementName','1'});
    if isRangeOutsideResult(result,range)
        result.updateResultData(struct('CalcDerivedMin',range(1),'CalcDerivedMax',range(2)));
    end

    function ret=isRangeOutsideResult(result,range)
        ret=false;
        if result.hasDerivedMinMax
            if(~isempty(result.DerivedMin)&&result.DerivedMin>range(1))||...
                (~isempty(result.DerivedMax)&&result.DerivedMax<range(2))
                ret=true;
            end
        else
            ret=true;
        end

