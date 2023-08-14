function vector_sig=hdlissignalvector(signal)





    if hdlispirbased
        vector_sig=hdlissignaltype(signal,'vector');
    else
        vects=hdlsignalvector(signal);
        if iscell(vects)
            vector_sig=any(cell2mat(vects));
        else
            vector_sig=any(vects);
        end
    end
end
