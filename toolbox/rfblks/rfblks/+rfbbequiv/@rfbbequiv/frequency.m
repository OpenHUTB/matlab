function freq=frequency(h)







    maxlen=get(h,'MaxLength');
    ts=get(h,'Ts');
    fc=get(h,'Fc');


    ifftlen=2^ceil(log2(maxlen));


    freq=((-ifftlen/2):(ifftlen/2-1))*(1/ts)/ifftlen+fc;


    if any(freq<=0.0)
        if isempty(h.Block)
            errHole=sprintf('%s: ',h.Name);
        else
            errHole='';
        end
        error(message(['rfblks:rfbbequiv:rfbbequiv:frequency:'...
        ,'WrongInputsToInputPort'],errHole));
    end
