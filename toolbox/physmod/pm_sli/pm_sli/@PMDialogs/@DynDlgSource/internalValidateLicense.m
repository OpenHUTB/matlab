function errorString=internalValidateLicense(hThis,hBlock)











    if~isa(hBlock,'double')
        hBlock=hBlock.Handle;
    end
    [~,errorString]=pm.sli.internal.checklicense(hBlock);

end
