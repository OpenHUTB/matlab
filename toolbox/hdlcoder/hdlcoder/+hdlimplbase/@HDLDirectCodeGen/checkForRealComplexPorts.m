function[noports,any_complex,all_complex]=...
    checkForRealComplexPorts(this,ports)%#ok<INUSL>









    if~isempty(ports)
        noports=false;
        any_complex=false;
        all_complex=true;

        for ii=1:length(ports)
            sig=ports(ii).Signal;
            if hdlsignaliscomplex(sig)
                any_complex=true;
            else
                all_complex=false;
            end
        end
    else
        noports=true;
        any_complex=false;
        all_complex=false;
    end

end
