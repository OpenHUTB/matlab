function[dtRow,unitsRow,interpRow,bpathRow,portRow]=initializeMetadataRows(~,opts)



    dtRow={};
    unitsRow={};
    interpRow={};
    bpathRow={};
    portRow={};

    if(opts.metadata.dataType)
        dtRow={''};
    end
    if(opts.metadata.units)
        unitsRow={''};
    end
    if(opts.metadata.interp)
        interpRow={''};
    end
    if(opts.metadata.blockPath)
        bpathRow={''};
    end
    if(opts.metadata.portIndex)
        portRow={''};
    end
end
