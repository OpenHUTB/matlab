function yesNo=isCompatibleSwAddrMethod(m3iSwAddrMethod)




    yesNo=~isempty(m3iSwAddrMethod)&&m3iSwAddrMethod.isvalid()&&...
    any(strcmp(m3iSwAddrMethod.MemoryAllocationKeywordPolicy,{'','ADDR-METHOD-SHORT-NAME'}));

end


