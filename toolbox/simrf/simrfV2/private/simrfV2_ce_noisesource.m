function[newData]=simrfV2_ce_noisesource(origData)






    newData(length(origData))=struct;
    s_idx=0;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case{'SimulinkInputSignalType','NoisePSD','CarrierFreq',...
            'InternalGrounding'}
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        case 'CarrierFreqUnit'
            s_idx=s_idx+1;
            newData(s_idx).Name='CarrierFreq_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        end
    end

    newData=newData(1:s_idx);

end