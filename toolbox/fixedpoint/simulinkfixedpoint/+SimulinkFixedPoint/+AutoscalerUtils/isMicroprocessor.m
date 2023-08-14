function res=isMicroprocessor(model)




    if nargin>0
        model=convertStringsToChars(model);
    end

    res=true;
    curRoot=bdroot(model);
    cs=getActiveConfigSet(curRoot);
    devType=lower(get_param(cs,'ProdHWDeviceType'));

    asic='asic';
    fpga='fpga';
    unconstr='unconstr';

    if(strncmp(devType,asic,length(asic))||...
        strncmp(devType,fpga,length(fpga))||...
        strncmp(devType,unconstr,length(unconstr)))
        res=false;
    end
end


