classdef NumericBinValue<SimBiology.internal.plotting.categorization.binvalue.BinValue


    methods(Access=?SimBiology.internal.plotting.categorization.binvalue.BinValue)
        function obj=getEmptyObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.NumericBinValue.empty;
        end

        function obj=getUnconfiguredObject(obj)
            obj=SimBiology.internal.plotting.categorization.binvalue.NumericBinValue;
        end

        function flag=isValueInput(obj,values)
            flag=isnumeric(values);
        end

        function configureSingleObjectFromValue(obj,value)
            set(obj,'value',value);
        end
    end


    methods(Access=public)
        function value=type(obj)
            value=SimBiology.internal.plotting.categorization.binvalue.BinValue.NUMERIC;
        end


        function flag=isEqual(obj,comparisonObj)
            flag=(obj.value==comparisonObj.value);
        end

        function name=getDisplayNameHelper(obj,plotDefinition,categoryDefinition)
            name=num2str(obj.value);
        end

        function value=getScatterplotValue(obj)
            value=vertcat(obj.value);
        end

        function rangeBinValues=createRangeBinValues(obj,numBins)

            binBoundaries=obj.getBinBoundaries(numBins);

            actualNumBins=numel(binBoundaries)-1;


            rangeBinValues(actualNumBins,1)=SimBiology.internal.plotting.categorization.binvalue.RangeBinValue;

            for i=1:actualNumBins
                rangeBinValues(i).value=[binBoundaries(i),binBoundaries(i+1)];
            end
        end
    end

    methods(Access=private)
        function binBoundaries=getBinBoundaries(obj,numBins)

            values=unique([obj.value]);
            if numBins==1
                binBoundaries=[min(values),inf];
            elseif numel(values)==1
                binBoundaries=[values,inf];
            else
                delta=100/numBins;
                percentiles=prctile(values,delta:delta:100-delta);

                binBoundaries=[-inf,percentiles,inf];


                c=histcounts(values,binBoundaries);
                d=min(diff(percentiles));
                orderOfMag=round(log10(d));
                maxRoundingDigit=4;
                for i=-orderOfMag:maxRoundingDigit
                    roundedBoundaries=round(binBoundaries,i);
                    c_rounded=histcounts(values,roundedBoundaries);
                    if(isequal(c_rounded,c))
                        binBoundaries=roundedBoundaries;
                        break;
                    end
                end

                binBoundaries=unique(binBoundaries);
            end
        end
    end
end