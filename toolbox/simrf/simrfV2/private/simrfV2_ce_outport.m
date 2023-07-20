function[newData]=simrfV2_ce_outport(origData)






    newData(length(origData))=struct;
    s_idx=0;

    introduce_stepsize=true;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case 'SensorType'
            s_idx=s_idx+1;
            newData(s_idx).Name='SensorType';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'OutputFormat'
            s_idx=s_idx+1;
            newData(s_idx).Name='OutputFormat';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'CarrierFreq'
            s_idx=s_idx+1;
            newData(s_idx).Name='CarrierFreq';
            newData(s_idx).Value=origData(n_idx).Value;
        case{'CarrierFreqUnit','CarrierFreq_unit'}
            s_idx=s_idx+1;
            newData(s_idx).Name='CarrierFreq_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'ZL'
            s_idx=s_idx+1;
            newData(s_idx).Name='ZL';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'InternalGrounding'
            s_idx=s_idx+1;
            newData(s_idx).Name='InternalGrounding';
            newData(s_idx).Value=origData(n_idx).Value;

        case 'AutoStep'
            s_idx=s_idx+1;
            newData(s_idx).Name='AutoStep';
            newData(s_idx).Value=origData(n_idx).Value;
        case 'StepSize'
            s_idx=s_idx+1;
            newData(s_idx).Name='StepSize';
            newData(s_idx).Value=origData(n_idx).Value;
            introduce_stepsize=false;
        case 'StepSize_unit'
            s_idx=s_idx+1;
            newData(s_idx).Name='StepSize_unit';
            newData(s_idx).Value=origData(n_idx).Value;
        end
    end

    if introduce_stepsize


        s_idx=s_idx+1;
        newData(s_idx).Name='AutoStep';
        newData(s_idx).Value='off';

        s_idx=s_idx+1;
        newData(s_idx).Name='StepSize';
        newData(s_idx).Value='-1';

        s_idx=s_idx+1;
        newData(s_idx).Name='StepSize_unit';
        newData(s_idx).Value='s';
    end

    newData=newData(1:s_idx);

end