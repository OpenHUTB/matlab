function Pwatts=simrfV2_convert2watts(Power,Unit)

    if isinf(Power)
        Pwatts=inf;
        return
    end
    switch Unit
    case 'W'
        Pwatts=Power;
    case 'mW'
        Pwatts=0.001*Power;
    case 'dBW'
        Pwatts=10.^(Power/10);
    case 'dBm'
        Pwatts=0.001*10.^(Power/10);
    end
end