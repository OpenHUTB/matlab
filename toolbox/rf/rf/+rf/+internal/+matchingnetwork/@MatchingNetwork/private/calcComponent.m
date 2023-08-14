

function[type,value]=calcComponent(reactance,frequency)
    if(reactance>=0)
        type='L';
        value=reactance/(2*pi*frequency);
    else
        type='C';
        value=-1/(2*pi*frequency*reactance);
    end
end