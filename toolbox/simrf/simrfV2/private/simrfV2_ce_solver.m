function[newData]=simrfV2_ce_solver(origData)






    newData(length(origData))=struct;
    s_idx=0;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case 'CarrierFreq'
            s_idx=s_idx+1;
            newData(s_idx).Name='Tones';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'CarrierFreqUnit'
            s_idx=s_idx+1;
            newData(s_idx).Name='Tones_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'EnvTemperature'
            s_idx=s_idx+1;
            newData(s_idx).Name='Temperature';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'EnvTemperatureUnit'
            s_idx=s_idx+1;
            newData(s_idx).Name='Temperature_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'AddThermalNoise'
            s_idx=s_idx+1;
            newData(s_idx).Name='AddNoise';
            newData(s_idx).Value=origData(n_idx).Value;
        end
    end

    s_idx=s_idx+1;
    newData(s_idx).Name='Harmonics';
    newData(s_idx).Value='[1]';

    s_idx=s_idx+1;
    newData(s_idx).Name='SolverDelFlag';
    newData(s_idx).Value='1';

    s_idx=s_idx+1;
    newData(s_idx).Name='NormalizeCarrierPower';
    newData(s_idx).Value='off';

    newData=newData(1:s_idx);

end