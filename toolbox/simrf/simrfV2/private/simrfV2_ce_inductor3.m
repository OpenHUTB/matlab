function[newData]=simrfV2_ce_inductor3(origData)






    newData(length(origData))=struct;
    s_idx=0;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case{'L1','L1_unit','L2','L2_unit','L3','L3_unit','K12',...
            'K12_unit','K13','K13_unit','K23','K23_unit'}
            s_idx=s_idx+1;
            newData(s_idx).Name='Inductance';
            newData(s_idx).Value=origData(n_idx).Value;
        end
    end

    newData=newData(1:s_idx);

end
