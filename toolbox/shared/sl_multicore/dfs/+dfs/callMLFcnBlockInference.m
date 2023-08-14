function size=callMLFcnBlockInference(blockHandle,inSizes)





    size=0;
    assert(slprivate('is_stateflow_based_block',blockHandle),...
    'Expected a MATLAB Function Block');
    chartId=sfprivate('block2chart',blockHandle);
    if nargin<2
        inSizes={[4,1]};
    end
    sf('PrePropagateCompileSizesEml',gcbh,chartId,inSizes);

end
