function cCodeGen(this,config)%#ok<INUSD>







    fileName=fullfile(matlabroot,'toolbox','shared','eda','fpgaautomation','+eda','+avnet','@AES_DVCI_G','soft_channel_hil.out');

    copyfile(fileName,'./soft_channel_hil.out','f');

end

