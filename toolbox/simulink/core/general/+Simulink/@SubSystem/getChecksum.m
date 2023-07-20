function[checksum,additionalInfo]=getChecksum(subsys)













































































    switch nargout
    case{0,1}
        checksum=slprivate('getSSChecksumImpl',subsys);
    case 2
        [checksum,additionalInfo]=slprivate('getSSChecksumImpl',subsys);
    end

end

