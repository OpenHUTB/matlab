



function tf=hasTunableLUTObject(aBlk)
    tf=false;
    assert(strcmpi(aBlk.BlockType,'Lookup_n-D'));
    dataSpec=aBlk.DataSpecification;
    if strcmpi(dataSpec,'Lookup table object')
        lutPropValues=slci.internal.getLookupObjectValue(...
        aBlk.Handle,aBlk.LookupTableObject);
        if isKey(lutPropValues,'SupportTunableSize')&&...
            lutPropValues('SupportTunableSize')
            tf=true;
        end
    end
end