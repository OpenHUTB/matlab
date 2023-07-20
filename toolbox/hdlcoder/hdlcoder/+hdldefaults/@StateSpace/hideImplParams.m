function params=hideImplParams(~,blockHandle,~)
    if blockHandle~=-1
        referenceBlock=get_param(blockHandle,'ReferenceBlock');
        if contains(referenceBlock,'Dynamic State-Space')
            params={'dspstyle','dotproductstrategy'};
        else
            params={};
        end
    else
        params={};
    end
end