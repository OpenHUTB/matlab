function status=isBlockAtHighestRate(this,signal)%#ok





    status=false;
    hcurrentdriver=hdlcurrentdriver;
    maxRate=hcurrentdriver.PirInstance.DutBaseRate;

    blockRate=hdlsignalrate(signal);

    if blockRate==maxRate
        status=true;
    end
