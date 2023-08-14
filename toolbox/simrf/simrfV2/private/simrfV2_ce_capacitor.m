function[newData]=simrfV2_ce_capacitor(origData)






    newData(length(origData))=struct;
    s_idx=0;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case{'C','Capacitance'}
            s_idx=s_idx+1;
            newData(s_idx).Name='Capacitance';
            newData(s_idx).Value=origData(n_idx).Value;
        case{'C_unit','Capacitance_unit'}
            s_idx=s_idx+1;
            newData(s_idx).Name='Capacitance_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        end
    end

    newData=newData(1:s_idx);

end