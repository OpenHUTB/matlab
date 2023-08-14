classdef Range















    properties(SetAccess=private)
        Minimum(1,:)double{mustBeReal,mustBeFinite}
        Maximum(1,:)double{mustBeReal,mustBeFinite}
        NumberOfDimensions(1,1)double{mustBeGreaterThanOrEqual(NumberOfDimensions,1)}=1
        Interval(1,:)fixed.Interval
    end

    methods
        function this=Range(rangeMinimum,rangeMaximum)

            this.Minimum=rangeMinimum;
            this.Maximum=rangeMaximum;
            assert(all(rangeMinimum<rangeMaximum));
            this.NumberOfDimensions=numel(this.Maximum);
            this.Interval=fixed.Interval(this.Minimum,this.Maximum,'[]');
        end

        function range=getRangeForDimension(this,dimension)

            [minValue,maxValue]=getMinMaxForDimension(this,dimension);
            range=maxValue-minValue;
        end

        function[minValue,maxValue]=getMinMaxForDimension(this,dimension)


            minValue=this.Minimum(dimension);
            maxValue=this.Maximum(dimension);
        end
    end
end
