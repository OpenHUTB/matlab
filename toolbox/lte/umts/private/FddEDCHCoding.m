















function out=FddEDCHCoding(input,redundancy,frameCapacity)
    out=double(fdd('EdchCoding',input,redundancy,frameCapacity)).';
end

