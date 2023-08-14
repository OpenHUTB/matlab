function[newData]=simrfV2_ce_resistor(origData)






    newData(length(origData))=struct;
    s_idx=0;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case 'R'
            s_idx=s_idx+1;
            newData(s_idx).Name='Resistance';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'R_unit'
            s_idx=s_idx+1;
            newData(s_idx).Name='Resistance_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        end
    end

    s_idx=s_idx+1;
    newData(s_idx).Name='AddNoise';
    newData(s_idx).Value='off';

    newData=newData(1:s_idx);

end