function metricValue=convertToMetricDynamicValue(mfModel,value)

    metricValue=metric.data.MetricDynamicValue.empty();

    if~isempty(value)
        switch class(value)
        case 'double'
            if(isscalar(value))
                metricValue=metric.data.DoubleValue(mfModel);
                metricValue.Value=value;
            else
                metricValue=metric.data.DoubleVectorValue(mfModel);
                for i=1:length(value)
                    metricValue.Value.insertAt(value(i),i);
                end
            end
        case 'uint64'
            if(isscalar(value))
                metricValue=metric.data.Uint64Value(mfModel);
                metricValue.Value=value;
            else
                metricValue=metric.data.Uint64VectorValue(mfModel);
                for i=1:length(value)
                    metricValue.Value.insertAt(value(i),i);
                end
            end
        case{'char','string'}
            metricValue=metric.data.StringValue(mfModel);
            metricValue.Value=value;
        case 'struct'
            if(isfield(value,'Numerator')&&isfield(value,'Denominator'))
                metricValue=metric.data.FractionValue(mfModel);
                metricValue.Numerator=uint64(value.Numerator);
                metricValue.Denominator=uint64(value.Denominator);
            elseif(isfield(value,'BinCounts')&&isfield(value,'BinEdges'))
                metricValue=metric.data.DistributionValue(mfModel);
                for i=1:length(value.BinCounts)
                    metricValue.BinCounts.insertAt(uint64(value.BinCounts(i)),i);
                end
                for i=1:length(value.BinEdges)
                    mfValue=metric.internal.convertToMetricDynamicValue(mfModel,value.BinEdges(i));
                    metricValue.BinEdges.insertAt(mfValue,i);
                end
            else
                ME=MException('Invalid value type');
                throw(ME);
            end
        otherwise
            ME=MException('Invalid value type');
            throw(ME);
        end
    end
end
