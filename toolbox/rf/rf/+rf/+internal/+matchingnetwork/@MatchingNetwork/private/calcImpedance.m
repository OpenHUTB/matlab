

function[z]=calcImpedance(componentType,value,frequency)
    if(componentType==1||componentType==3)
        z=1/(1j*2*pi*frequency*value);
    else
        z=1j*2*pi*frequency*value;
    end
end