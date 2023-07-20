function v=baseValidateComplex(this,ports,msg)






















    v=hdlvalidatestruct;

    if~isempty(ports)
        is_complex=false;

        for ii=1:length(ports)
            sig=ports(ii).Signal;
            if~isempty(sig)&&hdlsignaliscomplex(sig)
                is_complex=true;
                break;
            end
        end

        if(is_complex)
            v=hdlvalidatestruct(1,msg);
        end
    end
