function[newData]=simrfV2_ce_configuration(origData)






    newData(length(origData))=struct;
    s_idx=0;
    fndNCP=false;
    for n_idx=1:length(origData)
        switch origData(n_idx).Name
        case{'AutoFreq'
'Tones'
'Tones_unit'
'Harmonics'
'SolverType'
'StepSize'
'StepSize_unit'
'AddNoise'
'defaultRNG'
'Seed'
'Temperature'
'Temperature_unit'
'SolverDelFlag'
'AbsTol'
'RelTol'
'MaxIter'
'ErrorEstimationType'
            }
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        case 'NormalizeCarrierPower'
            fndNCP=true;
            s_idx=s_idx+1;
            newData(s_idx).Name=origData(n_idx).Name;
            newData(s_idx).Value=origData(n_idx).Value;
        end
    end

    if~fndNCP
        s_idx=s_idx+1;
        newData(s_idx).Name='NormalizeCarrierPower';
        newData(s_idx).Value='off';
    end

    s_idx=s_idx+1;
    newData(s_idx).Name='EnableInterpFilter';
    newData(s_idx).Value='off';

    newData=newData(1:s_idx);

end
