function openPort=getOpenPort()






    if(isempty(getenv('MW_INSTALL')))
        openPort=0;
        return;
    end

    envPort=getenv('CEF_DEBUG_PORT');
    if~isempty(envPort)
        openPort=str2double(envPort);
        return;
    end

    try
        wmi=matlab.internal.WebwindowManagerInterface;
        openPort=double(wmi.getOpenPort());
    catch
        openPort=0;
    end
