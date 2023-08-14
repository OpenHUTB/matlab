function flag=checkResourceSharing(this)




    resource_sharing_list={'Detect Change','DiscreteFir','DiscreteIntegrator','DiscreteTransferFcn','EnablePort',...
    'HDL Minimum Resource FFT','HDL_FIFO','MinMax','Sqrt','TriggerPort','Unit Delay Enabled Resettable','Unit Delay Resettable'};
    resource_sharing_sources=strjoin(resource_sharing_list,'|');

    [flag,blocks]=this.getMatchingHandleAndMaskedBlocks(resource_sharing_sources,'no-resource-sharing');%#ok<ASGLU>
end