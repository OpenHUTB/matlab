function value=BlockSupportsCap(blockObj,inCap)




    value=false;
    capsets=blockObj.Capabilities.CapabilitySets;
    for ii=1:length(capsets)
        caps=capsets(ii).CapabilityArray;
        for jj=1:length(caps)
            cap=caps(jj);
            if strcmpi(cap.Capability,inCap)&&strcmpi(cap.Support,'Yes')
                value=true;
                return
            end
        end
    end
end
