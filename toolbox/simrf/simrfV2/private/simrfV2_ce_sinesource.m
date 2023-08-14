function[newData]=simrfV2_ce_sinesource(origData)






    newData(length(origData))=struct;
    s_idx=0;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case{'SineSourceType','VO_I','VO_I_Unit','IO_I','IO_I_Unit',...
            'VO_Q','VO_Q_Unit','IO_Q','IO_Q_Unit','VA_I','VA_I_Unit',...
            'IA_I','IA_I_Unit','VA_Q','VA_Q_Unit','IA_Q','IA_Q_Unit',...
            'Fmod','Fmod_Unit','TD','TD_Unit','CarrierFreq',...
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