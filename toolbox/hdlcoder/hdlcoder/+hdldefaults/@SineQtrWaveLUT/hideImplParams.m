function params=hideImplParams(~,blockHandle,~)
    if blockHandle~=-1
        referenceBlock=get_param(blockHandle,'ReferenceBlock');
        if contains(referenceBlock,'HDL Optimized')...
            &&strcmpi(get_param(blockHandle,'SimulateLUTROMDelay'),'off')
            params={};
        else
            params={'maptoram'};
        end
    else
        params={};
    end
end