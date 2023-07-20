function openPeripheralConfiguration(hCS,blockPath)







    if nargin==2

        codertarget.peripherals.AppController(hCS,blockPath);
    else

        codertarget.peripherals.AppController(hCS);
    end

end
