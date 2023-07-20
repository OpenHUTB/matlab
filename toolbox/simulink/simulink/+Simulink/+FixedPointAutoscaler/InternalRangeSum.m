classdef InternalRangeSum<Simulink.FixedPointAutoscaler.InternalRange




    methods(Access='public')

        function this=InternalRangeSum(blkObj,runObj,allResults)
            this=this@Simulink.FixedPointAutoscaler.InternalRange(blkObj,runObj,allResults);
        end

        function calcInternalRange(this)
            inputRanges=this.getInputConnectedRanges();
            if numel(inputRanges)==2
                inputComplexity=this.getInputConnectedComplexity();
                outputComplexity=any([inputComplexity{:}]);
                outRange=this.calcAddRange(inputRanges{1},inputRanges{2},outputComplexity);
                this.putRange(outRange);
            end
        end

    end

    methods(Access='protected')
        function putRange(this,outRange)
            result=findResultFromArrayOrCreate(this.runObj,{'Object',this.blockObject,'ElementName','Accumulator'});
            if~isempty(result)
                result.updateResultData(struct('CalcDerivedMin',outRange(1),'CalcDerivedMax',outRange(2)));
            end
        end

    end

end

