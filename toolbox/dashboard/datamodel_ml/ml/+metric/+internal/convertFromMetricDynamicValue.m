function value=convertFromMetricDynamicValue(mfValue)
    value=[];

    if~isempty(mfValue)
        switch class(mfValue)
        case{'metric.data.DoubleValue','metric.data.Uint64Value'}
            value=mfValue.Value;
        case 'metric.data.StringValue'
            value=string(mfValue.Value);
        case{'metric.data.DoubleVectorValue','metric.data.Uint64VectorValue'}
            for i=1:mfValue.Value.Size
                value=[value,mfValue.Value(i)];%#ok<AGROW>
            end
        case 'metric.data.FractionValue'
            value.Numerator=mfValue.Numerator;
            value.Denominator=mfValue.Denominator;
        case 'metric.data.DistributionValue'
            value=struct('BinCounts',[],'BinEdges',[]);
            for i=1:mfValue.BinCounts.Size
                value.BinCounts=[value.BinCounts,mfValue.BinCounts(i)];
            end
            for i=1:mfValue.BinEdges.Size
                binEdgeValue=metric.internal.convertFromMetricDynamicValue(mfValue.BinEdges(i));
                value.BinEdges=[value.BinEdges,binEdgeValue];
            end
        end
    end
end